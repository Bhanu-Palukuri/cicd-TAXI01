provider "aws" {
  region = "eu-west-1" # Ensure this matches your resources
}

resource "aws_instance" "taxi_server_23413999" {
  ami           = "ami-032a56ad5e480189c"
  instance_type = "t2.medium"
  key_name      = "pam01"

  vpc_security_group_ids = [aws_security_group.demo_sg.id]
  subnet_id              = aws_subnet.dpp-public-subnet-01.id

  for_each = toset(["jenkins-master", "build-slave", "ansible"]) # Fixed invalid key

  tags = {
    Name = "${each.key}"
  }
}

resource "aws_security_group" "demo_sg" { # Fixed naming issue
  name        = "demo-sg"
  description = "SSH Access"
  vpc_id      = aws_vpc.dpp-vpc.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Container port"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS port"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ssh-port"
  }
}

resource "aws_vpc" "dpp-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "dpp-vpc"
  }
}

resource "aws_subnet" "dpp-public-subnet-01" {
  vpc_id                  = aws_vpc.dpp-vpc.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = true        # Fixed boolean value
  availability_zone       = "eu-west-1a" # Ensure this matches the provider region
  tags = {
    Name = "dpp-public-subent-01"
  }
}

resource "aws_subnet" "dpp-public-subnet-02" {
  vpc_id                  = aws_vpc.dpp-vpc.id
  cidr_block              = "10.1.2.0/24"
  map_public_ip_on_launch = true        # Fixed boolean value
  availability_zone       = "eu-west-1a" # Ensure this matches the provider region
  tags = {
    Name = "dpp-public-subent-02"
  }
}

resource "aws_internet_gateway" "dpp-igw" {
  vpc_id = aws_vpc.dpp-vpc.id
  tags = {
    Name = "dpp-igw"
  }
}

resource "aws_route_table" "dpp-public-rt" {
  vpc_id = aws_vpc.dpp-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dpp-igw.id
  }
}

resource "aws_route_table_association" "dpp-rta-public-subnet-01" {
  subnet_id      = aws_subnet.dpp-public-subnet-01.id
  route_table_id = aws_route_table.dpp-public-rt.id
}

resource "aws_route_table_association" "dpp-rta-public-subnet-02" {
  subnet_id      = aws_subnet.dpp-public-subnet-02.id
  route_table_id = aws_route_table.dpp-public-rt.id
}
