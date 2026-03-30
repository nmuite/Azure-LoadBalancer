#!/bin/bash
# Update system and install NGINX
apt update -y
apt install nginx -y
# Enable and start NGINX
systemctl enable nginx
systemctl start nginx
# Deploy a custom HTML page (optional)
echo "<h1>this is VM02 Furaha-tele </h1>" > /var/www/html/index.html