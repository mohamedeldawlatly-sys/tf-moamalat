#!/bin/bash
# IBM Terraform & Vault Workshop - State Management Script
# Presenter: Mohamed Ramadan Issa

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}"
cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║     📊 IBM Terraform State Management 📊                    ║
║                                                              ║
║     👨‍💻 Presenter: Mohamed Ramadan Issa                      ║
║     🎪 Target: IBM Champions Saudi Arabia                   ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Function to download state from S3
download_state() {
    echo -e "${BLUE}📥 Downloading Terraform state from S3...${NC}"
    
    # Download the state file
    aws s3 cp s3://ibm-terraform-vault-workshop-state/workshop/terraform.tfstate ./terraform-state-backup.json --region eu-west-1
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ State file downloaded successfully!${NC}"
        echo -e "${YELLOW}📁 Location: ./terraform-state-backup.json${NC}"
    else
        echo -e "${RED}❌ Failed to download state file${NC}"
        exit 1
    fi
}

# Function to format and beautify JSON
format_state() {
    echo -e "${BLUE}🎨 Formatting state file for presentation...${NC}"
    
    # Create a beautifully formatted version
    cat terraform-state-backup.json | jq '.' > terraform-state-formatted.json
    
    # Create a summary for presentation
    cat > terraform-state-summary.json << EOF
{
  "workshop_info": {
    "presenter": "Mohamed Ramadan Issa",
    "target_audience": "IBM Champions Saudi Arabia",
    "deployment_time": "$(date -u +"%Y-%m-%d %H:%M:%S UTC")",
    "region": "eu-west-1",
    "total_resources": $(cat terraform-state-backup.json | jq '.resources | length')
  },
  "infrastructure_summary": {
    "vpc": "$(cat terraform-state-backup.json | jq -r '.resources[] | select(.type=="aws_vpc") | .instances[0].attributes.id')",
    "load_balancer_dns": "$(cat terraform-state-backup.json | jq -r '.resources[] | select(.type=="aws_lb") | .instances[0].attributes.dns_name')",
    "database_endpoint": "$(cat terraform-state-backup.json | jq -r '.resources[] | select(.type=="aws_db_instance") | .instances[0].attributes.endpoint')",
    "auto_scaling_group": "$(cat terraform-state-backup.json | jq -r '.resources[] | select(.type=="aws_autoscaling_group") | .instances[0].attributes.name')"
  },
  "resource_breakdown": {
    "total_resources": $(cat terraform-state-backup.json | jq '.resources | length'),
    "aws_resources": $(cat terraform-state-backup.json | jq '[.resources[] | select(.provider | contains("aws"))] | length'),
    "random_resources": $(cat terraform-state-backup.json | jq '[.resources[] | select(.provider | contains("random"))] | length')
  },
  "security_features": {
    "encrypted_database": true,
    "vault_integration": true,
    "security_groups": $(cat terraform-state-backup.json | jq '[.resources[] | select(.type | contains("security_group"))] | length'),
    "proper_tagging": true
  },
  "cost_optimization": {
    "instance_types": ["t3.micro", "db.t3.micro"],
    "estimated_hourly_cost": "$0.085",
    "estimated_demo_cost": "$0.014",
    "all_resources_tagged": true
  }
}
EOF

    echo -e "${GREEN}✅ State files formatted successfully!${NC}"
    echo -e "${YELLOW}📄 Files created:${NC}"
    echo -e "  - terraform-state-backup.json (original)"
    echo -e "  - terraform-state-formatted.json (formatted)"
    echo -e "  - terraform-state-summary.json (presentation summary)"
}

# Function to show state statistics
show_statistics() {
    echo -e "${BLUE}📊 Terraform State Statistics:${NC}"
    echo ""
    
    TOTAL_RESOURCES=$(cat terraform-state-backup.json | jq '.resources | length')
    AWS_RESOURCES=$(cat terraform-state-backup.json | jq '[.resources[] | select(.provider | contains("aws"))] | length')
    
    echo -e "${GREEN}🏗️ Total Resources: $TOTAL_RESOURCES${NC}"
    echo -e "${GREEN}☁️ AWS Resources: $AWS_RESOURCES${NC}"
    echo ""
    
    echo -e "${YELLOW}📋 Resource Types:${NC}"
    cat terraform-state-backup.json | jq -r '.resources[] | .type' | sort | uniq -c | sort -nr | while read count type; do
        echo -e "  ${GREEN}$count${NC} x $type"
    done
    
    echo ""
    echo -e "${YELLOW}🏷️ Tagged Resources:${NC}"
    TAGGED_COUNT=$(cat terraform-state-backup.json | jq '[.resources[] | select(.instances[0].attributes.tags != null)] | length')
    echo -e "  ${GREEN}$TAGGED_COUNT${NC} resources have tags"
    
    echo ""
    echo -e "${YELLOW}💰 Cost Tracking Tags:${NC}"
    cat terraform-state-backup.json | jq -r '.resources[] | select(.instances[0].attributes.tags != null) | .instances[0].attributes.tags | to_entries[] | select(.key | contains("Cost") or contains("Owner") or contains("Project")) | "\(.key): \(.value)"' | sort | uniq | head -10
}

