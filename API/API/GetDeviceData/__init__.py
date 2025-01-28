import logging
import azure.functions as func
import json
from azure.cosmos import CosmosClient, exceptions
import os

COSMOS_DB_URL = os.getenv("COSMOS_DB_URL")
COSMOS_DB_KEY = os.getenv("COSMOS_DB_KEY")
client = CosmosClient(COSMOS_DB_URL, credential=COSMOS_DB_KEY)
database = client.get_database_client("TelemetryDB")
container = database.get_container_client("TelemetryData")

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Processing GetDeviceData request.")

    user_id = req.params.get("user_id")
    device_id = req.params.get("device_id")

    if not user_id or not device_id:
        return func.HttpResponse(
            json.dumps({"error": "Missing 'user_id' or 'device_id' query parameters."}),
            status_code=400,
            mimetype="application/json"
        )

    try:
        query = f"SELECT * FROM c WHERE c.user_id = '{user_id}' AND c.device_id = '{device_id}'"
        items = list(container.query_items(query=query, enable_cross_partition_query=True))
        return func.HttpResponse(
            json.dumps(items),
            mimetype="application/json",
            status_code=200
        )
    except Exception as e:
        logging.error(f"Error fetching data: {e}")
        return func.HttpResponse(
            json.dumps({"error": "Failed to fetch data."}),
            status_code=500,
            mimetype="application/json"
        )
