# Docker/Kubernetes Learning Environment

## Setup

### Local

`cd` into the project (direnv).

### EC2

```bash
aws ssm get-parameter --name "/ec2/learning-key" --with-decryption \
  --query "Parameter.Value" --output text > ~/.ssh/learning-key.pem && \
chmod 600 ~/.ssh/learning-key.pem
```

## Usage

### Local

TODO

### EC2

```bash
ssh -i ~/.ssh/learning-key.pem ubuntu@<IP>
```

Get IP: `cd terraform && tofu output instance_public_ips`