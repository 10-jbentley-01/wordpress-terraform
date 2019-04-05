variable "client_name" {
  description = "Name of the client"
  type = "string"
}

variable "environment" {
  description = "Name of the environment"
  type = "string"
}

variable "linux_ami_id" {
  description = "The AMI ID to be used to build linux ec2 instances"
  type = "string"
}

variable "linux_instance_type" {
  description = "Imnstance type to use for linux EC2 instances"
  type = "string"
}
variable "wp_ver" {
  description = "The version of Wordpress to intsall"
}

variable "db_password" {
  description = "The password to be used for the Aurora DB master User account"
  type = "string"
}

variable "wp_admin_passwd" {
  description = "Password to be used for the wordpress admin user"
  type = "string"
}

variable "wp_admin_email" {
  description = "Email address to be used for the Wordpress admin account"
  type = "string"
}

