# Azure Datanricks with Azure Private Link.

There are 2 options:
- **Simplified deployment**: only 1 private endpoint is being used for both front-end (user) and backed-end (clusters) connectivity.
- **Standard deployment (recommended)**: separate private endpoint for front-end connections (user) and a separate one for backend-end (clusters) connections.

Requirements:
- Premium SKU
- Must use VNET-injection

More info:<br>
https://learn.microsoft.com/en-us/azure/databricks/security/network/classic/private-link