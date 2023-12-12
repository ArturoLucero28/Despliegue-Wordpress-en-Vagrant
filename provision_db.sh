
sudo apt-get update
sudo apt-get install -y mariadb-server


sudo mysql -u root -p -e "CREATE DATABASE wordpress_db;"
sudo mysql -u root -p -e "CREATE USER 'wordpress_user'@'%' IDENTIFIED BY '1234';"
sudo mysql -u root -p -e "GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wordpress_user'@'%';"
sudo mysql -u root -p -e "FLUSH PRIVILEGES;"


sudo systemctl restart mariadb
