 output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.web-server-instance.public_ip
}

# Create the inventory file
resource "null_resource" "generate_inventory" {
  provisioner "local-exec" {
    command = <<EOF
      # Create the inventory file and add hosts
      echo "[all]" > ../Ansible/hosts
      echo "WebserverInstance ansible_host=${aws_instance.web-server-instance.public_ip} ansible_user=ubuntu ansible_ssh_common_args='-o StrictHostKeyChecking=no' ansible_ssh_private_key_file=../Ansible/mykey.pem" >> ../Ansible/hosts
    EOF
  }
}
