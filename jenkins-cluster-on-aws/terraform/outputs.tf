output "jenkins-master-elb" {
  value = aws_elb.jenkins_elb.dns_name
}

output "jenkins-dns" {
  value = "https://${aws_route53_record.jenkins_master.name}"
}