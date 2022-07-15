/*resource "aws_key_pair" "ec2-key" {
  key_name   = var.ec2-key.name
  public_key = var.ec2-key.key
}*/

module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "3.4.0"

  name          = "${var.project-name}-cluster-${lookup(var.env, var.provider-param.region)}"
  ami           = data.aws_ami.amazon_ecs.id
  key_name      = var.ec2-key
  instance_type = "t2.micro"

  count                  = var.instance_count
  iam_instance_profile   = aws_iam_role.ec2-role.name
  user_data              = file("userdata-docker.sh")
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  subnet_id              = module.vpc.public_subnets[count.index]

  tags = {
    Terraform   = "true"
    Environment = lookup(var.env, var.provider-param.region)
  }
}
