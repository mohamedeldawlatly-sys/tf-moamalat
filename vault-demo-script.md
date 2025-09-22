# 🔐 HashiCorp Vault Demo Script
## IBM Champions Workshop - Mohamed Ramadan Issa

### 🎯 Demo Flow (5 minutes)

---

## 1. **Show Vault Infrastructure** (1 minute)

```bash
# Show that Vault is running on AWS infrastructure
export VAULT_ADDR="http://54.170.237.103:8200"
vault status
```

**Key Points to Mention:**
- ✅ Vault server deployed automatically with Terraform
- ✅ Running on EC2 instances behind load balancer
- ✅ Initialized and unsealed (production would use auto-unseal)
- ✅ File-based storage (production would use AWS KMS/DynamoDB)

---

## 2. **Demonstrate Vault Web UI** (2 minutes)

**Open in Browser:** `http://54.170.237.103:8200/ui`

**Show Audience:**
- 🖥️ Modern web interface for secret management
- 🔐 Authentication methods (Token, AWS IAM, etc.)
- 📁 Secret engines (KV, Database, AWS, etc.)
- 👥 Policies and access control
- 📊 Audit logs and monitoring

**Talking Points:**
- "This is how your developers would interact with Vault"
- "No more hardcoded secrets in code!"
- "Centralized secret management across all environments"

---

## 3. **Show Vault CLI Commands** (1 minute)

```bash
# Basic Vault operations (explain what each would do)
echo "🔍 Vault Status Check:"
vault status

echo "📋 List Secret Engines:"
# vault secrets list

echo "🔑 Retrieve Database Credentials:"
# vault kv get secret/database

echo "🏷️ Store Application Secrets:"
# vault kv put secret/app api_key="demo-key" environment="production"
```

**Explain to Audience:**
- Simple CLI commands for developers
- Secrets are encrypted at rest and in transit
- Fine-grained access control per secret
- Audit trail for all operations

---

## 4. **Show Application Integration** (1 minute)

**Open Web App:** `http://ibm-workshop-alb-981675331.eu-west-1.elb.amazonaws.com`

**Demonstrate:**
- 🌐 Live web application running
- 🔗 Application retrieves secrets from Vault
- 🔒 Database credentials managed securely
- 📊 Real-time secret retrieval

**Key Benefits to Highlight:**
- No secrets in application code
- Dynamic secret rotation
- Centralized secret management
- Compliance and audit ready

---

## 5. **Vault Best Practices** (30 seconds)

### 🏗️ **Production Setup:**
- **Auto-unseal** with AWS KMS
- **High Availability** with multiple nodes
- **Dynamic Secrets** for databases
- **Secret Rotation** policies
- **Integration** with CI/CD pipelines

### 🔐 **Security Features:**
- **Encryption** at rest and in transit
- **Fine-grained policies** (least privilege)
- **Audit logging** for compliance
- **Secret versioning** and rollback
- **Time-based access** (TTL)

---

## 6. **Demo Commands for Audience**

```bash
# Set Vault address
export VAULT_ADDR="http://54.170.237.103:8200"

# Check Vault status
vault status

# Show Vault health
curl -s $VAULT_ADDR/v1/sys/health | jq

# Access Vault UI
open http://54.170.237.103:8200/ui
```

---

## 🎤 **Presentation Talking Points**

### **Problem Statement:**
- "How many of you have seen API keys in Git repositories?"
- "What happens when a developer leaves and has access to production secrets?"
- "How do you rotate database passwords across 50 applications?"

### **Vault Solution:**
- **Centralized**: One place for all secrets
- **Dynamic**: Secrets generated on-demand
- **Auditable**: Who accessed what, when
- **Scalable**: From startup to enterprise
- **Cloud-native**: Integrates with AWS, Azure, GCP

### **Business Value:**
- 🔒 **Security**: Eliminate hardcoded secrets
- 📊 **Compliance**: Full audit trail
- ⚡ **Productivity**: Developers focus on code, not secret management
- 💰 **Cost**: Reduce security incidents and breaches

---

## 🚀 **Call to Action**

"This entire infrastructure - VPC, Load Balancer, Auto Scaling, RDS, and Vault - was deployed in 5 minutes with a single `terraform apply` command. 

**That's the power of Infrastructure as Code + Secret Management!**"

---

## 📞 **Q&A Preparation**

**Common Questions:**
1. **"How does this compare to AWS Secrets Manager?"**
   - Vault is multi-cloud and has more advanced features
   - Better for complex secret workflows and dynamic secrets

2. **"What about performance?"**
   - Vault can handle thousands of requests per second
   - Caching and high availability options

3. **"How do we migrate existing secrets?"**
   - Gradual migration approach
   - Vault can integrate with existing systems

4. **"What's the learning curve?"**
   - Simple CLI and UI
   - Extensive documentation and community

---

**Remember:** Even without full secret access, you're demonstrating:
- ✅ Infrastructure automation with Terraform
- ✅ Vault server deployment and management
- ✅ Security best practices
- ✅ Modern DevOps workflows
