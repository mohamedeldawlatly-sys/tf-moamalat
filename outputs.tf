# Outputs for IBM Terraform & Vault Workshop
# Presenter: Mohamed Ramadan Issa

output "webapp_url" {
  description = "URL of the deployed web application"
  value       = "http://${aws_lb.main.dns_name}"
}

output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "vault_url" {
  description = "URL to access Vault UI"
  value       = "http://${aws_lb.main.dns_name}:8200"
}

output "vault_root_token" {
  description = "Vault root token (for demo purposes only)"
  value       = random_password.vault_password.result
  sensitive   = true
}

output "database_endpoint" {
  description = "RDS database endpoint"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

output "database_username" {
  description = "Database username"
  value       = aws_db_instance.main.username
}

output "database_password" {
  description = "Database password (stored in Vault)"
  value       = random_password.db_password.result
  sensitive   = true
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "security_group_web_id" {
  description = "ID of the web security group"
  value       = aws_security_group.web.id
}

output "security_group_db_id" {
  description = "ID of the database security group"
  value       = aws_security_group.db.id
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.web.name
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.web.arn
}

# Instructions for accessing the application
output "access_instructions" {
  description = "Instructions for accessing the deployed application"
  sensitive   = true
  value = <<-EOT
    
    🎉 IBM Terraform & Vault Workshop Deployment Complete!
    
    📱 Web Application: http://${aws_lb.main.dns_name}
    🔐 Vault UI: http://${aws_lb.main.dns_name}:8200
    
    🔑 To access Vault:
    export VAULT_ADDR=http://${aws_lb.main.dns_name}:8200
    export VAULT_TOKEN=${random_password.vault_password.result}
    vault status
    
    📊 Database Credentials (stored in Vault):
    vault kv get secret/database
    
    🏷️ All resources are tagged with:
    - Environment: workshop
    - Project: ibm-terraform-vault-demo
    - Owner: mohamed-ramadan-issa
    - Workshop: terraform-vault-demo
    
    🧹 Cleanup: terraform destroy -auto-approve
    
    Presenter: Mohamed Ramadan Issa
    Target: IBM Champions Saudi Arabia
  EOT
}

# Demo commands for the presentation
output "demo_commands" {
  description = "Commands to demonstrate during the workshop"
  value = <<-EOT
    
    🎯 Demo Commands for IBM Champions Workshop:
    
    1. Check Vault Status:
       vault status
    
    2. List Vault Secrets:
       vault kv list secret/
    
    3. Get Database Credentials:
       vault kv get secret/database
    
    4. Show AWS Resources:
       aws ec2 describe-instances --region eu-west-1 --query 'Reservations[*].Instances[*].[InstanceId,State.Name,Tags[?Key==`Name`].Value|[0]]' --output table
    
    5. Show RDS Instance:
       aws rds describe-db-instances --region eu-west-1 --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus,Engine]' --output table
    
    6. Show Load Balancer:
       aws elbv2 describe-load-balancers --region eu-west-1 --query 'LoadBalancers[*].[LoadBalancerName,State.Code,DNSName]' --output table
  EOT
}
