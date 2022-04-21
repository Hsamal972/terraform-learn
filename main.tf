provider "aws" {
    region = "ap-south-1"
    # access_key = "AKIAV2HOUZPVUROGCWOY"
    # secret_key = "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"
}
resource "aws_vpc" "dev-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
      "Name" = "dev-vpc-1"
    }
  
}
resource "aws_subnet" "dev-subnet-1" {
    vpc_id = aws_vpc.dev-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = "ap-south-1b"
    tags = {
      "Name" = "dev-subnet-1"
    }
}
variable "subnet_cidr_block" {
    description = "Subnet cidr block"

}   
# data "aws_vpc" "dev-vpc" {
#     default = true
# }
# resource "aws_subnet" "dev_subnet_2" {
#     vpc_id = data.aws_vpc.dev-vpc.id
#     cidr_block = "172.31.48.0/20"
#     availability_zone = "ap-south-1b"
# }
output "dev-vpc-id" {
    value = aws_vpc.dev-vpc.id
}
output "dev-subnet-id" {
    value = aws_subnet.dev-subnet-1.cidr_block
}