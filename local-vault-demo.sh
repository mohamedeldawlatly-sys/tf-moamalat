#!/bin/bash
# Local Vault Demo for IBM Champions Workshop
# Run this on your laptop during the presentation

echo "🔐 HASHICORP VAULT DEMO - IBM CHAMPIONS WORKSHOP"
echo "================================================="
echo "Presenter: Mohamed Ramadan Issa"
echo ""

# Check if vault is installed
if ! command -v vault &> /dev/null; then
    echo "❌ Vault CLI not found. Installing..."
    # Add installation commands for your OS
    exit 1
fi

echo "1️⃣ STARTING LOCAL VAULT SERVER (DEV MODE)"
echo "=========================================="
echo "vault server -dev &"
echo ""

echo "2️⃣ SETTING UP ENVIRONMENT"
echo "========================="
echo "export VAULT_ADDR='http://127.0.0.1:8200'"
echo "export VAULT_TOKEN='dev-only-token'"
echo ""

echo "3️⃣ BASIC VAULT OPERATIONS"
echo "========================="
echo ""

echo "📊 Check Vault Status:"
echo "vault status"
echo ""

echo "🔑 Store Database Credentials:"
echo "vault kv put secret/database \\"
echo "  username=admin \\"
echo "  password=SuperSecure123! \\"
echo "  host=ibm-workshop-db.eu-west-1.rds.amazonaws.com \\"
echo "  port=3306"
echo ""

echo "📋 List Secrets:"
echo "vault kv list secret/"
echo ""

echo "🔍 Retrieve Database Credentials:"
echo "vault kv get secret/database"
echo ""

echo "🔐 Store API Keys:"
echo "vault kv put secret/api-keys \\"
echo "  stripe_key=sk_live_51H... \\"
echo "  github_token=ghp_xxxx... \\"
echo "  aws_access_key=AKIA..."
echo ""

echo "📱 Store Application Config:"
echo "vault kv put secret/app-config \\"
echo "  environment=production \\"
echo "  debug=false \\"
echo "  max_connections=100 \\"
echo "  cache_ttl=3600"
echo ""

echo "4️⃣ ADVANCED VAULT FEATURES"
echo "=========================="
echo ""

echo "🔄 Enable Database Secrets Engine:"
echo "vault secrets enable database"
echo ""

echo "⚙️ Configure MySQL Database:"
echo "vault write database/config/mysql \\"
echo "  plugin_name=mysql-database-plugin \\"
echo "  connection_url='{{username}}:{{password}}@tcp(mysql.example.com:3306)/' \\"
echo "  allowed_roles='readonly,readwrite'"
echo ""

echo "👤 Create Database Role:"
echo "vault write database/roles/readonly \\"
echo "  db_name=mysql \\"
echo "  creation_statements='CREATE USER \"{{name}}\"@\"%\" IDENTIFIED BY \"{{password}}\"; GRANT SELECT ON *.* TO \"{{name}}\"@\"%\";' \\"
echo "  default_ttl='1h' \\"
echo "  max_ttl='24h'"
echo ""

echo "🎫 Generate Dynamic Database Credentials:"
echo "vault read database/creds/readonly"
echo ""

echo "5️⃣ VAULT POLICIES & ACCESS CONTROL"
echo "=================================="
echo ""

echo "📝 Create Policy for Developers:"
echo "vault policy write developer - <<EOF"
echo "# Allow developers to read/write their app secrets"
echo "path \"secret/data/app-*\" {"
echo "  capabilities = [\"create\", \"read\", \"update\", \"delete\", \"list\"]"
echo "}"
echo ""
echo "# Allow read-only access to shared secrets"
echo "path \"secret/data/shared/*\" {"
echo "  capabilities = [\"read\", \"list\"]"
echo "}"
echo "EOF"
echo ""

echo "🎟️ Create Token with Policy:"
echo "vault token create -policy=developer -ttl=8h"
echo ""

echo "6️⃣ VAULT AUDIT & MONITORING"
echo "==========================="
echo ""

echo "📊 Enable Audit Logging:"
echo "vault audit enable file file_path=/tmp/vault-audit.log"
echo ""

echo "📈 View Audit Logs:"
echo "tail -f /tmp/vault-audit.log | jq"
echo ""

echo "7️⃣ VAULT WEB UI"
echo "==============="
echo ""
echo "🌐 Access Vault UI at: http://127.0.0.1:8200/ui"
echo "🔑 Use the root token to login"
echo ""

echo "8️⃣ INTEGRATION EXAMPLES"
echo "======================="
echo ""

echo "🐍 Python Application Example:"
echo "import hvac"
echo "client = hvac.Client(url='http://127.0.0.1:8200')"
echo "client.token = 'your-vault-token'"
echo "secret = client.secrets.kv.v2.read_secret_version(path='database')"
echo "db_password = secret['data']['data']['password']"
echo ""

echo "☁️ AWS Integration:"
echo "vault auth enable aws"
echo "vault write auth/aws/role/ec2-role \\"
echo "  auth_type=ec2 \\"
echo "  policies=developer \\"
echo "  bound_ami_id=ami-12345678"
echo ""

echo "🔄 Kubernetes Integration:"
echo "vault auth enable kubernetes"
echo "vault write auth/kubernetes/role/webapp \\"
echo "  bound_service_account_names=webapp \\"
echo "  bound_service_account_namespaces=default \\"
echo "  policies=developer \\"
echo "  ttl=1h"
echo ""

echo "9️⃣ CLEANUP"
echo "=========="
echo ""
echo "🧹 Stop Vault Server:"
echo "pkill vault"
echo ""

echo "✅ DEMO COMPLETE!"
echo "================="
echo ""
echo "🎯 Key Takeaways:"
echo "• Centralized secret management"
echo "• Dynamic secret generation"
echo "• Fine-grained access control"
echo "• Comprehensive audit logging"
echo "• Multi-cloud and platform support"
echo "• Easy integration with applications"
echo ""
echo "📞 Questions & Discussion"
echo "========================"
echo "Mohamed Ramadan Issa - IBM Champions Workshop"
