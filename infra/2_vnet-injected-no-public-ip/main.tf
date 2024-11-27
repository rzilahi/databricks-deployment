########################################################################################
# VNET injected Databricks workspace with no public IP feature
########################################################################################

resource "azurerm_resource_group" "databricks_rg" {
  name     = var.resourceGroupName
  location = var.location
}

########################################################################################
# Network related resources
########################################################################################
resource "azurerm_virtual_network" "databricks_vnet" {
  name = "${var.workspaceName}-vnet"
  resource_group_name = azurerm_resource_group.databricks_rg.name
  location = azurerm_resource_group.databricks_rg.location
  address_space = ["10.0.0.0/22"]
}

# Both public and private subnets must be delegated to Microsoft.Databricks/workspaces
resource "azurerm_subnet" "public_subnet" {
  name = "${var.workspaceName}-public-subnet"
  resource_group_name = azurerm_resource_group.databricks_rg.name
  virtual_network_name = azurerm_virtual_network.databricks_vnet.name
  address_prefixes     = ["10.0.0.0/24"]
  delegation {
    name = "databricks-delegation-private"

    service_delegation {
      name = "Microsoft.Databricks/workspaces"
    }
  }
}

resource "azurerm_subnet" "private_subnet" {
  name = "${var.workspaceName}-private-subnet"
  resource_group_name = azurerm_resource_group.databricks_rg.name
  virtual_network_name = azurerm_virtual_network.databricks_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  delegation {
    name = "databricks-delegation-private"

    service_delegation {
      name = "Microsoft.Databricks/workspaces"
    }
  }
}

resource "azurerm_network_security_group" "databricks_nsg" {
  name                = "${var.workspaceName}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.databricks_rg.name
  lifecycle {
    ignore_changes = [
      security_rule
    ]
  }
}

resource "azurerm_subnet_network_security_group_association" "public_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.public_subnet.id
  network_security_group_id = azurerm_network_security_group.databricks_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "private_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.private_subnet.id
  network_security_group_id = azurerm_network_security_group.databricks_nsg.id
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

  custom_parameters {
    no_public_ip                                         = true
    virtual_network_id                                   = azurerm_virtual_network.databricks_vnet.id
    private_subnet_name                                  = azurerm_subnet.private_subnet.name
    public_subnet_name                                   = azurerm_subnet.public_subnet.name
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.public_subnet_nsg_association.id
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.private_subnet_nsg_association.id
    storage_account_name                                 = "${var.workspaceName}-dbfs"
  }
  # We need this, otherwise destroy doesn't cleanup things correctly
  depends_on = [
    azurerm_subnet_network_security_group_association.public,
    azurerm_subnet_network_security_group_association.private
  ]
}