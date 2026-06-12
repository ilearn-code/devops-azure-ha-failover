# Azure High-Availability Failover Training Project

This project demonstrates DNS-based failover using Azure Traffic Manager, Front Door, and Application Gateway.

## Architecture Overview

```
[User Browser]
    |
    | DNS lookup: www.myapp.com
    |
    v
[DNS Server] --CNAME--> [Azure Traffic Manager]
    |
    | Returns IP based on priority + health
    |
    v
[Client connects to one of these based on priority:]
    |
    +---> Priority 1: [Azure Front Door] ---> [Backend: App Services]
    |
    +---> Priority 2: [App Gateway West] ---> [Backend: App Service West]
    |
    +---> Priority 3: [App Gateway East] ---> [Backend: App Service East]
```

## Project Structure

```
.
├── terraform/              # Infrastructure as Code
│   ├── providers.tf       # Terraform & Azure provider config
│   ├── variables.tf       # Input variables
│   ├── main.tf           # Main resource definitions
│   ├── outputs.tf        # Output values
│   ├── afd.tf            # Azure Front Door (to be created)
│   ├── aag.tf            # Application Gateways (to be created)
│   ├── atm.tf            # Traffic Manager (to be created)
│   └── modules/          # Reusable modules (future)
├── scripts/              # Helper scripts
└── project-prompt.md     # Training guide
```

## Quick Start

### Prerequisites

1. Azure CLI installed and logged in:
   ```bash
   az login
   az account show
   ```

2. Terraform installed (1.0+):
   ```bash
   terraform version
   ```

### Phase 1: Deploy Backend Resources (Current Step)

```bash
cd terraform

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy the backend App Services
terraform apply

# View outputs
terraform output
```

This creates:
- 2 Resource Groups (West, East, Global)
- 2 App Service Plans (West, East)
- 2 App Services as dummy backends

### Next Steps

We'll add in phases:
1. ✅ Backend App Services (dummy apps)
2. ⏳ Azure Front Door with routing
3. ⏳ Application Gateways (West + East) with WAF
4. ⏳ Traffic Manager with priority routing
5. ⏳ Testing scripts

## Learning Objectives

- Understand DNS-based failover with Traffic Manager
- Configure priority routing across multiple endpoints
- Mirror routing rules between AFD and AAG
- Implement WAF policies
- Test failover scenarios
- Design IaC modules for route parity

## Environments

- `ha-ua` - User Acceptance (POC environment)
- `ha-prod` - Production (ha)
- `enp` - ha Non-Prod
- `ha-prod` - ha Production
