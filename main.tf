provider "aws" {
    region = "ap-south-1"
}
variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
      "Name" = "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
      "Name" = "${var.env_prefix}-subnet-1"
    }
}


resource "aws_route_table" "myapp-route-table" {
    vpc_id = aws_vpc.myapp-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-internet-gateway.id
    }
    tags = {
      "Name" = "${var.env_prefix}-route-table"
    }
}

resource "aws_internet_gateway" "myapp-internet-gateway" {
    vpc_id = aws_vpc.myapp-vpc.id
}

# resource "aws_route_table_association" "myapp-rtb-association" {
#     subnet_id = aws_subnet.myapp-subnet-1.id
#     route_table_id = aws_route_table.myapp-route-table.id
  
# }

# output "aws_ami" {
#     value = data.aws_ami.latest-ami.id
# }

resource "aws_default_route_table" "default-rtb" {
    default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-internet-gateway.id
    }
}

resource "aws_security_group" "myapp-sg" {
    name = "${var.env_prefix}-sg"
    vpc_id = aws_vpc.myapp-vpc.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
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
      "Name" = "${var.env_prefix}-sg"
    }  
}

data "aws_ami" "latest-ami"{
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-kernel-*-x86_64-gp2"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}


resource "aws_instance" "myapp-instance" {
    ami = data.aws_ami.latest-ami.id
    instance_type = "t2.micro"
    availability_zone = "ap-south-1b"
    subnet_id = aws_subnet.myapp-subnet-1.id
    vpc_security_group_ids = [aws_security_group.myapp-sg.id]
    associate_public_ip_address = true
    key_name = aws_key_pair.ssh_key.key_name
    tags = {
      "Name" = "${var.env_prefix}-instance"
    }
    user_data = <<EOF
                #!/bin/bash
                sudo yum update -y
                sudo yum install docker -y
                sudo systemctl start docker
                sudo usermod -aG docker ec2-user
                docker run -p 8080:80 nginx
                EOF
}

resource "aws_key_pair" "ssh_key" {
    key_name = "server-key"
    public_key = file("C:\\Users\\doome\\.ssh\\id_rsa.pub")
}

