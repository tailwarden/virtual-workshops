data "aws_ami" "jenkins_master" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["jenkins-master"]
  }
}

  
resource "aws_security_group" "jenkins_master_sg" {
  name        = "jenkins_master_sg"
  description = "Allow traffic on port 8080 and enable SSH"

  ingress {
    from_port       = "22"
    to_port         = "22"
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = "8080"
    to_port         = "8080"
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_elb_sg.id]
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name   = "jenkins_master_sg"
  }
}

resource "aws_instance" "jenkins_master" {
  ami                    = data.aws_ami.jenkins_master.id
  instance_type          = var.jenkins_master_instance_type
  key_name               = var.key
  vpc_security_group_ids = [aws_security_group.jenkins_master_sg.id]

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = false
  }

  tags = {
    Name   = "jenkins_master"
  }
}