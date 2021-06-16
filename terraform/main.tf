provider "aws" {
  region = "us-east-1"
  profile = "default"
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = "vpc-70b2250d"

  ingress {
    description      = "TLS from VPC"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    }

  tags = {
    Name = "allow_tls"
  }
}
# Create SSH Keys using your local keys
resource "aws_key_pair" "server_key" {
    key_name = "server_key"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDCo2OBjHhs6Qv7gGtA2ThqkWaLHQhahefqJThjXomr1k2alO7y8xp5czxPHpzwCmDThQTUdRtbFzA3R45Df6QZKlexBIW2vTlIkJ4daW+qYLEBjRNqLmxJUL2v3qts+PZ13JCELkNzFGJDh6PSf2xTFjLQRCYVqgXELTS/J9Ea9TOYhAoqERjLBzdnIYMoWXb5krN4JbCyE2Cplc8kMhveukjfz4gGB9lfcdzsvxfeQQ3okhycwPRZ16prV82Crg5v2XSsIMsmUm5M2vZFkVaOGztLSU+bI5lYc0SWPxseqe0ARgWhfzreeGQ2HJprL1JtPRFutJSJy1Cli97MS4nMx8cQdjjORK1O8d/WrvcSidMJeQBqX9Y7kCn7MheG+FZgsY7dg9iHONjN/XJEV+iOI/T/R+Eqtpm0MO2raAAN2y5CpTXB19as6fA+DRjza4nx7nt2HC9OpExX8IiTWlstb8qHBE/AGkq2+VyT7TeaSomVi68iFyeLFbFTCzAWS7k= User@Chris-eCom"
}
# Executing User Data While Instance Launch 
data "template_file" "jen_user_data" {
    template = "${file("${path.module}/templates/jenkins.tpl")}"
}
# Web Server
resource "aws_instance" "jenkins-server" {
    ami = "ami-0747bdcabd34c712a"
    instance_type = "t2.micro"
    key_name = "server_key"
    subnet_id = "subnet-d8034487"
    user_data = "${data.template_file.jen_user_data.rendered}"
    vpc_security_group_ids = [
        "${aws_security_group.allow_tls.id}"
    ]

    tags = {
        Name = "jen-server"
    }  
}