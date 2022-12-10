resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block #"10.4.0.0/16"

  tags = {
    Name = "team2-vpc"
  }
}

resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_block_1 #"10.4.5.0/24"
  availability_zone = var.zone1               #"us-east-1a"

  tags = {
    Name = "Public1-team2"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_block_2 #"10.4.3.0/24"
  availability_zone = var.zone2               #"us-east-1b"

  tags = {
    Name = "Public2-team2"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "IGW-team2"
  }
}

resource "aws_route_table" "example" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "route_table-team2"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.example.id
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.example.id
}

