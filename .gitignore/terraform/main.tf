provider "aws" {
  region = "us-east-1"
}

# Security Group for EC2 + SonarQube
resource "aws_security_group" "sonarqube_sg" {
  name        = "sonarqube-sg"
  description = "Allow SonarQube UI, SSH, and required ports"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # SonarQube UI
  }

  # Optional: if you want HTTP/HTTPS also open
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# S3 bucket for SonarQube logs/reports
resource "aws_s3_bucket" "sonarqube_reports" {
  bucket = "sonarqube-reports-${random_id.bucket.hex}"  # must be globally unique
}

resource "random_id" "bucket" {
  byte_length = 4
}

# EC2 Instance to run SonarQube
resource "aws_instance" "sonarqube" {
  ami                    = "ami-04b70fa74e45c3917"  # Amazon ubuntu (us-east-1)
  instance_type          = "c7i-flex.large"
  key_name               = "sonarqube-key"          # Your actual EC2 keypair
  vpc_security_group_ids = [aws_security_group.sonarqube_sg.id]

  user_data = templatefile("${path.module}/user.sh", {
  bucket_name = aws_s3_bucket.sonarqube_reports.bucket
  })


  tags = {
    Name = "SonarQube-Server"
  }
}

# Outputs
output "sonarqube_url" {
  value = "http://${aws_instance.sonarqube.public_ip}:9000"
}

output "s3_bucket" {
  value = aws_s3_bucket.sonarqube_reports.bucket
}
