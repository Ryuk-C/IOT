import random
import time
import json
import ssl
from threading import Thread
from paho.mqtt import client as mqtt
import socket

# Azure IoT Hub connection details

sas_token = ""

# Azure IoT Hub connection details
iot_hub_name = "wateringsystemhub"

# Configuration for multiple devices (at least 3 devices linked to 3 users)
device_configs = {
    "SoilSensorSimulator": {
        "sas_token": "",
        "user_id": "user_1"
    },
    "SoilSensorSimulator2": {
        "sas_token": "",
        "user_id": "user_2"
    },
    "SoilSensorSimulator3": {
        "sas_token":  "",
        "user_id": "user_3"
    }
}

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print(f"[{userdata}] Connected to IoT Hub successfully!")
    else:
        print(f"[{userdata}] Failed to connect. Return code: {rc}")

def on_disconnect(client, userdata, rc):
    print(f"[{userdata}] Disconnected from IoT Hub with result code: {rc}")
    if rc != 0:
        print(f"[{userdata}] Unexpected disconnection. Attempting to reconnect...")
        reconnect(client, userdata)

def on_publish(client, userdata, mid):
    print(f"[{userdata}] Message published successfully!")

def reconnect(client, device_id):
    """
    Reconnect the client to Azure IoT Hub.
    """
    try:
        print(f"[{device_id}] Reconnecting...")
        client.reconnect()
    except Exception as e:
        print(f"[{device_id}] Reconnection failed: {e}")
        time.sleep(5)  # Wait before retrying

def simulate_device(device_id, sas_token, user_id):
    """
    Simulate device behavior for sending data to Azure IoT Hub.
    """
    try:
        # Test DNS resolution
        ip = socket.gethostbyname(f"{iot_hub_name}.azure-devices.net")
        print(f"[{device_id}] IoT Hub resolved to IP: {ip}")
    except socket.gaierror:
        print(f"[{device_id}] Failed to resolve IoT Hub hostname. Check network or IoT Hub name.")
        return

    # Initialize MQTT client
    client = mqtt.Client(client_id=device_id, protocol=mqtt.MQTTv311, userdata=device_id)
    client.on_connect = on_connect
    client.on_disconnect = on_disconnect
    client.on_publish = on_publish

    # Configure MQTT client for Azure IoT Hub
    client.username_pw_set(
        username=f"{iot_hub_name}.azure-devices.net/{device_id}/?api-version=2021-04-12",
        password=sas_token
    )

    # Use system's default certificate store for TLS
    client.tls_set_context(ssl.create_default_context())

    print(f"[{device_id}] Connecting to Azure IoT Hub...")
    try:
        client.connect(f"{iot_hub_name}.azure-devices.net", port=8883)
    except Exception as e:
        print(f"[{device_id}] Error connecting to Azure IoT Hub: {e}")
        return

    client.loop_start()  # Start a non-blocking loop

    topic = f"devices/{device_id}/messages/events/"
    print(f"[{device_id}] Publishing to MQTT topic: {topic}")

    while True:
        # Generate random sensor data
        soil_moisture = random.uniform(10, 100)
        water_level = random.uniform(0, 100)

        # Create the payload with user_id
        payload = {
            "device_id": device_id,
            "user_id": user_id,
            "soil_moisture": soil_moisture,
            "water_level": water_level,
            "timestamp": time.time()
        }
        
        # Publish to IoT Hub
        message = json.dumps(payload)
        result = client.publish(topic, message, qos=1)

        if result.rc == mqtt.MQTT_ERR_SUCCESS:
            print(f"[{device_id}] Message sent: {message}")
        else:
            print(f"[{device_id}] Failed to send message: {result}")

        # Wait before sending the next data
        time.sleep(5)

if __name__ == "__main__":
    # Simulate each device in a separate thread
    for device_id, config in device_configs.items():
        Thread(target=simulate_device, args=(device_id, config["sas_token"], config["user_id"])).start()
