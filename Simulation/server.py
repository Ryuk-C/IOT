from flask import Flask, request, jsonify

app = Flask(__name__)


# Store watering commands
watering_command = {"action": None}

@app.route('/send-command', methods=['POST'])
def send_command():
    global watering_command
    data = request.json
    watering_command = data
    print("Received command:", watering_command)
    return jsonify({"status": "success", "received_command": watering_command})

@app.route('/get-command', methods=['GET'])
def get_command():
    return jsonify(watering_command)

if __name__ == '__main__':
    app.run(debug=True, port=5000)
