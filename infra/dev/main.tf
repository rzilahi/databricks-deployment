resource "azurerm_resource_group" "databricks-rg" {
  name     = var.resourceGroupName
  location = var.location
}

resource "azurerm_databricks_workspace" "workspace" {
  name                = var.workspaceName
  resource_group_name = azurerm_resource_group.databricks-rg.name
  location            = azurerm_resource_group.databricks-rg.location
  sku                 = "premium"
  tags = {
    workspace_name = var.workspaceName
  }
}
