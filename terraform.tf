provider "aws" {
  access_key = ""
  secret_key = ""
  region     = "ap-south-1"
}




data "aws_ssm_parameter" "ami"{
    name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-kernel-5.10-hvm-x86_64-gp2"
}

resource "aws_vpc" "vpc"{
    
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = true
    tags = {

        Name = "terraform-vpc"
    }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

}

resource "aws_subnet" "subnet1" {
  
  cidr_block              = "10.0.1.0/24"
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true
   tags = {

        Name = "terraform-vpc"
    }
}

resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
   tags = {

        Name = "terraform-vpc"
    }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rtb.id
}

resource "aws_security_group" "Allow_ssh" {
  name   = "Allow_ssh"
  vpc_id = aws_vpc.vpc.id

  # HTTP access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

   tags = {

        Name = "terraform-vpc"
    }
}



resource "aws_instance" "terrform" {
  ami                    = nonsensitive(data.aws_ssm_parameter.ami.value)
  instance_type          = "t2.micro"
  key_name = "common2"
  subnet_id              = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.Allow_ssh.id]
  user_data = <<EOF
  #! /bin/bash
  sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat/jenkins.repo
  sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
  sudo amazon-linux-extras install java-openjdk11 -y 
  sudo yum install jenkins -y
  EOF

  tags= {
    Name = "jenkins-master"
  }
}
resource "aws_instance" "terrform1" {
  ami                    = nonsensitive(data.aws_ssm_parameter.ami.value)
  instance_type          = "t2.micro"
  key_name = "common2"
  subnet_id              = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.Allow_ssh.id]
  user_data = <<EOF
  sudo amazon-linux-extras install java-openjdk11 -y
  sudo amazon-linux-extras install ansible2 -y
  EOF
  tags= {
    Name = "jenkins-slave"
  }
}
