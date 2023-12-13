#!/bin/bash

# Actualizar la lista de paquetes e instalar software necesario
sudo apt-get update
sudo apt-get install -y mariadb-server

# Configurar MariaDB para permitir conexiones remotas 
sudo sed -i 's/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

# Reiniciar el servicio MariaDB para aplicar la configuración
sudo systemctl restart mariadb

# Crear una base de datos y un usuario de ejemplo
sudo mysql -e "CREATE DATABASE IF NOT EXISTS mydatabase;"
sudo mysql -e "CREATE USER 'arturo'@'%' IDENTIFIED BY '1234';"
sudo mysql -e "GRANT ALL PRIVILEGES ON mydatabase.* TO 'arturo'@'%';"
sudo mysql -e "FLUSH PRIVILEGES;"

