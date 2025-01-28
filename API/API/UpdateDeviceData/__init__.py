import logging
import azure.functions as func
import json
from azure.cosmos import CosmosClient, exceptions
import os
import time
from datetime import datetime

COSMOS_DB_URL = os.getenv("COSMOS_DB_URL")
COSMOS_DB_KEY = os.getenv("COSMOS_DB_KEY")
client = CosmosClient(COSMOS_DB_URL, credential=COSMOS_DB_KEY)
database = client.get_database_client("TelemetryDB")
container = database.get_container_client("TelemetryData")

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Processing UpdateDeviceData request.")

    try:
        form_data = dict(req.form)
        logging.info(f"Received form data: {form_data}")

        body = {
            "id": form_data.get("id"),
            "user_id": form_data.get("user_id"),
            "device_id": form_data.get("device_id"),
            "soil_moisture": float(form_data.get("soil_moisture", 0)),
            "water_level": float(form_data.get("water_level", 0)),
            "timestamp": datetime.utcnow().isoformat() + "Z"
        }

        if not body["user_id"] or not body["device_id"]:
            return func.HttpResponse(
                json.dumps({"error": "Missing 'user_id' or 'device_id' in the form data."}),
                status_code=400,
                mimetype="application/json"
            )

        if not body["id"]:
            body["id"] = f"{body['user_id']}-{body['device_id']}-{str(int(time.time()))}"

        logging.info(f"Processed body for database: {body}")

        container.upsert_item(body)
        logging.info("Data upserted successfully.")

        return func.HttpResponse(
            json.dumps({"message": "Data updated successfully."}),
            status_code=200,
            mimetype="application/json"
        )

    except ValueError as ve:
        logging.error(f"Value conversion error: {ve}")
        return func.HttpResponse(
            json.dumps({"error": "Invalid numeric values in form data."}),
            status_code=400,
            mimetype="application/json"
        )
    except Exception as e:
        logging.error(f"Unexpected error: {e}")
        return func.HttpResponse(
            json.dumps({"error": f"Failed to update data: {str(e)}"}),
            status_code=500,
            mimetype="application/json"
        )
