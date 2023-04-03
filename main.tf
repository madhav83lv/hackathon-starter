#provider.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}


#key-pairs.tf
resource "aws_key_pair" "tf-key-pair" {
  key_name   = "tf-key-pair"
  public_key = tls_private_key.rsa.public_key_openssh
}
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "tf-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "tf-key-pair"
}


#main.tf
resource "aws_instance" "ec2-web" {
  ami               = "ami-006e00d6ac75d2ebb"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1"
  key_name          = "tf-key-pair"
  user_data         = "${file("install_mongo-db.sh")}"
  tags = {
    Name = "ec2-mongodb"
  }
}


#outputs.tf
output "server_private_ip" {
  value = aws_instance.ec2-web.private_ip
}
output "server_public_ipv4" {
  value = aws_instance.ec2-web.public_ip
}
output "server_id" {
  value = aws_instance.ec2-web.id
}
