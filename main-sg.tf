resource "aws_security_group" "allow_ssh_http_https" {
  vpc_id = aws_vpc.main_vpc.id

  dynamic "ingress" {
    for_each = { for key, rule in var.sg_settings : key => rule if rule.type == "ingress" }

    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ["0.0.0.0/0"]
    }
  }


  dynamic "egress" {
    for_each = { for key, rule in var.sg_settings : key => rule if rule.type == "egress" }

    content {
      description = egress.value.description
      from_port   = egress.value.port
      to_port     = egress.value.port
      protocol    = egress.value.protocol
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = {
    Name = "${var.env}-allow-ssh-http-http"
  }

}
