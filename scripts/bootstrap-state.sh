#!/usr/bin/env bash
# Provisions the Azure Storage backend for Terraform remote state.
# Run this once before the first `terraform init`.
#
# Usage:
#   chmod +x scripts/bootstrap-state.sh
#   ./scripts/bootstrap-state.sh
#
# After completion, initialise Terraform with:
#   terraform init -backend-config=backend.hcl
set -euo pipefail

# ─── Configuration ────────────────────────────────────────────────────────────
# Keep these in sync with terraform.tfvars.
SUBSCRIPTION_ID="93440e23-ac12-46e8-aafb-4b58882c1f6a"
LOCATION="southeastasia"
PROJECT="vertaview"

RG_NAME="rg-${PROJECT}-tfstate"
SA_NAME="st${PROJECT}tf"   # 13 chars — within 3-24 limit
CONTAINER_NAME="tfstate"
STATE_KEY="${PROJECT}.tfstate"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_HCL="${SCRIPT_DIR}/../backend.hcl"

# ─── Pre-flight ───────────────────────────────────────────────────────────────
echo "==> Setting subscription: ${SUBSCRIPTION_ID}"
az account set --subscription "${SUBSCRIPTION_ID}"

# ─── Resource group ───────────────────────────────────────────────────────────
echo "==> Creating resource group: ${RG_NAME}"
az group create \
  --name "${RG_NAME}" \
  --location "${LOCATION}" \
  --tags project="${PROJECT}" managed_by="bootstrap" \
  --output none

# ─── Storage account ──────────────────────────────────────────────────────────
echo "==> Creating storage account: ${SA_NAME}"
az storage account create \
  --name "${SA_NAME}" \
  --resource-group "${RG_NAME}" \
  --location "${LOCATION}" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --allow-blob-public-access false \
  --tags project="${PROJECT}" managed_by="bootstrap" \
  --output none

echo "==> Enabling blob versioning and soft-delete (90 days)"
az storage account blob-service-properties update \
  --account-name "${SA_NAME}" \
  --resource-group "${RG_NAME}" \
  --enable-versioning true \
  --enable-delete-retention true \
  --delete-retention-days 90 \
  --output none

# ─── Container ────────────────────────────────────────────────────────────────
echo "==> Creating container: ${CONTAINER_NAME}"
az storage container create \
  --name "${CONTAINER_NAME}" \
  --account-name "${SA_NAME}" \
  --auth-mode login \
  --output none

# ─── Write backend.hcl ────────────────────────────────────────────────────────
echo "==> Writing ${BACKEND_HCL}"
cat > "${BACKEND_HCL}" <<EOF
resource_group_name  = "${RG_NAME}"
storage_account_name = "${SA_NAME}"
container_name       = "${CONTAINER_NAME}"
key                  = "${STATE_KEY}"
EOF

echo ""
echo "Done. Next step:"
echo "  terraform init -backend-config=backend.hcl"
