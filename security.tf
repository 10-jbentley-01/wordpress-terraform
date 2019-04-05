module "www_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "www_security_group"
  description = "lets the world into the public load balancer"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["https-443-tcp", "http-80-tcp"]

  computed_egress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = "${module.wordpress_sg.this_security_group_id}"
    }
  ]
  number_of_computed_egress_with_source_security_group_id = "1"
}

module "wordpress_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "wordpress_security_group"
  description = "allows the private load balance to talk to wordpress ec2"
  vpc_id      = "${module.vpc.vpc_id}"

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = "${module.www_sg.this_security_group_id}"
    },
    {
      rule = "nfs-tcp"
      source_security_group_id = "${module.wordpress_sg.this_security_group_id}"
    },
    {
      rule = "mysql-tcp"
      source_security_group_id = "${module.wordpress_sg.this_security_group_id}"
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 3

  egress_rules = ["all-all"]
}