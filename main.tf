provider vault{
  address = "http://34.71.251.34:8200"
  token = "hvs.0F8m6ealq5Ij0I10TfUoR0L4"

}
resource "aws_iam_role" "role" {
  name = "test-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "policy" {
  name        = "test-policy"
  description = "A test policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}
}

resource "vault_aws_secret_backend" "aws" {
  access_key = "AKIAWCLFHFHVC7AJ6P5D"
  secret_key = "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"
  path = "awsvaulpocnew123"
}

resource "vault_aws_secret_backend_role" "role" {
  backend = vault_aws_secret_backend.aws.path
  name    = "test2"
  credential_type = "iam_user"
  
  policy_document = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateAccessKey",
        "iam:DeleteAccessKey",
        "iam:GetUser",
        "iam:DeleteUser",
        "iam:ListAccessKeys",
        "iam:ListAttachedUserPolicies",
        "iam:ListGroupsForUser",
        "iam:ListUserPolicies",
        "iam:RemoveUserFromGroup"
      ],
      "Resource": [
        "arn:aws:iam::417360980458:user/vault-root-*",
        "arn:aws:iam::417360980458:user/root-for-vault"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:AttachUserPolicy",
        "iam:CreateUser",
        "iam:DeleteUserPolicy",
        "iam:DetachUserPolicy",
        "iam:PutUserPolicy"
      ],
      "Resource": [
        "arn:aws:iam::417360980458:user/vault-root-*"
      ],
      "Condition": {
        "StringEquals": {
          "iam:PermissionsBoundary": [
            "arn:aws:iam::417360980458:policy/vault-aws-permission-boundary"
          ]
        }
      }
    }
  ]
}
EOT
}

# generally, these blocks would be in a different module
data "vault_aws_access_credentials" "creds" {
  backend = vault_aws_secret_backend.aws.path
  role    = vault_aws_secret_backend_role.role.name
}
#error here
provider "aws" {
  access_key = data.vault_aws_access_credentials.creds.access_key
  secret_key = data.vault_aws_access_credentials.creds.secret_key
  region = "us-east-1"
}
