provider "aws" {
    region = "us-east-1"
}

variable env {}
variable avail-zone {}
variable device-ip {
  type        = string
  description = "Enter Your Device IP Address: "
}
variable vpc-cidr-block {}
variable subnet-cidr-block {}
variable instance-type {}
variable public-key-loc {}


resource "aws_vpc" "app-vpc"{
    cidr_block = var.vpc-cidr-block
    tags = {
        Name = "${var.env}-vpc"
    }
}
resource "aws_subnet" "app-subnet" {
    vpc_id = aws_vpc.app-vpc.id
    cidr_block = var.subnet-cidr-block
    availability_zone = var.avail-zone
    tags = {
        Name = "${var.env}-subnet"
    }
}

resource "aws_internet_gateway" "app-igateway" {
    vpc_id = aws_vpc.app-vpc.id
    tags = {
        Name = "${var.env}-igateway"
    }
}
resource "aws_default_route_table" "main-app-rtb" {
    default_route_table_id = aws_vpc.app-vpc.default_route_table_id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.app-igateway.id
    }
    tags = {
        Name = "${var.env}-main-rtb"
    }
}

resource "aws_security_group" "app-sec-group"{
    name   = "app-sec-group"
    vpc_id = aws_vpc.app-vpc.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.device-ip]
    }
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    } 
    tags = {
        Name = "${var.env}-sg"
    }   
}

data "aws_ami" "amazon-linux-image" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-*-x86_64-gp2"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

resource "aws_key_pair" "ssh-key" {
    key_name = "app-key"
    public_key = file(var.public-key-loc)
}

resource "aws_instance" "app-server" {
    ami = data.aws_ami.amazon-linux-image.id
    instance_type = var.instance-type
    subnet_id = aws_subnet.app-subnet.id
    vpc_security_group_ids = [aws_security_group.app-sec-group.id]
    associate_public_ip_address = true
    key_name = aws_key_pair.ssh-key.key_name
    availability_zone = var.avail-zone
    user_data = file("run_nginx_docker.sh")
    tags = {
        Name = "${var.env}-app-server"
    }
}

output ami_id {
  value       =  data.aws_ami.amazon-linux-image.id
}

output server-ip {
  value       =  aws_instance.app-server.public_ip
}
