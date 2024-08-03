resource "aws_vpc" "myvpc" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"
  tags = {
    Name = var.vpc_name
  }
}

variable "cidr_block" {
  type    = string
  default = "10.1.0.0/16"
}

variable "vpc_name" {
  type    = string
  default = "myvpc-tf"
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "myigw"
  }
}

resource "aws_subnet" "mysubnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = var.subnet_cidr_block
  map_public_ip_on_launch = "true"
#   enable_dns64 = "true"

  tags = {
    Name = "mysubnet"
  }
}
variable "subnet_cidr_block" {
  type    = string
  default = "10.1.1.0/24"
}

resource "aws_route_table" "myrt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }


  tags = {
    Name = "myrt"
  }
}

resource "aws_route_table_association" "myrta" {
  subnet_id      = aws_subnet.mysubnet.id
  route_table_id = aws_route_table.myrt.id
}

variable "sg_name" {
  type    = string
  default = "mysg"
}

resource "aws_security_group" "mysg" {
  name        = "mysg"
  description = "security group"
  vpc_id      = aws_vpc.myvpc.id

  tags = {
    Name = var.sg_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.mysg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.mysg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}



resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.mysg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}



resource "aws_instance" "myinstance" {
  ami = var.ami
  instance_type = var.instance_type
  associate_public_ip_address = var.public_ip_ec2
  subnet_id                   = aws_subnet.mysubnet.id
  user_data                   = file("start.sh")
  vpc_security_group_ids = [aws_security_group.mysg.id]

  tags = {
    Name = var.instance_name
  }
}

variable "ami" {
  type    = string
  default = "ami-04a81a99f5ec58529"
}

variable "instance_type" {
  type    = string
  default ="t2.micro"
}

variable "instance_name" {
  type    = string
  default = "myinstance"
}

variable "public_ip_ec2" {
  type    = bool
  default = "true"
}