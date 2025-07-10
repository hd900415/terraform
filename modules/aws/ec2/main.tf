terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.2.0"
    }
  }
}


resource "aws_instance"  "web" {
  count                 = var.instance_count
  ami                    = var.amis[count.index]
  instance_type          = var.instance_types[count.index]
  subnet_id              = var.subnet_ids[count.index]
  vpc_security_group_ids = var.security_group_ids_list[count.index]
  key_name               = "terraform-key"
  root_block_device {
    volume_type = "gp3"
    volume_size = var.volume_sizes[count.index]
  }

  tags = {
    Name = "ec2-${var.instance_names[count.index]}-${var.env}"
  }
}

resource "aws_eip" "web" {
  count = var.instance_count
  domain = "vpc"

  tags = {
    Name = "eip-${var.instance_names[count.index]}-${var.env}"
  }
}

resource "aws_eip_association" "web" {
  count         = var.instance_count
  instance_id   = aws_instance.web[count.index].id
  allocation_id = aws_eip.web[count.index].id
}


