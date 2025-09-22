#!/bin/bash
# IBM Terraform & Vault Workshop - Quick Setup Script
# Presenter: Mohamed Ramadan Issa

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}"
cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║     🛠️ IBM Terraform & Vault Workshop Setup 🛠️              ║
║                                                              ║
║     👨‍💻 Presenter: Mohamed Ramadan Issa                      ║
║     🎪 Target: IBM Champions Saudi Arabia                   ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Detect OS
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    CYGWIN*)    MACHINE=Cygwin;;
    MINGW*)     MACHINE=MinGw;;
    *)          MACHINE="UNKNOWN:${OS}"
esac

echo -e "${BLUE}Detected OS: $MACHINE${NC}"

# Function to install on macOS
install_macos() {
    echo -e "${YELLOW}Installing tools for macOS...${NC}"
    
    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}Installing Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    # Install AWS CLI
    if ! command -v aws &> /dev/null; then
        echo -e "${YELLOW}Installing AWS CLI...${NC}"
        brew install awscli
    fi
    
    # Install Terraform
    if ! command -v terraform &> /dev/null; then
        echo -e "${YELLOW}Installing Terraform...${NC}"
        brew tap hashicorp/tap
        brew install hashicorp/tap/terraform
    fi
    
    # Install Vault
    if ! command -v vault &> /dev/null; then
        echo -e "${YELLOW}Installing Vault...${NC}"
        brew install hashicorp/tap/vault
    fi
}

# Function to install on Linux
install_linux() {
    echo -e "${YELLOW}Installing tools for Linux...${NC}"
    
    # Update package manager
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        
        # Install AWS CLI
        if ! command -v aws &> /dev/null; then
            echo -e "${YELLOW}Installing AWS CLI...${NC}"
            curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
            unzip awscliv2.zip
            sudo ./aws/install
            rm -rf aws awscliv2.zip
        fi
        
        # Install required packages
        sudo apt-get install -y wget unzip curl
        
    elif command -v yum &> /dev/null; then
        sudo yum update -y
        
        # Install AWS CLI
        if ! command -v aws &> /dev/null; then
            echo -e "${YELLOW}Installing AWS CLI...${NC}"
            curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
            unzip awscliv2.zip
            sudo ./aws/install
            rm -rf aws awscliv2.zip
        fi
        
        # Install required packages
        sudo yum install -y wget unzip curl
    fi
    
    # Install Terraform
    if ! command -v terraform &> /dev/null; then
        echo -e "${YELLOW}Installing Terraform...${NC}"
        wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
        unzip terraform_1.6.0_linux_amd64.zip
        sudo mv terraform /usr/local/bin/
        rm terraform_1.6.0_linux_amd64.zip
    fi
    
    # Install Vault
    if ! command -v vault &> /dev/null; then
        echo -e "${YELLOW}Installing Vault...${NC}"
        wget https://releases.hashicorp.com/vault/1.15.0/vault_1.15.0_linux_amd64.zip
        unzip vault_1.15.0_linux_amd64.zip
        sudo mv vault /usr/local/bin/
        rm vault_1.15.0_linux_amd64.zip
    fi
}

# Install based on OS
case $MACHINE in
    Mac)
        install_macos
        ;;
    Linux)
        install_linux
        ;;
    *)
        echo -e "${RED}Unsupported OS: $MACHINE${NC}"
        echo -e "${YELLOW}Please install the following tools manually:${NC}"
        echo "- AWS CLI: https://aws.amazon.com/cli/"
        echo "- Terraform: https://www.terraform.io/downloads"
        echo "- Vault: https://www.vaultproject.io/downloads"
        exit 1
        ;;
esac

# Verify installations
echo -e "${BLUE}Verifying installations...${NC}"

if command -v aws &> /dev/null; then
    echo -e "${GREEN}✅ AWS CLI: $(aws --version)${NC}"
else
    echo -e "${RED}❌ AWS CLI not found${NC}"
fi

if command -v terraform &> /dev/null; then
    echo -e "${GREEN}✅ Terraform: $(terraform --version | head -n1)${NC}"
else
    echo -e "${RED}❌ Terraform not found${NC}"
fi

if command -v vault &> /dev/null; then
    echo -e "${GREEN}✅ Vault: $(vault --version)${NC}"
else
    echo -e "${RED}❌ Vault not found${NC}"
fi

# Configure AWS (if not already configured)
echo -e "${BLUE}Checking AWS configuration...${NC}"
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${YELLOW}AWS credentials not configured.${NC}"
    echo -e "${YELLOW}Please run: aws configure${NC}"
    echo ""
    echo "You'll need:"
    echo "- AWS Access Key ID"
    echo "- AWS Secret Access Key"
    echo "- Default region: eu-west-1"
    echo "- Default output format: json"
else
    AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
    AWS_REGION=$(aws configure get region || echo "not set")
    echo -e "${GREEN}✅ AWS configured for account: $AWS_ACCOUNT${NC}"
    echo -e "${GREEN}✅ Default region: $AWS_REGION${NC}"
    
    if [ "$AWS_REGION" != "eu-west-1" ]; then
        echo -e "${YELLOW}⚠️ Consider setting region to eu-west-1 for this workshop${NC}"
    fi
fi

# Create terraform.tfvars if it doesn't exist
if [ ! -f "terraform.tfvars" ]; then
    echo -e "${BLUE}Creating terraform.tfvars file...${NC}"
    cp terraform.tfvars.example terraform.tfvars
    echo -e "${GREEN}✅ Created terraform.tfvars from example${NC}"
    echo -e "${YELLOW}You can customize terraform.tfvars if needed${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Setup completed successfully!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Review terraform.tfvars file"
echo "2. Run: ./scripts/demo-script.sh"
echo "3. Or manually run: terraform init && terraform plan"
echo ""
echo -e "${YELLOW}For GitHub Actions:${NC}"
echo "1. Fork this repository"
echo "2. Set repository secrets:"
echo "   - AWS_ACCESS_KEY_ID"
echo "   - AWS_SECRET_ACCESS_KEY"
echo "   - AWS_REGION (eu-west-1)"
echo "3. Push to main branch or trigger workflow manually"
echo ""
echo -e "${RED}⚠️ Remember to run 'terraform destroy' after the workshop!${NC}"
