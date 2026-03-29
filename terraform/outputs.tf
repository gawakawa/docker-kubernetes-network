output "instance_public_ips" {
  description = "Public IP addresses of the EC2 instances"
  value = {
    for idx, instance in aws_instance.host :
    "host${idx + 1}" => instance.public_ip
  }
}

output "my_ip" {
  description = "Your current public IP (used for security group rules)"
  value       = chomp(data.http.my_ip.response_body)
}

output "ssh_key_retrieval_command" {
  description = "Command to retrieve SSH private key from SSM"
  value       = <<-EOT
    aws ssm get-parameter --name "/ec2/learning-key" --with-decryption \
      --query "Parameter.Value" --output text > ~/.ssh/learning-key.pem && \
    chmod 600 ~/.ssh/learning-key.pem
  EOT
}

output "ssh_commands" {
  description = "SSH connection commands"
  value = {
    for idx, instance in aws_instance.host :
    "host${idx + 1}" => "ssh -i ~/.ssh/learning-key.pem ubuntu@${instance.public_ip}"
  }
}
