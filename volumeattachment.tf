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
resource "aws_ebs_volume" "volume" {
  availability_zone = aws_instance.terraform.availability_zone
  size = 16
}
resource "aws_volume_attachment" "attach" {
  device_name = "/dev/sdh"
  instance_id = aws_instance.terraform.id
  volume_id = aws_ebs_volume.volume.id
