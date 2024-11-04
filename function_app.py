import logging
import os

import azure.functions as func
from azure.identity import DefaultAzureCredential
from azure.mgmt.containerinstance import ContainerInstanceManagementClient

app = func.FunctionApp(http_auth_level=func.AuthLevel.FUNCTION)


@app.route(route="status")
def status(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Python HTTP trigger function processed a request.")

    action = req.params.get("action")

    if action:
        resource_group_name = os.getenv("MINECRAFT_RESOURCE_GROUP")
        container_group_name = os.getenv("MINECRAFT_CONTAINER_GROUP")
        subscription_id = os.getenv("MINECRAFT_SUBSCRIPTION_ID")

        # Authenticate using Azure Identity
        credential = DefaultAzureCredential()
        container_client = ContainerInstanceManagementClient(
            credential, subscription_id
        )

        if action == "start":
            container_client.container_groups.begin_start(
                resource_group_name, container_group_name
            )
            return func.HttpResponse(
                f"Started container group {container_group_name}", status_code=200
            )

        if action == "stop":
            container_client.container_groups.stop(
                resource_group_name, container_group_name
            )
            return func.HttpResponse(
                f"Stopped container group {container_group_name}", status_code=200
            )

        return func.HttpResponse(
            "Invalid action. Use 'start' or 'stop'.", status_code=400
        )

    else:
        return func.HttpResponse("ERROR, no action value specified.", status_code=404)
