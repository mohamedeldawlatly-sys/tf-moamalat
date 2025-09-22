# IBM Terraform & Vault Workshop

**Presenter**: Mohamed Ramadan Issa  
**Target Audience**: IBM Champions  
**Duration**: 10 minutes demo + hands-on  
**Region**: eu-west-1 (Ireland)

## Workshop Overview

This workshop demonstrates the power of **Infrastructure as Code** with Terraform and **Secret Management** with HashiCorp Vault through a live 3-tier web application deployment.

### What You'll Learn:
- Deploy secure infrastructure with Terraform
- Manage secrets with HashiCorp Vault
- Implement proper resource tagging
- Use GitHub Actions for CI/CD
- Best practices for AWS security

### What Gets Deployed:
- **Web Tier**: Application Load Balancer + Auto Scaling Group
- **App Tier**: EC2 instances with custom web application
- **Data Tier**: RDS MySQL database with encrypted storage
- **Security**: Vault server for secret management
- **Governance**: Comprehensive resource tagging

## Prerequisites

### 1. AWS Account Setup
```bash
# Install AWS CLI (if not installed)
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure AWS credentials
aws configure
# Enter your:
# - AWS Access Key ID
# - AWS Secret Access Key  
# - Default region: eu-west-1
# - Default output format: json
```

### 2. Required Tools
```bash
# Install Terraform
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Install Vault CLI
wget https://releases.hashicorp.com/vault/1.15.0/vault_1.15.0_linux_amd64.zip
unzip vault_1.15.0_linux_amd64.zip
sudo mv vault /usr/local/bin/

# Verify installations
terraform --version
vault --version
aws --version
```

### 3. Clone Repository
```bash
git clone https://github.com/your-username/ibm-terraform-vault-workshop.git
cd ibm-terraform-vault-workshop
```

## Quick Start (5-minute deployment)

### Option 1: Manual Deployment
```bash
# 1. Initialize Terraform
terraform init

# 2. Plan deployment (review resources)
terraform plan

# 3. Deploy infrastructure
terraform apply -auto-approve

# 4. Get application URL
terraform output webapp_url
```

### Option 2: GitHub Actions (Automated)
1. Fork this repository
2. Set GitHub Secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION` (eu-west-1)
3. Push to main branch or manually trigger workflow
4. Check Actions tab for deployment progress

## Vault Integration

### Accessing Vault
```bash
# Get Vault details after deployment
terraform output vault_url
terraform output vault_root_token

# Set Vault environment
export VAULT_ADDR=$(terraform output -raw vault_url)
export VAULT_TOKEN=$(terraform output -raw vault_root_token)

# Verify Vault connection
vault status
```

### Retrieving Database Credentials
```bash
# Application automatically retrieves DB credentials from Vault
# Manual retrieval for demonstration:
vault kv get -field=username secret/database
vault kv get -field=password secret/database
```

### How Application Uses Vault
The web application demonstrates Vault integration by:
1. **Authentication**: Uses AWS IAM role for Vault authentication
2. **Secret Retrieval**: Fetches database credentials from Vault KV store
3. **Dynamic Display**: Shows retrieved credentials on the web page (demo only)

## Resource Tagging Strategy

All resources are tagged with:
```hcl
tags = {
  Environment   = "workshop"
  Project      = "ibm-terraform-vault-demo"
  Owner        = "mohamed-ramadan-issa"
  CostCenter   = "ibm-champions"
  Workshop     = "terraform-vault-demo"
  CreatedBy    = "terraform"
  Region       = "eu-west-1"
}
```

## Application Features

The deployed web application displays:
- **Welcome Message**: "Welcome IBM Champions in Saudi Arabia!"
- **Logos**: IBM, Terraform, Vault, and Workshop branding
- 👨‍💻 **Presenter**: Mohamed Ramadan Issa
- **Live Vault Demo**: Real-time secret retrieval
- **Infrastructure Info**: Deployed resources overview

## Cleanup

**Important**: Always cleanup resources to avoid charges!

```bash
# Destroy all resources
terraform destroy -auto-approve

# Verify cleanup in AWS console
aws ec2 describe-instances --region eu-west-1
aws rds describe-db-instances --region eu-west-1
```

## Demo Script (10 minutes)

### Minutes 1-2: Problem Statement
- Show manual infrastructure provisioning challenges
- Highlight security risks of hardcoded secrets

### Minutes 3-7: Live Deployment
```bash
# Start deployment
terraform apply -auto-approve

# While deploying, explain:
# - Infrastructure as Code benefits
# - Vault secret management
# - Resource tagging importance
# - GitHub Actions automation
```

### Minutes 8-10: Results & Benefits
- Access deployed application
- Demonstrate Vault secret retrieval
- Show AWS console with tagged resources
- Summarize key benefits

## Troubleshooting

### Common Issues:

1. **AWS Credentials**:
   ```bash
   aws sts get-caller-identity  # Verify credentials
   ```

2. **Region Issues**:
   ```bash
   export AWS_DEFAULT_REGION=eu-west-1
   ```

3. **Terraform State**:
   ```bash
   terraform refresh  # Sync state with AWS
   ```

## Contact

**Presenter**: Mohamed Ramadan Issa  
**Workshop**: IBM Champions Terraform & Vault Demo  
**Region**: Saudi Arabia

---

**Important**: This is a demo environment. Always follow your organization's security policies for production deployments.

**Cost Warning**: Remember to run `terraform destroy` after the workshop to avoid AWS charges!
# ibm-terraform-vault-champions-workshop
