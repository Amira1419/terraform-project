resource "aws_subnet" "app-subnet" {
    vpc_id = var.vpc-id
    cidr_block = var.subnet-cidr-block
    availability_zone = var.avail-zone
    tags = {
        Name = "${var.env}-subnet"
    }
}

resource "aws_internet_gateway" "app-igateway" {
    vpc_id = var.vpc-id
    tags = {
        Name = "${var.env}-igateway"
    }
}
resource "aws_route_table" "app-rtb" {
    vpc_id = var.vpc-id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.app-igateway.id
    }
    tags = {
        Name = "${var.env}-rtb"
    }
}

resource "aws_route_table_association" "app-rtb-association" {
    subnet_id       = aws_subnet.app-subnet.id
    route_table_id  = aws_route_table.app-rtb.id

}
