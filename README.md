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
<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->