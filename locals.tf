locals {
  prefix = var.project

  # ─── Resource names ───────────────────────────────────────────────────────
  resource_group_name           = var.resource_group_name_override != "" ? var.resource_group_name_override : "rg-${local.prefix}"
  vnet_name                     = "vnet-${local.prefix}"
  private_subnet_name           = "snet-${local.prefix}-private"
  public_subnet_name            = "snet-${local.prefix}-public"
  nsg_private_name              = "nsg-${local.prefix}-private"
  nsg_public_name               = "nsg-${local.prefix}-public"
  databricks_workspace_name     = "dbw-${local.prefix}"
  managed_resource_group_name   = var.managed_resource_group_name_override != "" ? var.managed_resource_group_name_override : "rg-${local.prefix}-managed"

  # ─── Catalog storage account name (3-24 chars, lowercase alphanumeric only) ─
  catalog_storage_account_name = substr(replace("st${var.project}cat", "-", ""), 0, 24)

  # ─── Tags ─────────────────────────────────────────────────────────────────
  common_tags = merge(
    {
      project    = var.project
      location   = var.location
      managed_by = "terraform"
    },
    var.tags
  )
}
