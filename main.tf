terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
}

resource "aws_vpc" "fair_fairytale_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "fairFairytaleVpc"
  }
}

resource "aws_internet_gateway" "fair_fairytale_gateway" {
  vpc_id = aws_vpc.fair_fairytale_vpc.id

  tags = {
    Name = "fairFairytaleGateway"
  }
}

resource "aws_route_table" "fair_fairytale_route_table" {
  vpc_id = aws_vpc.fair_fairytale_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.fair_fairytale_gateway.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.fair_fairytale_gateway.id
  }

  tags = {
    Name = "fairFairytaleRouteTable"
  }
}


resource "aws_subnet" "fair_fairytale_subnet" {
  vpc_id     = aws_vpc.fair_fairytale_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "fairFairytaleSubnet"
  }
}

resource "aws_route_table_association" "fair_fairytale_route_table_association" {
  subnet_id      = aws_subnet.fair_fairytale_subnet.id
  route_table_id = aws_route_table.fair_fairytale_route_table.id
}


resource "aws_security_group" "fair_fairytale_security_group" {
  name        = "fair_fairytale_security_group"
  description = "Allow SSH HTTP HTTPS connections"
  vpc_id = aws_vpc.fair_fairytale_vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "fairFairytaleSecurityGroup"
  }
}

resource "aws_network_interface" "fair_fairytale_network_interface" {
  subnet_id      = aws_subnet.fair_fairytale_subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.fair_fairytale_security_group.id]

}

resource "aws_eip" "fair_fairytale_elastic_ip" {
  vpc                       = true
  network_interface         = aws_network_interface.fair_fairytale_network_interface.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.fair_fairytale_gateway]
}

output "server_public_ip" {
  value = aws_eip.fair_fairytale_elastic_ip.public_ip
}


resource "aws_instance" "fair_fairytale_server" {

  ami = "ami-0b0ea68c435eb488d"
  #https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#LaunchInstances:ami=ami-0b0ea68c435eb488d
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = "my-key"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.fair_fairytale_network_interface.id
  }

  user_data = <<-EOF
                #!/bin/bash
                cd ~
                sudo apt update -y
                sudo apt install python3 -y
                sudo apt install python3-pip -y
                git clone https://github.com/Moshi-Li/fair-fairytale-web.git
                cd fair-fairytale-web
                git checkout feat-init
                cd server
                pip3 install -r requirements.txt
                sudo python3 index.py
                EOF
}