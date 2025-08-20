output "vm_username" {
  value = "ubuntu"
}

output "vm_ip" {
  value = aws_instance.main.public_ip
}
