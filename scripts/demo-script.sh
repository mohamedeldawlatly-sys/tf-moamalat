#!/bin/bash
# IBM Terraform & Vault Workshop - Demo Script
# Presenter: Mohamed Ramadan Issa
# Target: IBM Champions Saudi Arabia
# Duration: 10 minutes

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_step() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')] $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️ $1${NC}"
}

# Banner
echo -e "${PURPLE}"
cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║        🚀 IBM Terraform & Vault Workshop Demo 🚀            ║
║                                                              ║
║        👨‍💻 Presenter: Mohamed Ramadan Issa                   ║
║        🎪 Target: IBM Champions Saudi Arabia                ║
║        ⏱️ Duration: 10 minutes                               ║
║        🌍 Region: eu-west-1                                  ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check prerequisites
print_step "Checking prerequisites..."

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI not found. Please install it first."
    exit 1
fi

# Check Terraform
if ! command -v terraform &> /dev/null; then
    print_error "Terraform not found. Please install it first."
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    print_error "AWS credentials not configured. Run 'aws configure' first."
    exit 1
fi

print_success "All prerequisites met!"

# Get AWS account info
AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=$(aws configure get region || echo "eu-west-1")
print_info "AWS Account: $AWS_ACCOUNT"
print_info "AWS Region: $AWS_REGION"

# Demo options
echo ""
echo -e "${YELLOW}Demo Options:${NC}"
echo "1. 🚀 Full Demo (Plan + Apply)"
echo "2. 📋 Plan Only"
echo "3. 🧹 Destroy Infrastructure"
echo "4. 🔍 Show Current Resources"
echo "5. 🔐 Vault Demo (if infrastructure exists)"
echo ""

read -p "Choose option (1-5): " OPTION

case $OPTION in
    1)
        print_step "Starting full demo deployment..."
        
        # Initialize Terraform
        print_step "Initializing Terraform..."
        terraform init
        print_success "Terraform initialized!"
        
        # Validate configuration
        print_step "Validating Terraform configuration..."
        terraform validate
        print_success "Configuration is valid!"
        
        # Plan deployment
        print_step "Creating deployment plan..."
        terraform plan -out=tfplan
        print_success "Plan created successfully!"
        
        # Ask for confirmation
        echo ""
        print_warning "This will create AWS resources that may incur charges."
        read -p "Continue with deployment? (y/N): " CONFIRM
        
        if [[ $CONFIRM =~ ^[Yy]$ ]]; then
            # Apply plan
            print_step "Deploying infrastructure..."
            terraform apply tfplan
            print_success "Infrastructure deployed successfully!"
            
            # Get outputs
            print_step "Getting deployment outputs..."
            echo ""
            echo -e "${GREEN}🎉 Deployment Complete!${NC}"
            echo ""
            echo -e "${CYAN}📱 Web Application:${NC} $(terraform output -raw webapp_url)"
            echo -e "${CYAN}🔐 Vault UI:${NC} $(terraform output -raw vault_url)"
            echo ""
            echo -e "${YELLOW}🔑 Vault Access Commands:${NC}"
            echo "export VAULT_ADDR=$(terraform output -raw vault_url)"
            echo "export VAULT_TOKEN=$(terraform output -raw vault_root_token)"
            echo "vault status"
            echo ""
            echo -e "${YELLOW}📊 Demo Commands:${NC}"
            echo "vault kv get secret/database"
            echo "vault kv get secret/app"
            echo ""
            print_warning "Remember to run 'terraform destroy' after the demo!"
        else
            print_info "Deployment cancelled."
        fi
        ;;
        
    2)
        print_step "Creating deployment plan..."
        terraform init
        terraform validate
        terraform plan
        print_success "Plan completed!"
        ;;
        
    3)
        print_step "Destroying infrastructure..."
        print_warning "This will destroy all resources!"
        read -p "Are you sure? (y/N): " CONFIRM
        
        if [[ $CONFIRM =~ ^[Yy]$ ]]; then
            terraform destroy -auto-approve
            print_success "Infrastructure destroyed!"
        else
            print_info "Destruction cancelled."
        fi
        ;;
        
    4)
        print_step "Checking current AWS resources..."
        
        echo -e "${CYAN}EC2 Instances:${NC}"
        aws ec2 describe-instances --region $AWS_REGION \
            --query 'Reservations[*].Instances[*].[InstanceId,State.Name,Tags[?Key==`Name`].Value|[0]]' \
            --output table || echo "No instances found"
        
        echo -e "${CYAN}RDS Instances:${NC}"
        aws rds describe-db-instances --region $AWS_REGION \
            --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus,Engine]' \
            --output table || echo "No RDS instances found"
        
        echo -e "${CYAN}Load Balancers:${NC}"
        aws elbv2 describe-load-balancers --region $AWS_REGION \
            --query 'LoadBalancers[*].[LoadBalancerName,State.Code,DNSName]' \
            --output table || echo "No load balancers found"
        ;;
        
    5)
        print_step "Running Vault demo..."
        
        if terraform output webapp_url &> /dev/null; then
            VAULT_URL=$(terraform output -raw vault_url)
            VAULT_TOKEN=$(terraform output -raw vault_root_token)
            
            print_info "Vault URL: $VAULT_URL"
            
            export VAULT_ADDR=$VAULT_URL
            export VAULT_TOKEN=$VAULT_TOKEN
            
            print_step "Checking Vault status..."
            if command -v vault &> /dev/null; then
                vault status
                
                print_step "Listing secrets..."
                vault kv list secret/
                
                print_step "Getting database credentials..."
                vault kv get secret/database
                
                print_step "Getting application secrets..."
                vault kv get secret/app
            else
                print_warning "Vault CLI not installed. Install it to run Vault commands."
                print_info "You can still access Vault UI at: $VAULT_URL"
                print_info "Root token: $VAULT_TOKEN"
            fi
        else
            print_error "No infrastructure found. Deploy first with option 1."
        fi
        ;;
        
    *)
        print_error "Invalid option selected."
        exit 1
        ;;
esac

echo ""
print_step "Demo script completed!"
echo -e "${PURPLE}Thank you for attending the IBM Terraform & Vault Workshop!${NC}"
echo -e "${CYAN}Presenter: Mohamed Ramadan Issa${NC}"
echo -e "${CYAN}Target: IBM Champions Saudi Arabia${NC}"
