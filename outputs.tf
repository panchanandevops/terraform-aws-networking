output "public_subnet_ids" {
  value = { for key, subnet in aws_subnet.public_subnet : key => subnet.id }
}

output "security_group_id" {
  value = [aws_security_group.allow_ssh_http_https.id]
}