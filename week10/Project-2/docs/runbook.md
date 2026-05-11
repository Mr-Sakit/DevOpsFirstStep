# SecureFlow Docs Runbook

## Provision

1. Create a remote state storage account and container.
2. Copy `infra/terraform/terraform.tfvars.example` to a local `terraform.tfvars`.
3. Run:

```bash
cd infra/terraform
terraform init \
  -backend-config="resource_group_name=group1_final" \
  -backend-config="storage_account_name=tfstategrp1sf26640" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=secureflow-dev.tfstate"
terraform plan -out=tfplan
terraform apply tfplan
```

## Configure

Install Ansible collections and apply roles from the ops VM `group1-final` (`10.2.0.4`), which can reach the private VMSS instances.

```bash
ansible-galaxy collection install -r config/ansible/requirements.yml
ANSIBLE_HOST_KEY_CHECKING=False \
ansible-playbook config/ansible/site.yml \
  -i config/ansible/inventories/prod/hosts.ini \
  --private-key ~/.ssh/group1-final_key.pem
```

## Deploy

Frontend and backend are independent deployables:

```bash
cd apps/frontend
npm ci
npm run build
tar -czf dist.tar.gz -C dist .

cd ../backend
mvn -B clean verify
```

GitHub Actions automates this through `.github/workflows/frontend.yml` and `.github/workflows/backend.yml`.

## Validate

```bash
curl -k https://e-document.tech/
```

Expected proof:

- Homepage loads only through the Application Gateway IP or domain.
- App Gateway public IP is `135.116.238.100`.
- Frontend VMSS private IP is `10.2.2.4`.
- Backend VMSS private IP is `10.2.3.4`.
- `POST /api/documents` creates a row in the database.
- `GET /api/documents` returns the new row.
- VMs have no public IP resources attached.
- SQL server has `public_network_access_enabled = false`.
- SQL resolves through `privatelink.database.windows.net`.
- App Gateway backend health shows frontend and backend as healthy.

## Kusto Queries

Application Gateway access:

```kusto
AzureDiagnostics
| where ResourceType == "APPLICATIONGATEWAYS"
| where Category == "ApplicationGatewayAccessLog"
| project TimeGenerated, clientIP_s, requestUri_s, httpStatus_d
| order by TimeGenerated desc
```

WAF blocks:

```kusto
AzureDiagnostics
| where Category == "ApplicationGatewayFirewallLog"
| summarize Blocks=count() by ruleId_s, Message
| order by Blocks desc
```

API failures:

```kusto
requests
| where cloud_RoleName contains "secureflow"
| summarize failures=countif(success == false), total=count() by bin(timestamp, 5m)
```


## Verified Result

- Terraform created the WAF v2 Application Gateway, VMSS tiers, SQL private endpoint, Log Analytics, Application Insights, autoscale settings, and alerts in `group1_final`.
- Ansible completed with zero failures against frontend, backend, and the ops-hosted SonarQube service.
- Public gateway checks from the ops VM returned 200 for `/` and `/api/health`.
- Authenticated gateway test uploaded `secureflow-test-contract.txt` and read it back from `/api/documents` for `automission@company.com`.

## Cost Monitoring

Terraform creates:

- `budget-secureflow-dev-monthly`: `$20` monthly budget scoped to `group1_final`.
- 50% and 80% actual-cost alerts.
- 100% forecasted-cost alert.
- `cost-anomaly-sf-dev`: Cost Management anomaly email alert.
- `cost-view-secureflow-dev-daily`: saved Cost Management view for month-to-date daily cost by resource type.

Use [cost-monitoring-dashboard.md](cost-monitoring-dashboard.md) for the professor demo steps and CLI validation commands.

## Compliance Mode

Terraform creates:

- `initiative-secureflow-dev-cis-foundation`: custom CIS-style Azure Policy initiative.
- `pa-secureflow-dev-cis`: resource-group policy assignment for `group1_final`.
- Audit checks for SQL public network access, compute public NIC exposure, and Application Gateway WAF v2.
- Compliance Mode UI score: `100% Compliant`.

Use [compliance-mode.md](compliance-mode.md) for the Azure Policy, CIS benchmark, and Security Center demo steps.

## Backup and Disaster Recovery

Terraform creates:

- `rsv-secureflow-dev-dr`: Recovery Services Vault with soft delete and geo-redundant storage.
- `bkpol-secureflow-dev-vm-daily`: daily VM backup policy.
- SQL short-term retention for `14` day point-in-time restore.
- SQL long-term retention for weekly, monthly, and yearly recovery evidence.
- Azure recovery evidence for Recovery Services Vault, SQL PITR, and restore drill readiness.

Use [backup-disaster-recovery.md](backup-disaster-recovery.md) for the Recovery Services Vault, SQL PITR, and deleted-record restore demo steps.

## AI-Powered Log Analysis

Terraform creates:

- `alert-secureflow-dev-ai-api-traffic-spike`: scheduled Kusto alert for suspicious `/api/*` traffic concentration.
- `alert-secureflow-dev-ai-failed-login-burst`: scheduled Kusto alert for repeated failed login attempts.
- AI Security Summary evidence from Log Analytics alert logic.

Use [ai-powered-log-analysis.md](ai-powered-log-analysis.md) for Kusto queries, alert validation, and the security operations demo script.

## Threat Intelligence Feed Integration

Implemented evidence:

- `waf-secureflow-dev`: Application Gateway WAF policy.
- `BlockThreatIntelIPs`: WAF custom rule that blocks RemoteAddr matches from the threat feed.
- `Threat Intelligence WAF Refresh`: scheduled/manual GitHub Actions workflow that fetches EmergingThreats indicators and refreshes the WAF rule.

Use [threat-intelligence-feed.md](threat-intelligence-feed.md) for Azure Portal screenshots, CLI validation, and the SOC automation demo script.

## Dynamic Application Security Testing

Implemented evidence:

- `DAST`: GitHub Actions workflow.
- `secureflow-ops`: self-hosted runner on the Azure ops VM in `group1_final`.
- `secureflow-zap-dast-report`: uploaded OWASP ZAP report artifact.
- Target: Application Gateway URL, with private frontend/backend/SQL tiers remaining unreachable directly.

Use [dast-security-testing.md](dast-security-testing.md) for workflow screenshots, report validation, and the security testing demo script.

## Load Balancing

Implemented evidence:

- `agw-secureflow-dev`: public Application Gateway WAF v2 load balancer.
- `ilb-secureflow-dev-frontend`: private frontend internal load balancer.
- `ilb-secureflow-dev-backend`: private backend internal load balancer.
- VMSS backend pools and health probes for frontend `/health` and backend `/api/health`.

Use [load-balancing.md](load-balancing.md) for Azure Portal screenshots, CLI validation, and the scalability demo script.

## Layer 7 Flood Protection

Implemented evidence:

- `waf-secureflow-dev`: Application Gateway WAF policy in prevention mode.
- `RateLimitLayer7Flood`: WAF rate-limit custom rule for client request bursts.
- `BlockThreatIntelIPs`: WAF custom rule for known malicious IP indicators.

Use [layer-7-flood-protection.md](layer-7-flood-protection.md) for Azure Portal screenshots, safe burst testing, and Log Analytics validation.

## Key Vault and VMSS Access

Terraform creates:

- A private Azure Key Vault with RBAC authorization.
- Key Vault private endpoint in `snet-data`.
- Private DNS zone `privatelink.vaultcore.azure.net`.
- Key Vault secret access for frontend and backend VMSS managed identities.
