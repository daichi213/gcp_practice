# リージョン
aws_region = "ap-northeast-1"

# AWS App Runner のサービス名
service_name = "sample-apprun"

# Spot Instance Availability Zone
spot_instance_region = {
  us-east-2 : "us-east-2",
  us-east-1 : "us-east-1",
  us-west-1 : "us-west-1",
  us-west-2 : "us-west-2",
  af-south-1 : "af-south-1",
  ap-east-1 : "ap-east-1",
  ap-south-1 : "ap-south-1",
  ap-northeast-3 : "ap-northeast-3",
  ap-northeast-2 : "ap-northeast-2",
  ap-southeast-1 : "ap-southeast-1",
  ap-southeast-2 : "ap-southeast-2",
  ap-northeast-1 : "ap-northeast-1",
  ca-central-1 : "ca-central-1",
  cn-north-1 : "cn-north-1",
  cn-northwest-1 : "cn-northwest-1",
  eu-central-1 : "eu-central-1",
  eu-west-1 : "eu-west-1",
  eu-west-2 : "eu-west-2",
  eu-south-1 : "eu-south-1",
  eu-west-3 : "eu-west-3",
  eu-north-1 : "eu-north-1",
  me-south-1 : "me-south-1",
  sa-east-1 : "sa-east-1"
}

# Spot Instance number
spot_instance_num = 1

# Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type
# spot_instance_ami = "ami-0b7546e839d7ace12"
# Ubuntu
spot_instance_ami = "ami-07200fa04af91f087"

spot_instance_type = "t2.large"

gp2_volume_size = "12"

gp2_volume_type = "gp2"
