import random
import time
import json
import ssl
from paho.mqtt import client as mqtt
from plant import Plant

# Azure IoT Hub connection details
path_to_root_cert = r"D:\\CDV\\Semester_5\\IoT\\IOT\\Simulation\\root_cert.pem"
device_id = "plant-1"
sas_token = "SharedAccessSignature sr=my-iot-hub-watering.azure-devices.net%2Fdevices%2Fplant-1&sig=F2AnYxtOuNpu0ApXFzeTmT%2FQ9S7iydUt6Pnl8SvOUUY%3D&se=1734524165"
iot_hub_name = "my-iot-hub-watering"

plant = Plant(40, 60)  
roomTemperature = random.uniform(20, 30)  # Simulated room temperature


def on_connect(client, userdata, flags, rc):
    print("Device connected with result code: " + str(rc))


def on_disconnect(client, userdata, rc):
    print("Device disconnected with result code: " + str(rc))


def on_publish(client, userdata, mid):
    print("Device sent message")


def on_subscribe(client, userdata, mid, granted_qos):
    print("Topic subscribed!")


def on_message(client, userdata, msg):
    print("Received message!\n")
    print("Topic: '" + msg.topic + "', payload: " + str(msg.payload))

    try:
        # Parse the incoming message payload as a JSON object
        payload = json.loads(msg.payload)

        # Check if the "action" field is present and its value is "water"
        if 'action' in payload:
            if payload['action'] == 'water':
                print("Received action to water the plant.")
                # Perform the action (e.g., start watering)
                if plant.isWaterable():
                    plant.startWatering()
                    print("watering is started")
            else:
                print(f"Unknown action: {payload['action']}")
        else:
            print("Action not specified in the message.")

    except json.JSONDecodeError:
        print("Failed to decode JSON message.")


def simulate_device():

    client = mqtt.Client(client_id=device_id, protocol=mqtt.MQTTv311)

    client.on_connect = on_connect
    client.on_disconnect = on_disconnect
    client.on_publish = on_publish
    client.on_subscribe = on_subscribe
    client.on_message = on_message

    #Azure IoT Hub connection details
    print(iot_hub_name+".azure-devices.net/" +
          device_id + "/?api-version=2021-04-12")
    client.username_pw_set(username=iot_hub_name+".azure-devices.net/" +
                           device_id + "/?api-version=2021-04-12", password=sas_token)

    client.tls_set(ca_certs=path_to_root_cert, certfile=None, keyfile=None,
                   cert_reqs=ssl.CERT_REQUIRED, tls_version=ssl.PROTOCOL_TLSv1_2, ciphers=None)
    client.tls_insecure_set(False)

    print("Connecting MQTT broker")
    client.connect(iot_hub_name+".azure-devices.net", port=8883)

    print("Connected to MQTT broker")

    topic = "devices/" + device_id + "/messages/events/"
    print(f"MQTT topic: {topic}")

    while True:
        plant.update(roomTemperature)
        print(plant.moisture," ",plant.waterLevel)
        # Send data to IoT hub
        send_data_to_iot_hub(client, plant.moisture, plant.waterLevel , topic)

        # Wait for some time before sending the next data
        time.sleep(1)


def send_data_to_iot_hub(device_client, moisture, waterLevel, topic):
    payload = {
        "device_id": device_id,
        "moisture": moisture,
        "waterLevel": waterLevel,
        "timestamp": time.time()
    }
    message = json.dumps(payload)
    device_client.publish(topic, message, qos=1)
    print(f"Message sent: {message}")


# Start simulating the device
simulate_device()