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
resource "aws_ami_from_instance" "ami" {
  name = "terraform"
  source_instance_id = aws_instance.terraform.id
}
resource "aws_instance" "ami_instance" {
  ami = aws_ami_from_instance.ami.id
  instance_type = var.instance_type
  key_name = var.key_name
}
