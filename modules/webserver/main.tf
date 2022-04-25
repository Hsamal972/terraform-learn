resource "aws_security_group" "myapp-sg" {
    name = "${var.env_prefix}-sg"
    vpc_id = var.vpc_id
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




resource "aws_instance" "myapp-instance" {
    ami = var.instance_id
    instance_type = "t2.micro"
    availability_zone = "ap-south-1b"
    subnet_id = var.subnet_id
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
    # provisioner "remote-exec" {
    #     inline = [
    #      "sudo yum install tree",
    #      "cd /tmp",
    #      "mkdir new" 
    #     ]
    # }
    # connection {
    #   type = "ssh"
    #   host = self.public_ip
    #   user = "ec2-user"
    #   private_key = file("C:\\Users\\doome\\.ssh\\id_rsa")
    # }
}

resource "aws_key_pair" "ssh_key" {
    key_name = "server-key"
    public_key = file("C:\\Users\\doome\\.ssh\\id_rsa.pub")
}
