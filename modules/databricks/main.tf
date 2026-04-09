# ─── Databricks Workspace ─────────────────────────────────────────────────────

resource "azurerm_databricks_workspace" "this" {
  name                        = var.databricks_workspace_name
  resource_group_name         = var.resource_group_name
  location                    = var.location
  sku                         = var.databricks_sku
  managed_resource_group_name = var.managed_resource_group_name
  tags                        = var.tags

  dynamic "custom_parameters" {
    for_each = var.enable_vnet_injection ? [1] : []

    content {
      no_public_ip                                         = var.no_public_ip
      virtual_network_id                                   = var.vnet_id
      private_subnet_name                                  = var.private_subnet_name
      public_subnet_name                                   = var.public_subnet_name
      private_subnet_network_security_group_association_id = var.private_subnet_nsg_assoc_id
      public_subnet_network_security_group_association_id  = var.public_subnet_nsg_assoc_id
    }
  }
}
