locals {
  ## instance role
  instance_role = {
    name = "${var.service_name}_instance_role"

    policy-01 = {
      name = "${var.service_name}_instance_policy"
    }

    profile = {
      name = "${var.service_name}_profile"
    }
  }
}


# ====================
#
# Instance Role
#
# ====================
resource "aws_iam_instance_profile" "instance_role" {
  name = local.instance_role.profile["name"]
  role = aws_iam_role.instance_role.name
}

resource "aws_iam_role" "instance_role" {
  name               = local.instance_role["name"]
  description        = "The role for a instance with jenkins"
  assume_role_policy = file("./roles/instance_role.json")
}


# ====================
#
# Instance Policy
#
# ====================
resource "aws_iam_policy" "instance_policy" {
  name   = local.instance_role.policy-01["name"]
  policy = file("./policies/instance_policy.json")
}

resource "aws_iam_role_policy_attachment" "instance_policy_attach" {
  policy_arn = aws_iam_policy.instance_policy.arn
  role       = aws_iam_role.instance_role.id
}
