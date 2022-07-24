# ====================
#
# IAM Group
#
# ====================
resource "aws_iam_group" "developers" {
  name = "developers"
}
# ====================
#
# IAM Groop Policy
#
# ====================
resource "aws_iam_policy" "developer_policy" {
  name        = "my_developer_policy"
  description = "A IAM policy for Developers."
  policy      = file("./policies/instance_policy.json")
}

resource "aws_iam_group_policy_attachment" "developer_policy_attach" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.developer_policy.arn
}

# ====================
#
# IAM User
#
# ====================
resource "aws_iam_user" "developer1" {
  name          = "developer1"
  path          = "/system/"
  force_destroy = true

  tags = {
    tag-key = "developer1"
  }
}

resource "aws_iam_group_membership" "team" {
  name = "developer_group_membership"

  users = [
    aws_iam_user.developer1.name,
  ]

  group = aws_iam_group.developers.name
}

resource "aws_iam_access_key" "developer1_access_key" {
  user = aws_iam_user.developer1.name
}
