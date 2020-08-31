resource "aws_instance" "MyFirstEc2instance_from_terraform" {
  ami = var.ami-id
  instance_type = "t2.micro"
  tags = {
    Name = "EC2started_from_console_from_terraform"
  }
  key_name = "testing"
  availability_zone = "us-east-1b"
  user_data = <<-EOF
                #!/bin/bash -x
                sudo apt-get update
                sudo apt-get install apache2 -y
                echo "my hostname will be $(hostname)" > /var/www/html/index.html

                EOF

}
resource "aws_instance" "terraform" {
  ami = var.ami-id
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = var.key_name
  tags = {
    Name = "testing"

  }
  user_data = <<-EOF
                #!/bin/bash -x
                sudo apt-get update
                sudo apt-get install apache2 -y
                echo "my hostname will be remote" > /var/www/html/index.html

                EOF
}

resource "aws_lb" "loadbalancer" {
  name = "test-loadbalancer"
  internal = false
  load_balancer_type = "application"
  security_groups = ["sg-94e8d1c3"]
  subnets = [aws_instance.terraform.subnet_id,aws_instance.MyFirstEc2instance_from_terraform.subnet_id]
}
resource "aws_lb_target_group" "target_lb" {
  name = "terraform"
  vpc_id = "vpc-73391f09"
  port = 80
  protocol = "HTTP"
  target_type = "instance"

}
resource "aws_lb_target_group_attachment" "first" {
  target_group_arn = aws_lb_target_group.target_lb.arn
  target_id        = aws_instance.MyFirstEc2instance_from_terraform.id
  port             = 80

}
resource "aws_lb_target_group_attachment" "second" {
  target_group_arn = aws_lb_target_group.target_lb.arn
  target_id        = aws_instance.terraform.id
  port             = 80
}
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.loadbalancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_lb.arn
  }
}
