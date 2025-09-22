# IBM Terraform & Vault Workshop - Destruction Guide

**IMPORTANT**: Always destroy resources after the workshop to avoid AWS charges!

**Presenter**: Mohamed Ramadan Issa  
**Target**: IBM Champions Saudi Arabia  

## 🚨 Quick Destruction (Recommended)

### Option 1: Terraform Destroy
```bash
cd /path/to/ibm-terraform-vault-workshop
terraform destroy -auto-approve
```

### Option 2: Using Demo Script
```bash
./scripts/demo-script.sh
# Choose option 3: "Destroy Infrastructure"
```

### Option 3: GitHub Actions
1. Go to your GitHub repository
2. Navigate to **Actions** tab
3. Select **IBM Terraform & Vault Workshop Deployment**
4. Click **Run workflow**
5. Select **destroy** from the dropdown
6. Click **Run workflow**

## Step-by-Step Destruction Process

### 1. Verify Current Resources
```bash
# Check what's currently deployed
terraform show

# List AWS resources
aws ec2 describe-instances --region eu-west-1 --query 'Reservations[*].Instances[*].[InstanceId,State.Name,Tags[?Key==`Name`].Value|[0]]' --output table
aws rds describe-db-instances --region eu-west-1 --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus]' --output table
aws elbv2 describe-load-balancers --region eu-west-1 --query 'LoadBalancers[*].[LoadBalancerName,State.Code]' --output table
```

### 2. Download State for Records (Optional)
```bash
# Download and format the state for your records
./scripts/download-state.sh
# Choose option 5: "Do everything"
```

### 3. Destroy Infrastructure
```bash
# Plan the destruction (see what will be destroyed)
terraform plan -destroy

# Execute destruction
terraform destroy -auto-approve
```

### 4. Verify Destruction
```bash
# Verify all resources are destroyed
terraform show
aws ec2 describe-instances --region eu-west-1 --query 'Reservations[*].Instances[*].[InstanceId,State.Name]' --output table
aws rds describe-db-instances --region eu-west-1
aws elbv2 describe-load-balancers --region eu-west-1
```

## Manual Cleanup (If Terraform Fails)

If Terraform destroy fails, manually clean up these resources in order:

### 1. Auto Scaling Group & EC2 Instances
```bash
# Delete Auto Scaling Group
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name ibm-workshop-asg --force-delete --region eu-west-1

# Terminate any remaining instances
aws ec2 describe-instances --region eu-west-1 --filters "Name=tag:Workshop,Values=terraform-vault-demo" --query 'Reservations[*].Instances[*].InstanceId' --output text | xargs -I {} aws ec2 terminate-instances --instance-ids {} --region eu-west-1
```

### 2. Load Balancer & Target Groups
```bash
# Delete Load Balancer
aws elbv2 delete-load-balancer --load-balancer-arn $(aws elbv2 describe-load-balancers --region eu-west-1 --names ibm-workshop-alb --query 'LoadBalancers[0].LoadBalancerArn' --output text) --region eu-west-1

# Delete Target Group (wait for LB deletion first)
sleep 60
aws elbv2 delete-target-group --target-group-arn $(aws elbv2 describe-target-groups --region eu-west-1 --names ibm-workshop-tg --query 'TargetGroups[0].TargetGroupArn' --output text) --region eu-west-1
```

### 3. RDS Database
```bash
# Delete RDS instance
aws rds delete-db-instance --db-instance-identifier ibm-workshop-db --skip-final-snapshot --region eu-west-1

# Delete DB subnet group (after DB is deleted)
aws rds delete-db-subnet-group --db-subnet-group-name ibm-workshop-db-subnet-group --region eu-west-1
```

