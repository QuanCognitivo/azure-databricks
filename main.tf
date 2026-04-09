# ─── Resource Group ───────────────────────────────────────────────────────────

resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# ─── Networking ───────────────────────────────────────────────────────────────

module "networking" {
  source = "./modules/networking"

  resource_group_name           = azurerm_resource_group.this.name
  location                      = azurerm_resource_group.this.location
  tags                          = local.common_tags
  enable_vnet_injection         = var.enable_vnet_injection
  vnet_name                     = local.vnet_name
  vnet_address_space            = var.vnet_address_space
  private_subnet_name           = local.private_subnet_name
  public_subnet_name            = local.public_subnet_name
  private_subnet_address_prefix = var.private_subnet_address_prefix
  public_subnet_address_prefix  = var.public_subnet_address_prefix
  nsg_private_name              = local.nsg_private_name
  nsg_public_name               = local.nsg_public_name
}

# ─── Databricks Workspace ─────────────────────────────────────────────────────

module "databricks" {
  source = "./modules/databricks"

  resource_group_name         = azurerm_resource_group.this.name
  location                    = azurerm_resource_group.this.location
  tags                        = local.common_tags
  databricks_workspace_name   = local.databricks_workspace_name
  managed_resource_group_name = local.managed_resource_group_name
  databricks_sku              = var.databricks_sku
  enable_vnet_injection       = var.enable_vnet_injection
  no_public_ip                = var.no_public_ip
  vnet_id                     = module.networking.vnet_id
  private_subnet_name         = module.networking.private_subnet_name
  public_subnet_name          = module.networking.public_subnet_name
  private_subnet_nsg_assoc_id = module.networking.private_subnet_nsg_assoc_id
  public_subnet_nsg_assoc_id  = module.networking.public_subnet_nsg_assoc_id
}

# ─── Catalog Storage (ADLS Gen2) ─────────────────────────────────────────────
# Dedicated storage account for Unity Catalog managed tables.
# HNS (hierarchical namespace) must be enabled for ADLS Gen2.

resource "azurerm_storage_account" "catalog" {
  name                     = local.catalog_storage_account_name
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true
  tags                     = local.common_tags
}

resource "azurerm_storage_container" "catalog" {
  for_each              = toset(["dev", "staging", "prod"])
  name                  = "${var.project}-${each.key}"
  storage_account_name  = azurerm_storage_account.catalog.name
  container_access_type = "private"
}

# ─── Databricks Access Connector ─────────────────────────────────────────────
# System-assigned managed identity used by Unity Catalog to read/write ADLS.

resource "azurerm_databricks_access_connector" "catalog" {
  name                = "ac-${local.prefix}-catalog"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tags                = local.common_tags

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "catalog_storage" {
  scope                = azurerm_storage_account.catalog.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.catalog.identity[0].principal_id
}

# ─── Storage Credential ───────────────────────────────────────────────────────
# Wraps the Access Connector managed identity so Unity Catalog can authenticate
# to ADLS on behalf of Databricks.

resource "databricks_storage_credential" "catalog" {
  name = "sc-${local.prefix}-catalog"

  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.catalog.id
  }

  depends_on = [module.databricks, azurerm_role_assignment.catalog_storage]
}

# ─── External Locations ───────────────────────────────────────────────────────
# Unity Catalog requires every storage path used as a catalog storage_root to
# be registered as an External Location first.

resource "databricks_external_location" "catalog" {
  for_each = toset(["dev", "staging", "prod"])

  name            = "el-${var.project}-${each.key}"
  url             = "abfss://${azurerm_storage_container.catalog[each.key].name}@${azurerm_storage_account.catalog.name}.dfs.core.windows.net/"
  credential_name = databricks_storage_credential.catalog.id

  depends_on = [databricks_storage_credential.catalog]
}

# ─── Unity Catalog Catalogs ───────────────────────────────────────────────────
# One catalog per environment. Each catalog is backed by its own ADLS container
# so managed tables for dev / staging / prod are fully isolated.
# Catalog names follow the pattern: {project}_{environment}

resource "databricks_catalog" "env" {
  for_each = toset(["dev", "staging", "prod"])

  name         = "${var.project}_${each.key}"
  comment      = "Catalog for the ${each.key} environment."
  storage_root = databricks_external_location.catalog[each.key].url

  depends_on = [databricks_external_location.catalog]
}
