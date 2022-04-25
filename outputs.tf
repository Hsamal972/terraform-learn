output "aws_ami" {
    value = data.aws_ami.latest-ami.id
}

output "public_ip" {
    value = module.myapp-server.myapp-instance.public_ip
}