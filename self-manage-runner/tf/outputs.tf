
output "public_ip" {
  value = aws_instance.runner_instance.public_ip
}

output "private_ip" {
  value = aws_instance.runner_instance.private_ip
}
