# azure-minecraft-server

## Overview

Minecraft server hosted in Azure. Managed in code using Azure Bicep.

Minecraft is ran as a container and data stored on a file share. Also contains an function app to start / stop the container using a URL to minimise costs.

## Deploy

Run deployment `az deployment group create --name minecraft --resource-group minecraft --template-file main.bicep`

## Conclusion

* Bicep is more confusing than cloudformation. I will never insult AWS doco ever again.
