resource "aws_security_group" "vpn_sg" {
  name        = "${var.project}-${var.vpc_environment}-pritunl-sg"
  description = "AWS security group for vpn"
  vpc_id      =  module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    ManagedBy = "DevOps"
    Project   = var.project
    Env       = var.vpc_environment
  }
}

locals {
  sg = [
    "11227|udp|0.0.0.0/0",
    "22|tcp|0.0.0.0/0",
    "443|tcp|0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "allow_ingress" {
  for_each          = toset(local.sg)
  from_port         = element(split("|", each.key), 0)
  to_port           = element(split("|", each.key), 0)
  protocol          = element(split("|", each.key), 1)
  security_group_id = aws_security_group.vpn_sg.id
  type              = "ingress"
  cidr_blocks       = flatten([split(",", element(split("|", each.key), 2))])
}
