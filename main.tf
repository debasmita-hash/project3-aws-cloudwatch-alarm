terraform {
 required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = "~> 6.0"
   }
 }
}
# AWS Provider
provider "aws" {
 region = "ap-south-1"
}
# Get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
 most_recent = true
 owners      = ["amazon"]
 filter {
   name   = "name"
   values = ["al2023-ami-*-x86_64"]
 }
 filter {
   name   = "architecture"
   values = ["x86_64"]
 }
 filter {
   name   = "root-device-type"
   values = ["ebs"]
 }
 filter {
   name   = "virtualization-type"
   values = ["hvm"]
 }
}
# Create EC2 Instance
resource "aws_instance" "project3" {
 ami           = data.aws_ami.amazon_linux.id
 instance_type = "t2.micro"
 monitoring = false
 user_data = <<-EOF
   #!/bin/bash
   nohup timeout 600 bash -c 'while true; do :; done' >/dev/null 2>&1 &
 EOF
 tags = {
   Name        = "Project3-CloudWatch-EC2"
   Environment = "Capstone"
 }
}
# Create CloudWatch CPU Alarm
resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
 alarm_name          = "Project3-EC2-High-CPU"
 comparison_operator = "GreaterThanThreshold"
 evaluation_periods  = 1
 metric_name         = "CPUUtilization"
 namespace           = "AWS/EC2"
 period              = 300
 statistic           = "Average"
 threshold           = 70
 alarm_description   = "Alarm when EC2 CPU utilization exceeds 70 percent"
 dimensions = {
   InstanceId = aws_instance.project3.id
 }
 treat_missing_data = "notBreaching"
}
# Output EC2 Instance ID
output "instance_id" {
 value = aws_instance.project3.id
}
# Output EC2 Public IP
output "public_ip" {
 value = aws_instance.project3.public_ip
}
# Output CloudWatch Alarm Name
output "alarm_name" {
 value = aws_cloudwatch_metric_alarm.cpu_alarm.alarm_name
}
