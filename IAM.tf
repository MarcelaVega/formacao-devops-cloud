resource "aws_iam_instance_profile" "ecs-instance-role" {
  name = "ecs-instance-role"
  role = aws_iam_role.ec2-role.name
}

resource "aws_iam_role" "ec2-role" {
  name = "ecs-instance-role"

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

resource "aws_iam_role_policy_attachment" "ecs-instance-role-attach" {
  role       = aws_iam_role.ec2-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}



resource "aws_iam_role" "ecs-role" {
  name = "ecs-task-role"

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

resource "aws_iam_role_policy_attachment" "ecs-task-role-attach" {
  role       = aws_iam_role.ecs-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "ec2-access-s3" {
  name        = "${var.project-name}-S3-Bucket"
  path        = "/"
  description = "Allow access on S3 bucket for EC2-instances"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ObjectLevel",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObjectAcl"
            ],
            "Resource": "${aws_s3_bucket.bucket.arn}/*"
        },
        {
            "Sid": "BucketLevel",
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketPublicAccessBlock",
                "s3:PutBucketPublicAccessBlock",
                "s3:CreateBucket",
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": "${aws_s3_bucket.bucket.arn}"
        },
        {
            "Sid": "AccountLevel",
            "Effect": "Allow",
            "Action": "s3:ListAllMyBuckets",
            "Resource": "*"
        }
    ]
})
}

resource "aws_iam_role_policy_attachment" "ecs-instance-role-attach2" {
  role       = aws_iam_role.ec2-role.name
  policy_arn = aws_iam_policy.ec2-access-s3.arn
}