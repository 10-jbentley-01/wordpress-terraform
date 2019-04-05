//alb
module "public_alb" {
  source                        = "terraform-aws-modules/alb/aws"
  vpc_id                        = "${module.vpc.vpc_id}"
  load_balancer_name            = "${var.client_name}-public-alb"
  security_groups               = ["${module.www_sg.this_security_group_id}"]
  subnets                       = ["${module.vpc.public_subnets}"]
  tags                          = {
    client = "${var.client_name}"
    environment = "${var.environment}"
  }
  logging_enabled = false

  http_tcp_listeners            = "${list(map("port", "80", "protocol", "HTTP"))}"
  http_tcp_listeners_count      = "1"

  target_groups                 = "${list(map("name", "wordpress", "backend_protocol", "HTTP", "backend_port", "80"))}"
  target_groups_count           = "1"
}

//ec2 stuff
module "asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  name = "${var.client_name}-wordpress"

  # Launch configuration
  lc_name = "${var.client_name}-wordpress-lc"

  image_id        = "${var.linux_ami_id}"
  instance_type   = "${var.linux_instance_type}"
  security_groups = ["${module.wordpress_sg.this_security_group_id}"]
  user_data            = "${data.template_file.userdata.rendered}"
  key_name = "london"



  # Auto scaling group
  asg_name                  = "${var.client_name}-wordpress-asg"
  vpc_zone_identifier       = ["${module.vpc.private_subnets}"]
  health_check_type         = "ELB"
  min_size                  = 1
  max_size                  = 6
  desired_capacity          = 3
  wait_for_capacity_timeout = 0
  target_group_arns = "${module.public_alb.target_group_arns}"
  tags = [
    {
      key                 = "client"
      value               = "${var.client_name}"
      propagate_at_launch = true
    },
    {
      key                 = "environment"
      value               = "${var.environment}"
      propagate_at_launch = true
    },
  ]
}


data "template_file" "userdata" {
  template = "${file("${path.module}/wordpress_userdata.tpl")}"

  vars {
    efs_id = "${aws_efs_file_system.wordpress_storage.id}"
    wp_ver = "${var.wp_ver}"
    db_name = "${aws_rds_cluster.wordpress_database.database_name}"
    db_pass = "${var.db_password}"
    db_user = "${var.client_name}admin"
    db_host = "${aws_rds_cluster.wordpress_database.endpoint}"
    alb_dns = "${module.public_alb.dns_name}"
    title = "${var.client_name} Wordpress Site"
    wp_admin = "${var.client_name}-wp-admin"
    wp_admin_passwd = "${var.wp_admin_passwd}"
    wp_admin_email = "${var.wp_admin_email}"
  }
}

//Autoscaling Policy

resource "aws_autoscaling_policy" "aws_autoscaling_policy" {
  name                   = "aws_autoscaling_policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = "${module.asg.this_autoscaling_group_name}"

  target_tracking_configuration {
    target_value     = 60
    disable_scale_in = false

    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
  }
}
//Storage
resource "aws_efs_file_system" "wordpress_storage" {
  tags = {
    Name = "wordpress_storage"
    client = "${var.client_name}"
    environment = "${var.environment}"
  }
}

resource "aws_efs_mount_target" "wordpress_mount_point" {
  count = "3"
  file_system_id = "${aws_efs_file_system.wordpress_storage.id}"
  subnet_id      = "${element(module.vpc.private_subnets, count.index)}"
  security_groups = ["${module.wordpress_sg.this_security_group_id}"]
}

//DB
resource "aws_rds_cluster" "wordpress_database" {
  cluster_identifier      = "${var.client_name}-aurora-cluster"
  engine                  = "aurora"
  engine_mode             = "serverless"
  db_subnet_group_name    = "${var.client_name}-vpc"
  vpc_security_group_ids  = ["${module.wordpress_sg.this_security_group_id}"]
  availability_zones      = ["${module.vpc.azs}"]
  database_name           = "${var.client_name}"
  master_username         = "${var.client_name}admin"
  master_password         = "${var.db_password}"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
  tags {
    client = "${var.client_name}"
    environment = "${var.environment}"
  }
}