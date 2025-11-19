#!/bin/bash

# Update system
apt-get update -y
apt-get upgrade -y

# Install Docker
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update -y
apt-get install -y docker.io
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu

# Increase virtual memory required by SonarQube
sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" >> /etc/sysctl.conf

# Create directory for logs
mkdir -p /opt/sonarqube_logs

# Pull and run SonarQube
docker pull sonarqube:lts
docker run -d \
  --name sonarqube \
  -p 9000:9000 \
  -v /opt/sonarqube_logs:/opt/sonarqube/logs \
  sonarqube:lts

# Install AWS CLI
apt install -y awscli

# Sync logs to S3 every 5 minutes
cat << EOF > /usr/local/bin/s3sync.sh
#!/bin/bash
aws s3 sync /opt/sonarqube_logs s3://${bucket_name}/logs
EOF

chmod +x /usr/local/bin/s3sync.sh

(crontab -l 2>/dev/null; echo "*/5 * * * * /usr/local/bin/s3sync.sh") | crontab -
