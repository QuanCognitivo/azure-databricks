variable "resource_group_name" {
  description = "Name of the resource group in which to create the Databricks workspace."
  type        = string
}

variable "location" {
  description = "The Azure region for the Databricks workspace."
  type        = string
}

variable "tags" {
  description = "Tags to apply to the Databricks workspace."
  type        = map(string)
  default     = {}
}

variable "databricks_workspace_name" {
  description = "Name of the Databricks workspace."
  type        = string
}

variable "managed_resource_group_name" {
  description = "Name of the Databricks-managed resource group."
  type        = string
}

variable "databricks_sku" {
  description = "Databricks workspace SKU. Allowed values: standard, premium, trial."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium", "trial"], var.databricks_sku)
    error_message = "databricks_sku must be one of: standard, premium, trial."
  }
}

variable "enable_vnet_injection" {
  description = "When true, deploys the workspace into the supplied VNet subnets."
  type        = bool
  default     = true
}

variable "no_public_ip" {
  description = "When true, cluster nodes have no public IP (Secure Cluster Connectivity / SCC)."
  type        = bool
  default     = true
}

variable "vnet_id" {
  description = "Resource ID of the Virtual Network. Required when enable_vnet_injection = true."
  type        = string
  default     = ""
}

variable "private_subnet_name" {
  description = "Name of the Databricks private subnet. Required when enable_vnet_injection = true."
  type        = string
  default     = ""
}

variable "public_subnet_name" {
  description = "Name of the Databricks public subnet. Required when enable_vnet_injection = true."
  type        = string
  default     = ""
}

variable "private_subnet_nsg_assoc_id" {
  description = "Resource ID of the private subnet NSG association. Required when enable_vnet_injection = true."
  type        = string
  default     = ""
}

variable "public_subnet_nsg_assoc_id" {
  description = "Resource ID of the public subnet NSG association. Required when enable_vnet_injection = true."
  type        = string
  default     = ""
}
