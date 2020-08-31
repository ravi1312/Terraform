resource "aws_instance" "terraform" {
  ami = var.ami-id
  instance_type = "t2.micro"

  key_name = var.key_name
  tags = {
    name = "terraform"
  }
  availability_zone = "us-east-1a"
  user_data = <<-EOF
                #!/bin/bash -x
                sudo apt-get update
                sudo apt-get install apache2 -y
                echo "my hostname will be $(hostname)" > /var/www/html/index.html

                EOF

}
resource "aws_eip" "elasticip" {
  instance = aws_instance.terraform.id
  vpc = true
}
resource "aws_eip_association" "elastic" {
  instance_id = aws_instance.terraform.id
  allocation_id = aws_eip.elasticip.id
}
