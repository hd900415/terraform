output "web_instance_info" {
  description = "Web instance connection information"
  value = {
    instance_ids   = module.aws_ec2.instance_ids
    instance_names = module.aws_ec2.instance_names
    public_ips     = module.aws_ec2.eip_public_ip
    private_ips    = module.aws_ec2.instance_private_ips
  }
}

output "ssh_commands" {
  description = "SSH connection commands"
  value = [
    for i, ip in module.aws_ec2.eip_public_ip :
    "ssh -i ~/.ssh/terraform-key.pem ec2-user@${ip}"
  ]
}

output "vpc_info" {
  description = "VPC information"
  value = {
    vpc_id     = module.aws_vpc.vpc_id
    subnet_ids = module.aws_vpc.public_subnet_ids
  }
}

output "security_groups" {
  description = "Security group information"
  value = {
    web_sg_ids  = module.aws_sg.web_security_group_ids
    test_sg_ids = module.aws_sg.test_security_group_ids
  }
}