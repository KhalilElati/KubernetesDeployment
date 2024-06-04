
data "azurerm_client_config" "current" {}
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.54.0"
    }
  }
  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "resource-group" {
  name     = "AKS-resource-group"
  location = var.resource_group_location
  
}

resource "azurerm_kubernetes_cluster" "cluster" {
  name                = "cluster-${var.stage}-aks"
  location            = azurerm_resource_group.resource-group.location
  resource_group_name = azurerm_resource_group.resource-group.name
  dns_prefix          = "k8s-dns"
  public_network_access_enabled = true
  default_node_pool {
    name            = "default"
    node_count      = 1
    vm_size         = "Standard_A2_v2"
    os_disk_size_gb = 30
  }

 identity {
    type = "SystemAssigned"
  }
  tags = {
    environment = var.stage
  }
  
}