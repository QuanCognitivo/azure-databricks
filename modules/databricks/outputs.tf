output "workspace_id" {
  description = "The resource ID of the Azure Databricks workspace."
  value       = azurerm_databricks_workspace.this.id
}

output "workspace_name" {
  description = "The name of the Azure Databricks workspace."
  value       = azurerm_databricks_workspace.this.name
}

output "workspace_url" {
  description = "The URL of the Databricks workspace."
  value       = azurerm_databricks_workspace.this.workspace_url
}

output "workspace_numeric_id" {
  description = "The numeric ID of the workspace, required for SCIM and account-level API calls."
  value       = azurerm_databricks_workspace.this.workspace_id
}

output "managed_resource_group_name" {
  description = "The name of the Databricks-managed resource group."
  value       = azurerm_databricks_workspace.this.managed_resource_group_name
}

output "managed_resource_group_id" {
  description = "The resource ID of the Databricks-managed resource group."
  value       = azurerm_databricks_workspace.this.managed_resource_group_id
}
