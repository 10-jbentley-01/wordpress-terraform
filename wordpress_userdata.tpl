#!/usr/bin/env bash

### logging
exec > /tmp/userdata.log 2>&1

### Change timezone #####
ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime

## prepare system
sudo yum install -y amazon-efs-utils mysql httpd
amazon-linux-extras install php7.3



mkdir -p /var/www/wordpress

mount -t efs ${efs_id}:/ /var/www/wordpress

## Install WP-CLI

curl -o /bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x /bin/wp

## create apache config
if [ ! -f /etc/httpd/conf.d/wordpress.conf ]; then
    touch /etc/httpd/conf.d/wordpress.conf
    echo 'ServerName 127.0.0.1:80' >> /etc/httpd/conf.d/wordpress.conf
    echo 'DocumentRoot /var/www/wordpress/' >> /etc/httpd/conf.d/wordpress.conf
    echo '<Directory /var/www/wordpress/>' >> /etc/httpd/conf.d/wordpress.conf
    echo '  Options Indexes FollowSymLinks' >> /etc/httpd/conf.d/wordpress.conf
    echo '  AllowOverride All' >> /etc/httpd/conf.d/wordpress.conf
    echo '  Require all granted' >> /etc/httpd/conf.d/wordpress.conf
    echo '</Directory>' >> /etc/httpd/conf.d/wordpress.conf
fi


##Install Wordpress
if [ ! -f /var/www/wordpress/index.php ]; then
    cd /var/www/wordpress
    wp core download --version=${wp_ver} --locale=en_GB
    wp config create --dbname=${db_name} --dbuser=${db_user} --dbpass=${db_pass} --dbhost=${db_host} --dbprefix=wp_
    wp core install --url=${alb_dns} --title='${title}' --admin_user=${wp_admin} --admin_password=${wp_admin_passwd} --admin_email=${wp_admin_email}
    wp theme activate twentyseventeen
fi

chown -R apache:apache /var/www/wordpress/

chkconfig httpd on
service httpd restart