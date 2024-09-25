provider "aws" {
    region = "us-east-1"
}

resource "aws_vpc" "app-vpc"{
    cidr_block = var.vpc-cidr-block
    tags = {
        Name = "${var.env}-vpc"
    }
}

module "app-network" {
    source = "./modules/network"
    vpc-id = aws_vpc.app-vpc.id
    subnet-cidr-block = var.subnet-cidr-block
    avail-zone = var.avail-zone
    env = var.env
}

module "app-server" {
    source = "./modules/server"
    vpc-id = aws_vpc.app-vpc.id
    subnet-id = module.app-network.app-subnet-id
    avail-zone = var.avail-zone
    env = var.env
    device-ip = var.device-ip
    instance-type = var.instance-type
    public-key-loc = var.public-key-loc
}





