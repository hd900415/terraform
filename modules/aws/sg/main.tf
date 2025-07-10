resource "aws_security_group" "web" {
  name        = "web-sg-${var.env}"
  description = "Allow SSH and HTTP"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg-${var.env}"
  }
}

resource "aws_security_group" "Allow-from-office" {
  description       = "Allow SSH from office IP"
  name              = "Allow-from-office-${var.env}"
  vpc_id            = var.vpc_id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.office_ip_cidr]
  }
  egress  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Allow-from-office-${var.env}"
  }
}
resource "aws_security_group" "test" {
    name_prefix = "test-sg-${var.env}-"
    description = "Security group for test instance"
    vpc_id      = var.vpc_id

    # 为 test 实例定制的入站规则
    ingress {
      description = "SSH from anywhere"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
      description = "Custom application port"
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
      description = "Custom application port"
      from_port   = 9443
      to_port     = 9443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    # 其他 test 专用规则...

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "test-sg-${var.env}"
    }
}

resource "aws_security_group" "whitelist" {
  description       = "Allow all traffic from whitelist IP"
  name              = "Allow-from-whitelist-${var.env}"
  vpc_id            = var.vpc_id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.whitelist_cidrs
  }
  egress  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Allow-from-whitelist-${var.env}"
  }
}