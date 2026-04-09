output "vnet_id" {
  description = "The resource ID of the Virtual Network. Empty string when VNet injection is disabled."
  value       = var.enable_vnet_injection ? azurerm_virtual_network.this[0].id : ""
}

output "vnet_name" {
  description = "The name of the Virtual Network. Empty string when VNet injection is disabled."
  value       = var.enable_vnet_injection ? azurerm_virtual_network.this[0].name : ""
}

output "private_subnet_id" {
  description = "The resource ID of the Databricks private subnet. Empty string when VNet injection is disabled."
  value       = var.enable_vnet_injection ? azurerm_subnet.private[0].id : ""
}

output "public_subnet_id" {
  description = "The resource ID of the Databricks public subnet. Empty string when VNet injection is disabled."
  value       = var.enable_vnet_injection ? azurerm_subnet.public[0].id : ""
}

output "private_subnet_name" {
  description = "The name of the Databricks private subnet. Empty string when VNet injection is disabled."
  value       = var.enable_vnet_injection ? azurerm_subnet.private[0].name : ""
}

output "public_subnet_name" {
  description = "The name of the Databricks public subnet. Empty string when VNet injection is disabled."
  value       = var.enable_vnet_injection ? azurerm_subnet.public[0].name : ""
}

output "nsg_private_id" {
  description = "The resource ID of the NSG attached to the private subnet. Empty string when VNet injection is disabled."
  value       = var.enable_vnet_injection ? azurerm_network_security_group.private[0].id : ""
}

output "nsg_public_id" {
  description = "The resource ID of the NSG attached to the public subnet. Empty string when VNet injection is disabled."
  value       = var.enable_vnet_injection ? azurerm_network_security_group.public[0].id : ""
}

output "private_subnet_nsg_assoc_id" {
  description = "The resource ID of the private subnet NSG association. Empty string when VNet injection is disabled."
  value       = var.enable_vnet_injection ? azurerm_subnet_network_security_group_association.private[0].id : ""
}

output "public_subnet_nsg_assoc_id" {
  description = "The resource ID of the public subnet NSG association. Empty string when VNet injection is disabled."
  value       = var.enable_vnet_injection ? azurerm_subnet_network_security_group_association.public[0].id : ""
}
