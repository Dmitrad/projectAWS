resource "aws_launch_configuration" "images" {
  name                        = "images"
  image_id                    = data.aws_ami.example.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  security_groups             = [aws_security_group.allow_tls.id]
  user_data                   = file(var.user_data_file)
  key_name                    = var.ssh_key_name
  # tags                        = var.tag_images
}

resource "aws_launch_configuration" "videos" {
  name                        = "videos"
  image_id                    = data.aws_ami.example.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  security_groups             = [aws_security_group.allow_tls.id]
  user_data                   = file(var.user_data_file_videos)
  key_name                    = var.ssh_key_name
  # tags                         = var.tag_videos
  
}

resource "aws_autoscaling_group" "images" {
  name                 = "images"
  max_size             = 2
  min_size             = 1
  desired_capacity     = 1
  force_delete         = false
  launch_configuration = aws_launch_configuration.images.name
  vpc_zone_identifier  = [aws_subnet.public_1.id]

  tag {
    key                 = "images"
    value               = "yes"
    propagate_at_launch = true
  }

}

resource "aws_autoscaling_policy" "images" {
  name                   = "cpu-policy-images"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 100
  autoscaling_group_name = aws_autoscaling_group.images.name
  policy_type = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "images" {
  alarm_name                = "images-cpu-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "60"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []

 dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.images.name
  }
  # alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.images.arn]
}

resource "aws_autoscaling_policy" "images_down" {
  name                   = "cpu-policy-imagesdown"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 100
  autoscaling_group_name = aws_autoscaling_group.images.name
  policy_type = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "images_down" {
  alarm_name                = "imagesdown-cpu-alarm"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "50"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []

 dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.images.name
  }
  # alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.images_down.arn]
}

resource "aws_autoscaling_group" "videos" {
  name                 = "videos"
  max_size             = 2
  min_size             = 1
  desired_capacity     = 1
  force_delete         = false
  launch_configuration = aws_launch_configuration.videos.name
  vpc_zone_identifier  = [aws_subnet.public_1.id]

  tag {
    key                 = "videos"
    value               = "yes"
    propagate_at_launch = true
  }

}

resource "aws_autoscaling_policy" "videos" {
  name                   = "cpu-policy-videos"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 100
  autoscaling_group_name = aws_autoscaling_group.videos.name
  policy_type = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "videos" {
  alarm_name                = "videos-cpu-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "60"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []

 dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.videos.name
  }
  # alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.videos.arn]
}

resource "aws_autoscaling_policy" "videos_down" {
  name                   = "cpu-policy-videosdown"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 100
  autoscaling_group_name = aws_autoscaling_group.videos.name
  policy_type = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "videos_down" {
  alarm_name                = "videosdown-cpu-alarm"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "50"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []

 dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.videos.name
  }
  # alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.videos_down.arn]
}


resource "aws_lb" "devops" {
  name               = "team2"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_tls.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  enable_deletion_protection = false


  tags = {
    Environment = "project"
  }
}

resource "aws_lb_target_group" "images" {
  name     = "images-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    port                = "traffic-port"
    path                = "/"
    matcher             = "200-320" #success code

  }
}

resource "aws_lb_target_group" "videos" {
  name     = "videos-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    port                = "traffic-port"
    path                = "/"
    matcher             = "200-320" #success code

  }
}

# Create a new ALB Target Group attachment Images
resource "aws_autoscaling_attachment" "asg_attachment_images" {
  autoscaling_group_name = aws_autoscaling_group.images.id
  lb_target_group_arn    = aws_lb_target_group.images.arn
}

# Create a new ALB Target Group attachment Videos
resource "aws_autoscaling_attachment" "asg_attachment_videos" {
  autoscaling_group_name = aws_autoscaling_group.videos.id
  lb_target_group_arn    = aws_lb_target_group.videos.arn
}


resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.devops.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.images.arn
  }
}

resource "aws_lb_listener_rule" "rule_1_images" {
  listener_arn = aws_lb_listener.lb_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.images.arn
  }

  condition {
    path_pattern {
      values = ["/images/"]
    }
  }
}

resource "aws_lb_listener_rule" "rule_1_videos" {
  listener_arn = aws_lb_listener.lb_listener.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.videos.arn
  }

  condition {
    path_pattern {
      values = ["/videos/"]
    }
  }

}
