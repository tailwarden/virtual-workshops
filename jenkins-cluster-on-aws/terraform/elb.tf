
resource "aws_security_group" "jenkins_elb_sg" {
  name        = "jenkins_elb_sg"
  description = "Allow http & https traffic"
  
  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name   = "jenkins_elb_sg"
  }
}

resource "aws_elb" "jenkins_elb" {
  subnets                   = var.subnets
  cross_zone_load_balancing = true
  security_groups           = [aws_security_group.jenkins_elb_sg.id]
  instances                 = [aws_instance.jenkins_master.id]

  listener {
    instance_port      = 8080
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = var.ssl_arn
  }

  listener {
    instance_port      = 8080
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"

  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:8080"
    interval            = 5
  }

  tags = {
    Name   = "jenkins_elb"
  }
}