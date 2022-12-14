#!/bin/bash
sudo yum update -y
sudo yum install -y httpd
sudo systemctl start httpd.service
sudo systemctl enable httpd.service
sudo echo "<h1> TEAM2 - VIDEO </h1>" > /var/www/html/index.html
sudo mkdir /var/www/html/videos
sudo chmod 777 /var/www/html/videos
sudo echo "<h1> TEAM2 - VIDEO </h1>" > /var/www/html/videos/index.html



# sudo yum update -y
# sudo yum install -y httpd
# sudo systemctl start httpd.service
# # sudo systemctl enable httpd.service
# sudo echo "<h1> At $(hostname -f) </h1> Videos"> /var/www/html/videos/index.html
