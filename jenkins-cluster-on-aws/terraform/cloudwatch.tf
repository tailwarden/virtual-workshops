// Scale out
resource "aws_cloudwatch_metric_alarm" "high_cpu_jenkins_workers_alarm" {
  alarm_name          = "high_cpu_jenkins_workers_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.jenkins_workers.name
  }

  alarm_description = "This metric monitors workers cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.scale_out.arn]
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale_out_jenkins_workers"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.jenkins_workers.name
}

// Scale In
resource "aws_cloudwatch_metric_alarm" "low_cpu_jenkins_workers_alarm" {
  alarm_name          = "low_cpu_jenkins_workers_alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "20"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.jenkins_workers.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.scale_in.arn]
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "scale_in_jenkins_workers"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.jenkins_workers.name
}