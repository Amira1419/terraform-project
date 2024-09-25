resource "aws_security_group" "app-sec-group"{
    name   = "app-sec-group"
    vpc_id = var.vpc-id
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
    subnet_id = var.subnet-id
    vpc_security_group_ids = [aws_security_group.app-sec-group.id]
    associate_public_ip_address = true
    key_name = aws_key_pair.ssh-key.key_name
    availability_zone = var.avail-zone
    user_data = file("./run_nginx_docker.sh")
    tags = {
        Name = "${var.env}-app-server"
    }
}