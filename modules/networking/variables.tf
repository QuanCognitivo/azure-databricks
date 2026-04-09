variable "resource_group_name" {
  description = "Name of the resource group in which to create networking resources."
  type        = string
}

variable "location" {
  description = "The Azure region for all networking resources."
  type        = string
}

variable "tags" {
  description = "Tags to apply to all networking resources."
  type        = map(string)
  default     = {}
}

variable "enable_vnet_injection" {
  description = "When true, creates VNet, subnets, and NSGs for Databricks VNet injection."
  type        = bool
  default     = true
}

variable "vnet_name" {
  description = "Name of the Virtual Network."
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the Virtual Network (CIDR notation)."
  type        = list(string)
  default     = ["10.100.0.0/16"]
}

variable "private_subnet_name" {
  description = "Name of the Databricks private (container) subnet."
  type        = string
}

variable "public_subnet_name" {
  description = "Name of the Databricks public (host) subnet."
  type        = string
}

variable "private_subnet_address_prefix" {
  description = "CIDR prefix for the Databricks private subnet. Must be /26 or larger."
  type        = string
  default     = "10.100.1.0/26"
}

variable "public_subnet_address_prefix" {
  description = "CIDR prefix for the Databricks public subnet. Must be /26 or larger."
  type        = string
  default     = "10.100.2.0/26"
}

variable "nsg_private_name" {
  description = "Name of the NSG attached to the private subnet."
  type        = string
}

variable "nsg_public_name" {
  description = "Name of the NSG attached to the public subnet."
  type        = string
}
