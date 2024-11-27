########################################################################################
# Default workspace deployment
########################################################################################

resource "azurerm_resource_group" "databricks_rg" {
  name     = var.resourceGroupName
  location = var.location
}

########################################################################################
# Databricks workspace deployment
########################################################################################
resource "azurerm_databricks_workspace" "vnet_injected" {
  name                  = var.workspaceName
  resource_group_name   = azurerm_resource_group.databricks_rg.name
  location              = azurerm_resource_group.databricks_rg.location
  sku                           = "premium"
  public_network_access_enabled = true
}