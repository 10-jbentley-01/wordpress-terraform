# Wordpress Terraform



The following terraform when applied will create a production ready HA Wordpress site with autoscaling
creating the following:

* A Client VPC
* 3 - Public Subnets
* 3 - Private Subnets (Each with a NAT Gateway)
* 3 - Database Subnets
* A Public ALB listening on port 80
* An ASG to deploy wordpress on ec2
* Target tracking autoscalling
* Security Groups
* RDS aurora serverless cluster
* EFS mountpoint to hold static wordpress sites allowing the ec2 instance to autoscale.

This was built and tested in "eu-west-2" but should work in any region,
I have included my tfvars file to allow it to be built with just "terraform apply"

Once the apply finishes it can take 5+ mins before wordpress becomes available.

#### Issues
* Passwords need to be stored in a secret store.
* Should be using TLS thought but not possible without a domain.
* EFS maybe slow at high volume, would need to add dummy data in order to get performance boost.
* Cloudfront would improve performance but is difficult to implement without a domain.
