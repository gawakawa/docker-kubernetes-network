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

None.

### EC2

```bash
# host1
eval "$(tofu -chdir=terraform output -json ssh_commands | jq -r '.host1')"

# host2
eval "$(tofu -chdir=terraform output -json ssh_commands | jq -r '.host2')"
```