# Architecture Proposal - Azure Terraform based .NET Deployment

## 1) Service choices and why

- **Azure App Service (Linux)** for hosting `Netwrix.DevOps.Test.App`: managed PaaS, easy CI/CD zip deploy, autoscale support, minimal operational burden.
- **Azure Database for PostgreSQL Flexible Server**: managed relational database with HA/backups options, private networking support.
- **Azure Application Gateway WAF v2**: internet-facing reverse proxy + OWASP WAF policies, TLS termination, path routing (if needed later).
- **Azure Key Vault**: secret storage (DB credentials, app secrets) and runtime secret references from App Service.
- **Azure Virtual Network** with dedicated subnets: network segmentation for App Gateway, App Service integration, and DB delegated subnet.
- **Azure Monitor (Log Analytics + Application Insights)**: centralized logs, metrics, traces, and diagnostics.

## 2) Traffic flow

1. Client sends HTTPS request to **Application Gateway public endpoint**.
2. **WAF policy** inspects and filters traffic.
3. Application Gateway forwards allowed traffic to **App Service** backend.
4. App Service retrieves secrets using **Managed Identity** and **Key Vault references**.
5. App connects to **PostgreSQL Flexible Server** over private network path via VNet integration.
6. App, gateway, and platform diagnostics stream to **Log Analytics/Application Insights**.

## 3) Network boundaries

- Single VNet with segmented subnets:
  - `agw` subnet for Application Gateway
  - `app-integration` subnet for App Service VNet integration (outbound)
  - `db` delegated subnet for PostgreSQL Flexible Server private access
- NSGs are applied to subnets to restrict unnecessary east-west traffic.
- App Service direct public access is restricted by access rules (allow only App Gateway ingress path).
- Database is private (no public internet DB endpoint exposure in intended production mode).

## 4) Identity model

- **System-assigned Managed Identity** on App Service.
- Managed identity granted least-privilege read access to Key Vault secrets.
- CI/CD uses **GitHub Actions OIDC federated identity** (no long-lived Azure client secret).
- Terraform deploy identity gets scoped RBAC permissions (prefer resource-group scope for least privilege).

## 5) Key security controls

- WAF enabled with OWASP managed rules.
- TLS enforced end-to-end where possible.
- Key Vault for sensitive values; avoid plaintext secrets in code/pipeline.
- App Service access restrictions to reduce direct origin exposure.
- Private DB subnet and DNS zone for private name resolution.
- Diagnostic logs and metrics enabled for App Gateway and App Service.
- Basic security gates in CI (format/validate/plan; optional policy scan extension point).

## 6) Scalability approach

- App Service Plan supports scale-up/scale-out (manual or autoscale).
- Application Gateway v2 supports autoscaling capacity.
- PostgreSQL Flexible Server can scale compute/storage independently.
- Stateless app design expected; horizontal scaling enabled by platform.

## 7) What is intentionally missing (time-box tradeoffs)

- Full private-only App Service ingress with private endpoints and private App Gateway-to-origin path hardening.
- End-to-end TLS with custom domains/certs from trusted CA and automated rotation.
- Blue/green or canary release strategy.
- Policy-as-code and advanced security scanning in pipeline (e.g., Checkov, tfsec, SAST/DAST).
- Multi-region DR topology and automated failover tests.

## 8) What I would do next

1. Enforce private ingress architecture fully (private endpoints + no direct public app endpoint).
2. Introduce separate environments (`dev`, `staging`, `prod`) with approval gates and drift detection.
3. Add autoscale rules, health probes, synthetic monitoring, and SLO dashboards.
4. Add vulnerability/dependency scanning and IaC policy checks as blocking gates.
5. Rotate bootstrap DB secret by moving to passwordless or managed identity-based DB auth where supported.
