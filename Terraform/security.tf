# Generate a new SSH key pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create and download the key pair
resource "aws_key_pair" "main" {
  key_name   = "mykey${timestamp()}"
  public_key = tls_private_key.ssh_key.public_key_openssh
  
  lifecycle {
    ignore_changes = [public_key]
  }

  provisioner "local-exec" {
    command = "echo '${tls_private_key.ssh_key.private_key_pem}' > ../Ansible/mykey.pem && chmod 400 ../Ansible/mykey.pem"
  }
  
}
