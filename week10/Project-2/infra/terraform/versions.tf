terraform {
  required_version = ">= 1.6.0"

  backend "azurerm" {
    resource_group_name  = "group1_final"
    storage_account_name = "tfstategrp1sf26640"
    container_name       = "tfstate"
    key                  = "secureflow-dev.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}
}
