terraform {
  backend "s3" {
    bucket = "jkidd-bucket"
    key = "tstate/statfile"
    region = "us-east-1" 
  }
}

provider "aws" {
   version = "~> 2.0"
   region = var.region
}

provider "aws" {
  version = "~> 2.0"
  region = var.region_be
  alias = "back_end"
}

resource "aws_instance" "front-end" {
  ami = data.aws_ami.ubuntu_fe.id
  instance_type = "t2.micro"
  key_name = "kiddcorp"
  tags = {
    Name = "HelloEC2"
  }
  security_groups = ["default"]
  depends_on = [aws_instance.back-end]
  provisioner "remote-exec" {
      inline = ["sudo apt-get -y update",
                "sudo apt-get -y install nginx",
                "sudo service nginx start"]
      connection {
        host = self.public_ip
        type = "ssh"
        user = "ubuntu"
        private_key = file("/Users/jwkidd3/terra_cred/kiddcorp")
      }
   }
}
resource "aws_instance" "back-end" {
  ami = data.aws_ami.ubuntu_be.id
  instance_type = "t2.micro"
  key_name = "kiddcorp"
  provider = aws.back_end
  tags = {
    Name = "HelloEC2"
  }
  security_groups = ["default"]
}
