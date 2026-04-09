# ─── Resource Group ───────────────────────────────────────────────────────────

output "resource_group_name" {
  description = "The name of the Azure Resource Group."
  value       = azurerm_resource_group.this.name
}

output "resource_group_id" {
  description = "The resource ID of the Azure Resource Group."
  value       = azurerm_resource_group.this.id
}

# ─── Networking ───────────────────────────────────────────────────────────────

output "vnet_id" {
  description = "The resource ID of the Virtual Network. Empty string when VNet injection is disabled."
  value       = module.networking.vnet_id
}

output "vnet_name" {
  description = "The name of the Virtual Network. Empty string when VNet injection is disabled."
  value       = module.networking.vnet_name
}

output "private_subnet_id" {
  description = "The resource ID of the Databricks private subnet. Empty string when VNet injection is disabled."
  value       = module.networking.private_subnet_id
}

output "public_subnet_id" {
  description = "The resource ID of the Databricks public subnet. Empty string when VNet injection is disabled."
  value       = module.networking.public_subnet_id
}

output "nsg_private_id" {
  description = "The resource ID of the NSG attached to the private subnet. Empty string when VNet injection is disabled."
  value       = module.networking.nsg_private_id
}

output "nsg_public_id" {
  description = "The resource ID of the NSG attached to the public subnet. Empty string when VNet injection is disabled."
  value       = module.networking.nsg_public_id
}

# ─── Databricks Workspace ─────────────────────────────────────────────────────

output "databricks_workspace_id" {
  description = "The resource ID of the Azure Databricks workspace."
  value       = module.databricks.workspace_id
}

output "databricks_workspace_name" {
  description = "The name of the Azure Databricks workspace."
  value       = module.databricks.workspace_name
}

output "databricks_workspace_url" {
  description = "The URL of the Databricks workspace."
  value       = module.databricks.workspace_url
}

output "databricks_workspace_numeric_id" {
  description = "The numeric ID of the workspace, required for SCIM and account-level API calls."
  value       = module.databricks.workspace_numeric_id
}

output "managed_resource_group_name" {
  description = "The name of the Databricks-managed resource group."
  value       = module.databricks.managed_resource_group_name
}

output "managed_resource_group_id" {
  description = "The resource ID of the Databricks-managed resource group."
  value       = module.databricks.managed_resource_group_id
}

output "workspace_login_command" {
  description = "Ready-to-use Databricks CLI login command for this workspace."
  value       = "databricks configure --host ${module.databricks.workspace_url}"
}

# ─── Unity Catalog Catalogs ───────────────────────────────────────────────────

output "catalog_names" {
  description = "Names of the Unity Catalog catalogs created for each environment."
  value       = { for env, cat in databricks_catalog.env : env => cat.name }
}

output "catalog_storage_account_name" {
  description = "Name of the ADLS Gen2 storage account backing the Unity Catalog catalogs."
  value       = azurerm_storage_account.catalog.name
}

output "catalog_access_connector_id" {
  description = "Resource ID of the Databricks Access Connector used by Unity Catalog."
  value       = azurerm_databricks_access_connector.catalog.id
}

output "catalog_storage_credential_name" {
  description = "Name of the Databricks storage credential backing the catalog external locations."
  value       = databricks_storage_credential.catalog.name
}

output "catalog_external_location_urls" {
  description = "External location URLs registered in Unity Catalog, keyed by environment."
  value       = { for env, loc in databricks_external_location.catalog : env => loc.url }
}
