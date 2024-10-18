terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.6.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.54.0"
    }    
  }
}

provider "azurerm" {
  features {
  }
}