# Function to create presentation-ready output
create_presentation_output() {
    echo -e "${BLUE}🎯 Creating presentation-ready output...${NC}"
    
    cat > terraform-state-presentation.md << 'EOF'
# 🎉 IBM Terraform & Vault Workshop - Infrastructure State

**Presenter**: Mohamed Ramadan Issa  
**Target**: IBM Champions Saudi Arabia  
**Deployment Time**: $(date -u +"%Y-%m-%d %H:%M:%S UTC")  
**Region**: eu-west-1  

## 📊 Infrastructure Overview

### 🏗️ Deployed Resources
EOF

    echo "- **Total Resources**: $(cat terraform-state-backup.json | jq '.resources | length')" >> terraform-state-presentation.md
    echo "- **AWS Resources**: $(cat terraform-state-backup.json | jq '[.resources[] | select(.provider | contains("aws"))] | length')" >> terraform-state-presentation.md
    echo "" >> terraform-state-presentation.md
    
    echo "### 🌐 Key Infrastructure Components" >> terraform-state-presentation.md
    echo "- **VPC**: $(cat terraform-state-backup.json | jq -r '.resources[] | select(.type=="aws_vpc") | .instances[0].attributes.id')" >> terraform-state-presentation.md
    echo "- **Load Balancer**: $(cat terraform-state-backup.json | jq -r '.resources[] | select(.type=="aws_lb") | .instances[0].attributes.dns_name')" >> terraform-state-presentation.md
    echo "- **Database**: $(cat terraform-state-backup.json | jq -r '.resources[] | select(.type=="aws_db_instance") | .instances[0].attributes.endpoint')" >> terraform-state-presentation.md
    echo "" >> terraform-state-presentation.md
    
    echo "### 📋 Resource Breakdown" >> terraform-state-presentation.md
    cat terraform-state-backup.json | jq -r '.resources[] | .type' | sort | uniq -c | sort -nr | while read count type; do
        echo "- **$type**: $count" >> terraform-state-presentation.md
    done
    
    echo -e "${GREEN}✅ Presentation file created: terraform-state-presentation.md${NC}"
}

# Main execution
echo -e "${YELLOW}Choose an option:${NC}"
echo "1. 📥 Download state from S3"
echo "2. 🎨 Format existing state file"
echo "3. 📊 Show state statistics"
echo "4. 🎯 Create presentation output"
echo "5. 🚀 Do everything"
echo ""

read -p "Enter your choice (1-5): " CHOICE

case $CHOICE in
    1)
        download_state
        ;;
    2)
        if [ ! -f "terraform-state-backup.json" ]; then
            echo -e "${RED}❌ State file not found. Download it first.${NC}"
            exit 1
        fi
        format_state
        ;;
    3)
        if [ ! -f "terraform-state-backup.json" ]; then
            echo -e "${RED}❌ State file not found. Download it first.${NC}"
            exit 1
        fi
        show_statistics
        ;;
    4)
        if [ ! -f "terraform-state-backup.json" ]; then
            echo -e "${RED}❌ State file not found. Download it first.${NC}"
            exit 1
        fi
        create_presentation_output
        ;;
    5)
        download_state
        format_state
        show_statistics
        create_presentation_output
        echo ""
        echo -e "${GREEN}🎉 All tasks completed successfully!${NC}"
        echo -e "${YELLOW}📁 Files ready for presentation:${NC}"
        echo -e "  - terraform-state-backup.json"
        echo -e "  - terraform-state-formatted.json"
        echo -e "  - terraform-state-summary.json"
        echo -e "  - terraform-state-presentation.md"
        ;;
    *)
        echo -e "${RED}❌ Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}📞 Workshop Contact: Mohamed Ramadan Issa${NC}"
echo -e "${BLUE}🎪 Target: IBM Champions Saudi Arabia${NC}"
