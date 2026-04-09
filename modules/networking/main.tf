# ─── Virtual Network ──────────────────────────────────────────────────────────

resource "azurerm_virtual_network" "this" {
  count = var.enable_vnet_injection ? 1 : 0

  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

# ─── Network Security Groups ──────────────────────────────────────────────────
# Databricks automatically injects required NSG rules during workspace creation.
# Do NOT pre-create those rules — the service will reject conflicting entries.

resource "azurerm_network_security_group" "private" {
  count = var.enable_vnet_injection ? 1 : 0

  name                = var.nsg_private_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_group" "public" {
  count = var.enable_vnet_injection ? 1 : 0

  name                = var.nsg_public_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# ─── Subnets ──────────────────────────────────────────────────────────────────
# The Microsoft.Databricks/workspaces delegation is mandatory for VNet injection.

resource "azurerm_subnet" "private" {
  count = var.enable_vnet_injection ? 1 : 0

  name                 = var.private_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this[0].name
  address_prefixes     = [var.private_subnet_address_prefix]

  delegation {
    name = "databricks-del-private"

    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
      ]
    }
  }
}

resource "azurerm_subnet" "public" {
  count = var.enable_vnet_injection ? 1 : 0

  name                 = var.public_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this[0].name
  address_prefixes     = [var.public_subnet_address_prefix]

  delegation {
    name = "databricks-del-public"

    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
      ]
    }
  }
}

# ─── NSG Associations ─────────────────────────────────────────────────────────
# Associations must be created before the workspace.

resource "azurerm_subnet_network_security_group_association" "private" {
  count = var.enable_vnet_injection ? 1 : 0

  subnet_id                 = azurerm_subnet.private[0].id
  network_security_group_id = azurerm_network_security_group.private[0].id
}

resource "azurerm_subnet_network_security_group_association" "public" {
  count = var.enable_vnet_injection ? 1 : 0

  subnet_id                 = azurerm_subnet.public[0].id
  network_security_group_id = azurerm_network_security_group.public[0].id
}
