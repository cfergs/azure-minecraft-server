# azure-minecraft-server

## Overview

Minecraft server hosted in Azure. Managed in code using Azure Bicep.

Minecraft is ran as a container and data stored on a file share. Also contains an function app to start / stop the container using a URL to minimise costs.

In addition leverages log analytics / application insights for viewing container / function app logs.

## Deploy

1. Create deployment group `az stack sub create --name minecraft --location australiaeast --template-file main.bicep --action-on-unmanage deleteResources --deny-settings-mode none`
2. Deploy function app -> in vscode, select command palette -> select `Azure Functions -> Deploy to Function App`. Choose function app created in previous step

## Conclusion

* Bicep is more confusing than cloudformation. I will never insult AWS doco ever again.

## Needs Work

* Haven't figured out how to deploy python through cli. Something for another day
* Missing python test cases
* Understanding if my usage of modules is appropriate
* Method to stop container group if is idle after X time period (likely a function app)
