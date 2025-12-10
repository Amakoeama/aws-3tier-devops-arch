#--- Load Balancer ---
resource "aws_lb" "app_alb" {
  name               = "3tier-app-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets = [
    aws_subnet.public[0].id,
    aws_subnet.public[1].id
  ]

  tags = {
    Name = "3tier-app-alb"
  }
}

#--- Target group for LB to send traffic ---
resource "aws_lb_target_group" "app_tg" {
  name        = "3tier-app-tg-8000"
  port        = 8000
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    interval            = 15
    path                = "/"
    port                = "8000"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "3tier-app-tg"
  }
  lifecycle {
    create_before_destroy = true
  }
}

#--- target group EC2 registration ---
# Tells ALB to send traffic to ec2 instance's on port 80
resource "aws_lb_target_group_attachment" "app_tg_attachment" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.app_server.id
  port             = 8000
}
#--- Listener ALB port 80 ---
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
  lifecycle {
    create_before_destroy = true
  }
}
 