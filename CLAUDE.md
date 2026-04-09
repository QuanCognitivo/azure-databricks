# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

```bash
# Initialize (download providers per .terraform.lock.hcl)
terraform init

# Validate configuration syntax
terraform validate

# Preview changes
terraform plan

# Apply changes
terraform apply

# Destroy all resources
terraform destroy

# Format code
terraform fmt -recursive

# Target a specific resource or module
terraform plan -target=module.networking
terraform apply -target=module.networking
```

## Architecture Overview

This project provisions a complete Azure Databricks platform with Unity Catalog and Fivetran ingestion using a three-layer architecture:

1. **Networking** (`modules/networking/`) — VNet with private/public subnet pair, each with a dedicated NSG. NSG rules are intentionally left empty; Databricks injects required rules during workspace creation. Service delegation to `Microsoft.Databricks/workspaces` is required on both subnets. All resources are gated by `enable_vnet_injection`; outputs return empty strings when disabled.

2. **Databricks Workspace** (`modules/databricks/`) — Single workspace resource with a dynamic `custom_parameters` block that is only populated when `enable_vnet_injection = true`. `no_public_ip = true` enables Secure Cluster Connectivity (SCC) by default.

3. **Unity Catalog** (root `main.tf`) — ADLS Gen2 storage account (HNS enabled — required for Unity Catalog) with three containers (dev/staging/prod). An Access Connector with a system-assigned managed identity is granted `Storage Blob Data Contributor` on the storage account. External locations and catalogs are created per environment using the naming pattern `{project}_{environment}`.

### Dependency Order

Resource Group → Networking → Databricks Workspace → Unity Catalog resources

The Databricks provider is authenticated dynamically using the workspace URL output, so all Databricks-level resources depend on the workspace being fully created first.

## Key Conventions

**Resource naming** — `locals.tf` sets `prefix = var.project`. All resource names follow the pattern `{type}-{project}` (e.g., `rg-vertaview`, `dbw-vertaview`). Storage account names are sanitized to remove hyphens and truncate to 24 lowercase alphanumeric characters (Azure storage naming constraint).

**Variable file** — `terraform.tfvars` is git-ignored. It must be created locally with at minimum `subscription_id` and `tenant_id`.

**Provider authentication** — The `azurerm` and `databricks` providers authenticate via Azure CLI (`az login`) or environment variables.

**Remote state** — The backend block in `providers.tf` is commented out. To enable it, uncomment and supply a `backend.hcl` file at `terraform init` time (partial configuration pattern).

**NSG auto-injection** — Do not add manual NSG rules to the networking module. Databricks injects its required rules automatically during workspace provisioning; manual rules will conflict.

**Unity Catalog managed identity flow** — Access Connector (system-assigned MI) → Azure RBAC role assignment (Storage Blob Data Contributor) → Databricks Storage Credential → External Locations → Catalogs. The `depends_on` chain on the storage credential enforces this ordering.

**Environment isolation** — Three catalogs (`{project}_dev`, `{project}_staging`, `{project}_prod`) each backed by a dedicated storage container provide full isolation and independent access controls.
