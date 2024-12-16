import json
import random
import requests
from azure.iot.device import IoTHubDeviceClient
import time
from plant import Plant

# Connect to IoT Hub
CONNECTION_STRING = "iot hub device Primary connection string"
client = IoTHubDeviceClient.create_from_connection_string(CONNECTION_STRING)

plant = Plant(40, 60)  
roomTemperature = random.uniform(20, 30)  # Simulated room temperature

# Fetch watering command from Flask
def fetch_watering_command():
    try:
        response = requests.get('http://localhost:5000/get-command')
        if response.status_code == 200:
            command = response.json()
            return command
        else:
            #print("Failed to fetch command:", response.status_code)
            return {"action": None}
    except Exception as e:
        #print("Error fetching command:", e)
        return {"action": None}

# Send message to IoT Hub
def send_message(data):  
    try:
        message = json.dumps(data)
        client.send_message(message)
        print("Message sent:", message)
    except Exception as e:
        print("Failed to send message:", e)

# Function to handle watering command
def process_watering_command(command):
    print(command)
    if plant.isWaterable() and command.get("action") == "water":
        plant.startWatering()

def update():  
    while True:
        # Update plant data
        plant.update(roomTemperature)
        print(plant.moisture," ",plant.waterLevel)
        
        # Send plant data to IoT Hub
        data = {
            "moisture": plant.moisture,
            "waterLevel": plant.waterLevel
        }
        #send_message(data)

        # Fetch watering command from Flask
        watering_command = fetch_watering_command()

        # Process watering command
        process_watering_command(watering_command)

        # Sleep to simulate delay (adjust time as needed)
        time.sleep(2)

# Start the update loop
update()

"""
-data is sent to cosmos db via iot hub on mqtt
-watering command is recieved with https request BUT request action is stacked as water?

"""