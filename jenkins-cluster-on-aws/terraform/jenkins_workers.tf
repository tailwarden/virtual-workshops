// Jenkins worker AMI
data "aws_ami" "jenkins_worker" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["jenkins-worker"]
  }
}

// Jenkinw workers security group
resource "aws_security_group" "jenkins_workers_sg" {
  name        = "jenkins_workers_sg"
  description = "Allow traffic on port 22 from Jenkins master SG"

  ingress {
    from_port       = "22"
    to_port         = "22"
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_master_sg.id]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name   = "jenkins_workers_sg"
  }
}

// Jenkins workers launch configuration
resource "aws_launch_configuration" "jenkins_workers_launch_conf" {
  name            = "jenkins_workers_config"
  image_id        = data.aws_ami.jenkins_worker.id
  instance_type   = var.jenkins_worker_instance_type
  key_name        = var.key
  iam_instance_profile = aws_iam_instance_profile.jenkins_instance_profile.name
  security_groups = [aws_security_group.jenkins_workers_sg.id]
  user_data       = templatefile("scripts/join-cluster.tftpl", {
      jenkins_url            = "http://${aws_instance.jenkins_master.private_ip}:8080"
      jenkins_username       = var.jenkins_username
      jenkins_password       = var.jenkins_password
      jenkins_credentials_id = var.jenkins_credentials_id
  }) 

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 30
    delete_on_termination = false
  }

  lifecycle {
    create_before_destroy = true
  }
}

// ASG Jenkins workers
resource "aws_autoscaling_group" "jenkins_workers" {
  name                 = "jenkins_workers_asg"
  launch_configuration = aws_launch_configuration.jenkins_workers_launch_conf.name
  vpc_zone_identifier  = var.subnets
  min_size             = 2
  max_size             = 10

  depends_on = [aws_instance.jenkins_master, aws_elb.jenkins_elb]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "jenkins_worker"
    propagate_at_launch = true
  }
}