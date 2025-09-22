#!/bin/bash
# IBM Terraform & Vault Workshop - EC2 User Data Script
# Presenter: Mohamed Ramadan Issa

# Update system
yum update -y

# Install required packages
yum install -y httpd python3 python3-pip unzip wget curl

# Install Vault
cd /tmp
wget https://releases.hashicorp.com/vault/1.15.0/vault_1.15.0_linux_amd64.zip
unzip vault_1.15.0_linux_amd64.zip
mv vault /usr/local/bin/
chmod +x /usr/local/bin/vault

# Create vault user and directories
useradd -r -d /opt/vault -s /bin/false vault
mkdir -p /opt/vault/{data,config,logs}
chown -R vault:vault /opt/vault

# Create Vault configuration
cat > /opt/vault/config/vault.hcl << 'EOF'
ui = true
storage "file" {
  path = "/opt/vault/data"
}
listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = true
}
api_addr = "http://0.0.0.0:8200"
cluster_addr = "http://0.0.0.0:8201"
EOF

# Create Vault systemd service
cat > /etc/systemd/system/vault.service << 'EOF'
[Unit]
Description=HashiCorp Vault
Documentation=https://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/opt/vault/config/vault.hcl

[Service]
Type=notify
User=vault
Group=vault
ProtectSystem=full
ProtectHome=read-only
PrivateTmp=yes
PrivateDevices=yes
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=/usr/local/bin/vault server -config=/opt/vault/config/vault.hcl
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
StartLimitBurst=3
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# Start and enable Vault
systemctl daemon-reload
systemctl enable vault
systemctl start vault

# Wait for Vault to start
sleep 10

# Initialize Vault (for demo purposes - not production ready)
export VAULT_ADDR="http://localhost:8200"
vault operator init -key-shares=1 -key-threshold=1 > /tmp/vault-init.txt

# Extract unseal key and root token
UNSEAL_KEY=$(grep 'Unseal Key 1:' /tmp/vault-init.txt | awk '{print $NF}')
ROOT_TOKEN="${vault_token}"

# Unseal Vault
vault operator unseal $UNSEAL_KEY

# Login with root token
vault auth $ROOT_TOKEN

# Enable KV secrets engine
vault secrets enable -path=secret kv

# Store database credentials in Vault
vault kv put secret/database \
  username="${db_username}" \
  password="${db_password}" \
  endpoint="${db_endpoint}"

# Store additional demo secrets
vault kv put secret/app \
  api_key="demo-api-key-12345" \
  app_secret="demo-app-secret-67890"

# Create web application directory
mkdir -p /var/www/html

