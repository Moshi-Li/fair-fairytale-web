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
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "fairFairytaleVpc"
  }
}

resource "aws_subnet" "fair_fairytale_subnet" {
  vpc_id     = aws_vpc.fair_fairytale_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "fairFairytaleSubnet"
  }
}

resource "aws_internet_gateway" "fair_fairytale_gateway" {
  vpc_id = aws_vpc.fair_fairytale_vpc.id

  tags = {
    Name = "fairFairytaleGateway"
  }
}

resource "aws_security_group" "fair_fairytale_security_group" {
  name        = "fair_fairytale_security_group"
  description = "Allow SSH inbound connections"
  vpc_id = aws_vpc.fair_fairytale_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "fairFairytaleSecurityGroup"
  }
}

resource "aws_instance" "fair_fairytale_server" {

  instance_type = "t2.micro"
  ami = "ami-0b0ea68c435eb488d"
  #https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#LaunchInstances:ami=ami-0b0ea68c435eb488d


vpc_security_group_ids = [ aws_security_group.fair_fairytale_security_group.id ]
  subnet_id = aws_subnet.fair_fairytale_subnet.id
  associate_public_ip_address = true
  tags = {
    Name = "fairFairytaleServer"
  }
}