terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.0"
    }
  }

  # Partial backend config — values are supplied at init time via backend.hcl.
  # Run: scripts/bootstrap-state.sh to provision the storage, then:
  #   terraform init -backend-config=backend.hcl
  backend "azurerm" {}
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

# The Databricks provider is configured after the workspace exists.
# Authentication falls through to Azure CLI / env vars / Managed Identity.
provider "databricks" {
  host = module.databricks.workspace_url
}