# Create the main web application
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>IBM Terraform & Vault Workshop</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Arial', sans-serif;
            background: white;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            color: #333;
        }
        
        .container {
            text-align: center;
            max-width: 1200px;
            padding: 2rem;
            background: rgba(0, 0, 0, 0.05);
            border-radius: 20px;
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            border: 1px solid rgba(0, 0, 0, 0.1);
        }
        
        .welcome-title {
            font-size: 3rem;
            margin-bottom: 1rem;
            background: linear-gradient(45deg, #0066CC, #004499);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        
        .subtitle {
            font-size: 1.5rem;
            margin-bottom: 2rem;
            opacity: 0.9;
        }
        
        .presenter {
            font-size: 1.2rem;
            margin-bottom: 2rem;
            color: #0066CC;
            font-weight: bold;
        }
        
        .logos {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 2rem;
            margin: 2rem 0;
            flex-wrap: wrap;
        }
        
        .logo {
            width: 80px;
            height: 80px;
            background: white;
            border-radius: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            color: #333;
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
            transition: transform 0.3s ease;
        }
        
        .logo:hover {
            transform: translateY(-5px);
        }
        
        .ibm-logo {
            background: #1261FE;
            color: white;
            font-size: 1.2rem;
        }
        
        .terraform-logo {
            background: #623CE4;
            color: white;
            font-size: 0.8rem;
        }
        
        .vault-logo {
            background: #000000;
            color: #FFD814;
            font-size: 0.9rem;
        }
        
        .aws-logo {
            background: #FF9900;
            color: white;
            font-size: 0.9rem;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1rem;
            margin: 2rem 0;
        }
        
        .info-card {
            background: rgba(0, 0, 0, 0.05);
            padding: 1.5rem;
            border-radius: 15px;
            border: 1px solid rgba(0, 0, 0, 0.1);
        }
        
        .info-card h3 {
            color: #0066CC;
            margin-bottom: 0.5rem;
        }
        
        .vault-demo {
            margin: 2rem 0;
            padding: 1.5rem;
            background: rgba(0, 0, 0, 0.1);
            border-radius: 15px;
            border-left: 4px solid #0066CC;
        }
        
        .vault-demo h3 {
            color: #0066CC;
            margin-bottom: 1rem;
        }
        
        .secret-display {
            background: rgba(0, 0, 0, 0.5);
            padding: 1rem;
            border-radius: 10px;
            font-family: 'Courier New', monospace;
            text-align: left;
            margin: 1rem 0;
        }
        
        .footer {
            margin-top: 2rem;
            padding-top: 1rem;
            border-top: 1px solid rgba(0, 0, 0, 0.2);
            opacity: 0.8;
        }
        
        .blink {
            animation: blink 2s infinite;
        }
        
        @keyframes blink {
            0%, 50% { opacity: 1; }
            51%, 100% { opacity: 0.5; }
        }
        
        .status-indicator {
            display: inline-block;
            width: 12px;
            height: 12px;
            background: #00ff00;
            border-radius: 50%;
            margin-right: 8px;
            animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
            0% { transform: scale(1); opacity: 1; }
            50% { transform: scale(1.2); opacity: 0.7; }
            100% { transform: scale(1); opacity: 1; }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="welcome-title">🎉 Welcome IBM Champions in Saudi Arabia! 🇸🇦</h1>
        <p class="subtitle">Terraform & HashiCorp Vault Workshop</p>
        <p class="presenter">👨‍💻 Presenter: Mohamed Ramadan Issa</p>
        
        <div class="logos">
            <div class="logo ibm-logo">IBM</div>
            <div class="logo terraform-logo">Terraform</div>
            <div class="logo vault-logo">Vault</div>
            <div class="logo aws-logo">AWS</div>
        </div>
        
        <div class="info-grid">
            <div class="info-card">
                <h3><span class="status-indicator"></span>Infrastructure Status</h3>
                <p>✅ VPC & Subnets Created</p>
                <p>✅ Load Balancer Active</p>
                <p>✅ Auto Scaling Group Running</p>
                <p>✅ RDS Database Online</p>
            </div>
            
            <div class="info-card">
                <h3>🔐 Security Features</h3>
                <p>✅ Vault Server Running</p>
                <p>✅ Secrets Encrypted</p>
                <p>✅ IAM Roles Configured</p>
                <p>✅ Security Groups Applied</p>
            </div>
            
            <div class="info-card">
                <h3>🏷️ Resource Tagging</h3>
                <p>Environment: workshop</p>
                <p>Project: ibm-terraform-vault-demo</p>
                <p>Owner: mohamed-ramadan-issa</p>
                <p>Region: eu-west-1</p>
            </div>
            
            <div class="info-card">
                <h3>📊 Deployment Info</h3>
                <p>Region: EU West (Ireland)</p>
                <p>Instances: Auto Scaling</p>
                <p>Database: MySQL 8.0</p>
                <p>Load Balancer: Application LB</p>
            </div>
        </div>
        
        <div class="vault-demo">
            <h3>🔐 Live Vault Integration Demo</h3>
            <p>This application retrieves secrets from HashiCorp Vault in real-time:</p>
            
            <div class="secret-display">
                <strong>Database Credentials (from Vault):</strong><br>
                🔑 Username: <span class="blink">${db_username}</span><br>
                🔒 Password: <span class="blink">••••••••••••••••</span><br>
                🌐 Endpoint: <span class="blink">${db_endpoint}</span>
            </div>
            
            <p><strong>Vault Commands:</strong></p>
            <div class="secret-display">
                export VAULT_ADDR=http://$(curl -s http://169.254.169.254/latest/meta-data/public-hostname):8200<br>
                vault kv get secret/database<br>
                vault kv get secret/app
            </div>
        </div>
        
        <div class="footer">
            <p>🚀 Deployed with Terraform | 🔐 Secured with Vault | ☁️ Powered by AWS</p>
            <p>Workshop Duration: 10 minutes | Target: IBM Champions Saudi Arabia</p>
            <p><strong>Remember:</strong> Run <code>terraform destroy</code> after the demo! 💰</p>
        </div>
    </div>
    
    <script>
        // Add some interactivity
        document.addEventListener('DOMContentLoaded', function() {
            // Rotate logos
            const logos = document.querySelectorAll('.logo');
            logos.forEach((logo, index) => {
                logo.addEventListener('click', function() {
                    this.style.transform = 'rotate(360deg) scale(1.1)';
                    setTimeout(() => {
                        this.style.transform = '';
                    }, 500);
                });
            });
            
            // Update timestamp
            const now = new Date();
            const timestamp = now.toLocaleString('en-US', {
                timeZone: 'Asia/Riyadh',
                year: 'numeric',
                month: 'long',
                day: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
            });
            
            const footer = document.querySelector('.footer');
            footer.innerHTML += `<p style="margin-top: 1rem; font-size: 0.9rem;">Deployed: ` + timestamp + ` (Saudi Arabia Time)</p>`;
        });
    </script>
</body>
</html>
EOF

# Create a simple Python Flask app for Vault integration
cat > /var/www/html/app.py << 'EOF'
#!/usr/bin/env python3
import os
import subprocess
import json
from flask import Flask, jsonify, render_template_string

app = Flask(__name__)

@app.route('/vault-status')
def vault_status():
    try:
        result = subprocess.run(['vault', 'status', '-format=json'], 
                              capture_output=True, text=True, 
                              env={'VAULT_ADDR': 'http://localhost:8200'})
        if result.returncode == 0:
            return jsonify(json.loads(result.stdout))
        else:
            return jsonify({'error': 'Vault not accessible'}), 500
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/vault-secrets')
def vault_secrets():
    try:
        # Get database secrets
        result = subprocess.run(['vault', 'kv', 'get', '-format=json', 'secret/database'], 
                              capture_output=True, text=True,
                              env={'VAULT_ADDR': 'http://localhost:8200',
                                   'VAULT_TOKEN': '${vault_token}'})
        if result.returncode == 0:
            data = json.loads(result.stdout)
            return jsonify(data['data'])
        else:
            return jsonify({'error': 'Could not retrieve secrets'}), 500
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

# Make Python app executable
chmod +x /var/www/html/app.py

# Install Flask
pip3 install flask

# Start Apache
systemctl enable httpd
systemctl start httpd

# Create a simple health check endpoint
cat > /var/www/html/health << 'EOF'
OK
EOF

# Set proper permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Create a startup script for the Flask app
cat > /etc/systemd/system/flask-app.service << 'EOF'
[Unit]
Description=Flask Vault Demo App
After=network.target vault.service

[Service]
Type=simple
User=apache
WorkingDirectory=/var/www/html
Environment=VAULT_ADDR=http://localhost:8200
Environment=VAULT_TOKEN=${vault_token}
ExecStart=/usr/bin/python3 /var/www/html/app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable and start Flask app
systemctl daemon-reload
systemctl enable flask-app
systemctl start flask-app

# Log deployment completion
echo "$(date): IBM Terraform & Vault Workshop deployment completed" >> /var/log/workshop-deployment.log
echo "Presenter: Mohamed Ramadan Issa" >> /var/log/workshop-deployment.log
echo "Target: IBM Champions Saudi Arabia" >> /var/log/workshop-deployment.log
echo "Vault URL: http://$(curl -s http://169.254.169.254/latest/meta-data/public-hostname):8200" >> /var/log/workshop-deployment.log
EOF
