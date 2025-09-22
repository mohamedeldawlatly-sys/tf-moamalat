# Terraform Backend Configuration for IBM Workshop
# This stores the Terraform state in S3 for team collaboration and state sharing

terraform {
  backend "s3" {
    bucket         = "ibm-terraform-vault-workshop-state"
    key            = "workshop/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    
    # Optional: DynamoDB table for state locking (prevents concurrent modifications)
    # dynamodb_table = "terraform-state-lock"
  }
}
