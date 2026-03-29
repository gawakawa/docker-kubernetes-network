terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "learning-tfstate-93927776"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

# Get current public IP
data "http" "my_ip" {
  url = "https://api.ipify.org"
}

# Get Ubuntu 24.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Generate SSH key pair
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "learning" {
  key_name   = "learning-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

# Store private key in SSM Parameter Store
resource "aws_ssm_parameter" "ssh_private_key" {
  name        = "/ec2/learning-key"
  description = "SSH private key for learning EC2 instances"
  type        = "SecureString"
  value       = tls_private_key.ssh.private_key_pem
}

# Security Group
resource "aws_security_group" "learning" {
  name        = "learning-sg"
  description = "Security group for Docker/Kubernetes learning environment"
  vpc_id      = data.aws_vpc.default.id

  # SSH
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  # ICMP (ping)
  ingress {
    description = "ICMP from my IP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  # Custom port 5000
  ingress {
    description = "Custom port 5000 from my IP"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  # Allow all traffic between instances in this security group
  ingress {
    description = "All traffic within security group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "learning-sg"
  }
}

# EC2 Instances
resource "aws_instance" "host" {
  count = 2

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  key_name               = aws_key_pair.learning.key_name
  vpc_security_group_ids = [aws_security_group.learning.id]

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  user_data = <<-EOF
#cloud-config
package_update: true
packages:
  - ca-certificates
  - curl
  - python3
  - tcpdump
write_files:
  - path: /etc/apt/keyrings/docker.asc
    defer: true
  - path: /etc/apt/sources.list.d/docker.sources
    content: |
      Types: deb
      URIs: https://download.docker.com/linux/ubuntu
      Suites: noble
      Components: stable
      Architectures: amd64
      Signed-By: /etc/apt/keyrings/docker.asc
runcmd:
  - curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  - chmod a+r /etc/apt/keyrings/docker.asc
  - apt-get update
  - apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  - systemctl enable docker
  - gpasswd -a ubuntu docker
  - systemctl restart docker
  EOF

  tags = {
    Name = "host${count.index + 1}"
  }
}
