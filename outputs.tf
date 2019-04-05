output "URL" {
  value = "http://${module.public_alb.dns_name}"
}

output "Wordpress Login" {
  value = "http://${module.public_alb.dns_name}/wp-admin"
}

output "Wordpress Admin User" {
  value = "${var.client_name}-wp-admin"
}

output "Wordpress Admin Password" {
  value = "${var.wp_admin_passwd}"
}