### 4. VPC Components
```bash
# Delete Security Groups
aws ec2 delete-security-group --group-id $(aws ec2 describe-security-groups --region eu-west-1 --filters "Name=group-name,Values=ibm-workshop-web-*" --query 'SecurityGroups[0].GroupId' --output text) --region eu-west-1
aws ec2 delete-security-group --group-id $(aws ec2 describe-security-groups --region eu-west-1 --filters "Name=group-name,Values=ibm-workshop-alb-*" --query 'SecurityGroups[0].GroupId' --output text) --region eu-west-1
aws ec2 delete-security-group --group-id $(aws ec2 describe-security-groups --region eu-west-1 --filters "Name=group-name,Values=ibm-workshop-db-*" --query 'SecurityGroups[0].GroupId' --output text) --region eu-west-1

# Delete Subnets
VPC_ID=$(aws ec2 describe-vpcs --region eu-west-1 --filters "Name=tag:Name,Values=ibm-workshop-vpc" --query 'Vpcs[0].VpcId' --output text)
aws ec2 describe-subnets --region eu-west-1 --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[*].SubnetId' --output text | xargs -I {} aws ec2 delete-subnet --subnet-id {} --region eu-west-1

# Delete Route Tables
aws ec2 describe-route-tables --region eu-west-1 --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=ibm-workshop-public-rt" --query 'RouteTables[*].RouteTableId' --output text | xargs -I {} aws ec2 delete-route-table --route-table-id {} --region eu-west-1

# Delete Internet Gateway
IGW_ID=$(aws ec2 describe-internet-gateways --region eu-west-1 --filters "Name=attachment.vpc-id,Values=$VPC_ID" --query 'InternetGateways[0].InternetGatewayId' --output text)
aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID --region eu-west-1
aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID --region eu-west-1

# Delete VPC
aws ec2 delete-vpc --vpc-id $VPC_ID --region eu-west-1
```

## 🗑️ Clean Up State and Buckets

### 1. Remove Terraform State
```bash
# Remove local state files
rm -f terraform.tfstate*
rm -f tfplan*
rm -f .terraform.lock.hcl
rm -rf .terraform/

# Clean up downloaded state files
rm -f terraform-state-*.json
rm -f terraform-state-presentation.md
```

### 2. Delete S3 State Bucket (Optional)
```bash
# Delete all objects in the bucket first
aws s3 rm s3://ibm-terraform-vault-workshop-state --recursive --region eu-west-1

# Delete the bucket
aws s3api delete-bucket --bucket ibm-terraform-vault-workshop-state --region eu-west-1
```

## Verification Checklist

After destruction, verify these items:

- [ ] No EC2 instances running
- [ ] No RDS instances exist
- [ ] No Load Balancers active
- [ ] No Auto Scaling Groups
- [ ] VPC and subnets deleted
- [ ] Security groups removed
- [ ] S3 state bucket cleaned (if desired)
- [ ] Local state files removed

### Verification Commands:
```bash
# Check for any remaining resources
aws ec2 describe-instances --region eu-west-1 --filters "Name=tag:Workshop,Values=terraform-vault-demo"
aws rds describe-db-instances --region eu-west-1 --query 'DBInstances[?contains(DBInstanceIdentifier, `ibm-workshop`)]'
aws elbv2 describe-load-balancers --region eu-west-1 --query 'LoadBalancers[?contains(LoadBalancerName, `ibm-workshop`)]'
aws ec2 describe-vpcs --region eu-west-1 --filters "Name=tag:Name,Values=ibm-workshop-vpc"
```

## Cost Verification

### Check AWS Billing
1. Go to AWS Console → Billing & Cost Management
2. Check **Cost Explorer** for today's charges
3. Verify no ongoing charges from:
   - EC2 instances
   - RDS databases
   - Load Balancers
   - Data transfer

### Expected Costs
- **Total workshop cost**: ~$0.02-0.05 (depending on duration)
- **After destruction**: $0.00 ongoing costs

## 🚨 Emergency Destruction

If you need to quickly destroy everything:

```bash
# Nuclear option - destroys everything with workshop tags
aws resourcegroupstaggingapi get-resources --region eu-west-1 --tag-filters Key=Workshop,Values=terraform-vault-demo --query 'ResourceTagMappingList[*].ResourceARN' --output text | while read arn; do
    echo "Attempting to delete: $arn"
    # This is a simplified approach - actual deletion depends on resource type
done
```

## Support

If you encounter issues during destruction:

1. **Check Terraform logs**: Look for specific error messages
2. **AWS Console**: Manually verify resource states
3. **Dependencies**: Some resources must be deleted in order
4. **Timeouts**: RDS deletion can take 5-10 minutes

## Post-Workshop Actions

After successful destruction:

1. Verify $0.00 ongoing AWS costs
2. Keep state files for documentation (optional)
3. Share workshop repository with IBM Champions
4. Document lessons learned
5. Plan next workshop improvements

---

**Remember**: The goal is to demonstrate Infrastructure as Code benefits while maintaining cost control. Always destroy demo resources promptly!

**Presenter**: Mohamed Ramadan Issa  
**Workshop**: IBM Champions Terraform & Vault Demo  
**Region**: Saudi Arabia
