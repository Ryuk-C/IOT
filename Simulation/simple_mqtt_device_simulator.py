import random
import time
import json
import ssl
from paho.mqtt import client as mqtt

from plant import Plant

# Azure IoT Hub connection details
path_to_root_cert = "root_cert.pem"
device_id = "my-new-device"
sas_token = "SharedAccessSignature sr=my-super-iot-hub-345u785358674.azure-devices.net%2Fdevices%2Fmy-new-device&sig=Zf4qI8ynyxGshGU1qV3bzsdaibLl6veopA3eBRl3ngw%3D&se=1732128200"
iot_hub_name = "my-super-iot-hub-345u785358674"

#----
plants=[]
last_execution_time = time.time()
roomTemperature = random.uniform(20, 30)

def initFakeWorldData():
    i=0
    plants.append(Plant(i,"Dragons Feverfew",40,60))
    i+=1
    plants.append(Plant(i,"Pink Annie",50,75))
    i+=1
    plants.append(Plant(i,"Dwarf Mulberry",70,100))

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
    print("Topic: '" + msg.topic+"', payload: " + str(msg.payload))


def sendData():
    print("data has been sent")

def update(_client,_topic):
    for p in plants:
        p.update(roomTemperature)
    print(plants[0].moisture , " ",plants[0].waterLevel)

    global last_execution_time
    if time.time() - last_execution_time >= 10:
        # Send data to IoT hub
        #send_data_to_iot_hub(_client, temperature, humidity, pressure, _topic)
        sendData()
        last_execution_time = time.time() 
    
    time.sleep(0.1)
    
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
    client.connect("my-super-iot-hub-345u785358674.azure-devices.net", port=8883)

    print("Connected to MQTT broker")

    topic = "devices/" + device_id + "/messages/events/"
    print(f"MQTT topic: {topic}")

    while True:
        update(client,topic)


def send_data_to_iot_hub(device_client, id, name, moisture, waterLevel, topic):
    payload = {
        "device_id": id,
        "name": name,
        "moisture": moisture,
        "humidity": waterLevel,
        "timestamp": time.time()
    }
    message = json.dumps(payload)
    device_client.publish(topic, message, qos=1)
    print(f"Message sent: {message}")


initFakeWorldData()

# Start simulating the device
#simulate_device()
while True:
    update(0,0)
