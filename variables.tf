# ─── Identity ─────────────────────────────────────────────────────────────────

variable "subscription_id" {
  description = "The Azure Subscription ID in which all resources will be provisioned."
  type        = string
}

variable "tenant_id" {
  description = "The Azure Active Directory Tenant ID."
  type        = string
}

# ─── Naming & Location ────────────────────────────────────────────────────────

variable "project" {
  description = "Short project identifier used as a prefix in resource names (lowercase, no spaces)."
  type        = string
  default     = "dbw"
}

variable "location" {
  description = "The Azure region for all resources (e.g. 'eastus2', 'westeurope')."
  type        = string
  default     = "eastus2"
}

variable "tags" {
  description = "A map of additional tags applied to all taggable resources. Merged with locals.common_tags."
  type        = map(string)
  default     = {}
}

# ─── Resource Group ───────────────────────────────────────────────────────────

variable "resource_group_name_override" {
  description = "Optional: override the computed resource group name. Leave empty to use the auto-generated name."
  type        = string
  default     = ""
}

# ─── Networking ───────────────────────────────────────────────────────────────

variable "vnet_address_space" {
  description = "Address space for the Virtual Network (CIDR notation)."
  type        = list(string)
  default     = ["10.100.0.0/16"]
}

variable "private_subnet_address_prefix" {
  description = "CIDR prefix for the Databricks private (container) subnet. Must be /26 or larger."
  type        = string
  default     = "10.100.1.0/26"
}

variable "public_subnet_address_prefix" {
  description = "CIDR prefix for the Databricks public (host) subnet. Must be /26 or larger."
  type        = string
  default     = "10.100.2.0/26"
}

variable "enable_vnet_injection" {
  description = "When true, the Databricks workspace is deployed into the managed VNet subnets."
  type        = bool
  default     = true
}

variable "no_public_ip" {
  description = "When true, cluster nodes have no public IP (Secure Cluster Connectivity / SCC)."
  type        = bool
  default     = true
}

# ─── Databricks Workspace ─────────────────────────────────────────────────────

variable "databricks_sku" {
  description = "Databricks workspace SKU. Allowed values: standard, premium, trial."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium", "trial"], var.databricks_sku)
    error_message = "databricks_sku must be one of: standard, premium, trial."
  }
}

variable "managed_resource_group_name_override" {
  description = "Optional: override the name of the Databricks-managed resource group. Leave empty to use the auto-generated name."
  type        = string
  default     = ""
}
