# Azure Terraform based .NET Deployment (Assessment Kit)

This repository contains a complete starter implementation for the assessment:

- Architecture proposal: `docs/architecture.md`
- Infrastructure as Code: `terraform/`
- CI/CD pipeline: `.github/workflows/deploy.yml`
- Minimal sample .NET 10 app and solution using the required assessment names:
  - `Netwrix.DevOps.Test.sln`
  - `Netwrix.DevOps.Test.App` (published as `Netwrix.DevOps.Test.App.zip`)

## What this deploys

- Linux compute for .NET app: Azure App Service (Linux)
- Database: Azure Database for PostgreSQL Flexible Server
- WAF/Firewall: Azure Application Gateway WAF v2
- Networking: VNet, dedicated subnets, NSGs, DB private DNS
- Secrets/config: Azure Key Vault + app settings using Key Vault references
- Logging/monitoring: Log Analytics + Application Insights + diagnostics

## Quick start

1. Read `docs/architecture.md` (use this in your submission).
2. Configure Terraform variables (`terraform/terraform.tfvars`).
3. Create Azure Federated Identity for GitHub OIDC.
4. Add GitHub repository secrets/variables.
5. Push to `main` branch and run workflow.

---

## Manual steps you need to do

### 1) Prerequisites on your machine

- Azure subscription with permissions to create resources.
- Terraform `>= 1.6`.
- Azure CLI logged in (`az login`).
- GitHub repository for this code.

### 2) Create state storage (one-time)

Create a storage account/container for Terraform remote state (recommended). Example:

- Resource Group: `rg-tfstate-shared`
- Storage Account: globally unique, e.g. `sttfstateabc123`
- Container: `tfstate`

You can do this from portal or CLI.

### 3) Configure Terraform backend

Edit `terraform/backend.hcl` and set:

- `resource_group_name`
- `storage_account_name`
- `container_name`
- `key`

### 4) Prepare Terraform variables

Create `terraform/terraform.tfvars` from `terraform/terraform.tfvars.example` and set:

- `project_name`
- `environment`
- `location`
- `db_admin_username`
- `db_admin_password` (temporary bootstrap; rotate immediately)
- `allowed_cidr_for_admin_access` (your office/home public IP CIDR)
- optional tags

### 5) Create Azure AD app + federated credential for GitHub OIDC

From Azure Portal or CLI:

- Create App Registration (or reuse existing).
- Create Service Principal.
- Assign minimal required roles on subscription or resource group:
  - `Contributor` (or split into fine-grained roles if desired)
  - `User Access Administrator` only if pipeline must assign roles
- Add Federated Credential:
  - Issuer: `https://token.actions.githubusercontent.com`
  - Subject: `repo:<org>/<repo>:ref:refs/heads/main`
  - Audience: `api://AzureADTokenExchange`

Collect:

- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`

### 6) Configure GitHub repository settings

Add **Repository Secrets**:

- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`
- `TF_DB_ADMIN_PASSWORD`

Add **Repository Variables**:

- `AZURE_RESOURCE_GROUP` (optional if you use env file approach)
- `AZURE_WEBAPP_NAME` (if you want explicit override)

### 7) Update pipeline environment values

Edit `.github/workflows/deploy.yml`:

- `TF_WORKING_DIR` if needed.
- Ensure Terraform var passing matches your naming.
- Optional: add `environment` protection/approvals in GitHub.

### 8) First deployment

Run locally once (recommended):

```powershell
cd terraform
terraform init -backend-config=backend.hcl
terraform plan -out tfplan
terraform apply tfplan
```

Then push to GitHub and let the workflow run.

### 9) Deploy app artifact

Pipeline builds:

- Solution: `Netwrix.DevOps.Test.sln`
- Project: `Netwrix.DevOps.Test.App/Netwrix.DevOps.Test.App.csproj`
- Artifact: `Netwrix.DevOps.Test.App.zip`

If you replace the sample app with a real one, keep the same naming or update `APP_SOLUTION_PATH` / `APP_PROJECT_PATH` in the workflow.

### 10) Post-deploy validation

- Browse Application Gateway public IP / DNS.
- Verify App Service is not directly accessible (IP restrictions).
- Check Key Vault references resolve in App Service config.
- Confirm logs in Log Analytics and Application Insights.
- Validate DB private connectivity from app (via VNet integration).

---

## Deliverables mapping

- Requirement 1 (architecture): `docs/architecture.md`
- Requirement 2 (IaC): `terraform/*`
- Requirement 3 (CI/CD): `.github/workflows/deploy.yml`

## Notes / tradeoffs

- This is assessment-focused and intentionally concise.
- Production hardening items are listed in architecture “Next steps” section.
