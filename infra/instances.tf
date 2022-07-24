locals {

  dev_instance = {
    name = "${var.service_name}_dev_instance"
  }
  prod_instance = {
    name = "${var.service_name}_prod_instance"
  }

  spot_instance_region = {
    value = "${var.spot_instance_region.ap-northeast-1}"
  }

}

# ====================
#
# VPC
#
# ====================
resource "aws_vpc" "myapp_vpc" {
  cidr_block                       = "10.1.0.0/16"
  enable_dns_hostnames             = true
  enable_dns_support               = true
  instance_tenancy                 = "default"
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name = "${var.service_name}_vpc"
  }
}

# ====================
#
# Internet Gateway
#
# ====================
resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.myapp_vpc.id

  tags = {
    Name = "${var.service_name}_gw"
  }
}
# ====================
#
# Subnet
#
# ====================
resource "aws_subnet" "public_1a" {
  vpc_id = aws_vpc.myapp_vpc.id
  # TODO 修正
  cidr_block        = "10.1.0.0/24"
  availability_zone = "${local.spot_instance_region.value}a"
  # trueにするとインスタンスにパブリックIPアドレスを自動的に割り当ててくれる
  map_public_ip_on_launch = false

  tags = {
    Name = "public_1a"
  }
}

resource "aws_subnet" "public_1c" {
  vpc_id            = aws_vpc.myapp_vpc.id
  cidr_block        = "10.1.20.0/24"
  availability_zone = "${local.spot_instance_region.value}c"
  # trueにするとインスタンスにパブリックIPアドレスを自動的に割り当ててくれる
  map_public_ip_on_launch = false

  tags = {
    Name = "public_1b"
  }
}

# ====================
#
# Route Table
#
# ====================
resource "aws_route_table" "myapp_route_table" {
  vpc_id = aws_vpc.myapp_vpc.id

  tags = {
    Name = "${var.service_name}_route_table"
  }
}

resource "aws_route" "my_app_route" {
  gateway_id             = aws_internet_gateway.internet_gw.id
  route_table_id         = aws_route_table.myapp_route_table.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "example" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.myapp_route_table.id
}

resource "aws_route_table_association" "pubic_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.myapp_route_table.id
}

# ====================
#
# Security Group
#
# ====================
resource "aws_security_group" "security_rule" {
  vpc_id = aws_vpc.myapp_vpc.id
  name   = "${var.service_name}_security_rule"

  tags = {
    Name = "${var.service_name}_security_rule"
  }
}

# インバウンドルール(ssh接続用)
resource "aws_security_group_rule" "in_ssh" {
  security_group_id = aws_security_group.security_rule.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
}

# インバウンドルール(pingコマンド用)
resource "aws_security_group_rule" "in_icmp" {
  security_group_id = aws_security_group.security_rule.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
}

# インバウンドルール(httpアクセス用)
resource "aws_security_group_rule" "in_http" {
  security_group_id = aws_security_group.security_rule.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
}

# インバウンドルール(Develop httpアクセス用)
resource "aws_security_group_rule" "in_http_dev" {
  security_group_id = aws_security_group.security_rule.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 3030
  to_port           = 3030
  protocol          = "tcp"
}

# アウトバウンドルール(全開放)
resource "aws_security_group_rule" "out_all" {
  security_group_id = aws_security_group.security_rule.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}

# ====================
#
# Elastic IP
#
# ====================
# resource "aws_eip" "dev_eip" {
#   instance   = aws_spot_fleet_request.spot_instance_dev.id
#   vpc        = true
#   depends_on = [aws_internet_gateway.internet_gw, aws_spot_fleet_request.spot_instance_dev]
# }

# resource "aws_eip" "prod_eip" {
#   instance   = aws_spot_fleet_request.spot_instance_prod.id
#   vpc        = true
#   depends_on = [aws_internet_gateway.internet_gw]
# }

# ====================
#
# Elastic IP Association
#
# ====================
# resource "aws_eip_association" "dev_eip_assoc" {
#   instance_id   = aws_spot_fleet_request.spot_instance_dev.id
#   allocation_id = aws_eip.dev_eip.id
# }

# ====================
#
# EC2 Instance Develop
#
# ====================
# resource "aws_instance" "locker_app_instance" {
#   ami                    = "ami-0ce107ae7af2e92b5"
#   vpc_security_group_ids = [aws_security_group.security_rule.id]
#   subnet_id              = aws_subnet.public_1a.id
#   key_name               = aws_key_pair.my_key_pair.id
#   instance_type          = "t2.micro"
#   monitoring             = false
#   tags = {
#     Name = "${var.service_name}_development"
#   }
#   lifecycle {
#     prevent_destroy = true
#   }
# }

# ====================
#
# EC2 Instance Production
#
# ====================
# resource "aws_instance" "locker_app_instance" {
#   ami                    = "ami-0ce107ae7af2e92b5"
#   vpc_security_group_ids = [aws_security_group.security_rule.id]
#   subnet_id              = aws_subnet.public_1a.id
#   key_name               = aws_key_pair.my_key_pair.id
#   instance_type          = "t2.micro"
#   monitoring             = false
#   tags = {
#     Name = "${var.service_name}_production"
#   }
#   lifecycle {
#     prevent_destroy = true
#   }
# }


# ====================
#
# EC2 Spot Instance Development
#
# ====================
resource "aws_spot_fleet_request" "spot_instance_dev" {
  iam_fleet_role = aws_iam_role.instance_role.arn

  # spot_price      = "0.1290" # Max Price デフォルトはOn-demand Price
  target_capacity                     = var.spot_instance_num
  terminate_instances_with_expiration = true
  wait_for_fulfillment                = true # fulfillするまでTerraformが待つ

  launch_specification {
    ami                         = var.spot_instance_ami
    instance_type               = var.spot_instance_type
    key_name                    = aws_key_pair.my_key_pair.key_name
    vpc_security_group_ids      = ["${aws_security_group.security_rule.id}"]
    subnet_id                   = aws_subnet.public_1a.id
    associate_public_ip_address = true

    root_block_device {
      volume_size = var.gp2_volume_size
      volume_type = var.gp2_volume_type
    }

    tags = {
      Name = local.dev_instance.name
    }
  }
}

# ====================
#
# EC2 Spot Instance Production
#
# ====================
# resource "aws_spot_fleet_request" "spot_instance_prod" {
#   iam_fleet_role = aws_iam_role.instance_role.arn

#   # spot_price      = "0.1290" # Max Price デフォルトはOn-demand Price
#   target_capacity                     = var.spot_instance_num
#   terminate_instances_with_expiration = true
#   wait_for_fulfillment                = "true" # fulfillするまでTerraformが待つ

#   launch_specification {
#     ami                         = var.spot_instance_ami
#     instance_type               = var.spot_instance_type
#     key_name                    = aws_key_pair.my_key_pair.key_name
#     vpc_security_group_ids      = ["${aws_security_group.security_rule.id}"]
#     subnet_id                   = aws_subnet.public_1a.id
#     associate_public_ip_address = true

#     root_block_device {
#       volume_size = var.gp2_volume_size
#       volume_type = var.gp2_volume_type
#     }

#     tags = {
#       Name = local.prod_instance.name
#     }
#   }
# }

# ====================
#
# Key Pair
#
# ====================
resource "aws_key_pair" "my_key_pair" {
  key_name   = "id_rsa"
  public_key = file("./keys/id_rsa.pub")
}

# ====================
#
# Data Instance
#
# ====================
data "aws_instances" "instances" {
  instance_state_names = ["running", "stopped"]
}
