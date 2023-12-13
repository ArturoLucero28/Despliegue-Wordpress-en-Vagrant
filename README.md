# Proyecto Wordpress en Arquitectura de 3 Capas en Alta Disponibilidad

Este proyecto tiene como objetivo desplegar un CMS Wordpress en una infraestructura de alta disponibilidad de 3 capas, utilizando una pila LEMP.


## Índice

1. [Introducción](#introducción)
2. [Estructura del Proyecto](#estructura-del-proyecto)
3. [Capa 1: Balanceador de Carga Nginx](#capa-1-balanceador-de-carga-nginx)
4. [Capa 2: BackEnd](#capa-2-backend)
     - [Configuración del Servidor NFS y PHP-FPM](#configuración-del-servidor-nfs-y-php-fpm)
     - [Configuración del Servidor Web](#configuración-del-servidor-web)
  
6. [Capa 3: Datos](#capa-3-datos)
7. [Error](#Error)
8. [Entrega](#entrega)

---

## Introducción

Se desplegará un entorno de alta disponibilidad con las siguientes máquinas:

- **Capa 1: Balanceador de Carga Nginx**
  - Máquina: `balanceadorArturoLucero`
- **Capa 2: BackEnd**
  - Máquinas: `serverweb1ArturoLucero`, `serverweb2ArturoLucero`, `serverNFSArturoLucero`
- **Capa 3: Datos**
  - Máquina: `serverdatosArturoLucero`

Las capas 2 y 3 no estarán expuestas a la red pública. Los servidores web utilizarán una carpeta compartida por NFS desde `serverNFSArturoLucero` y el motor PHP-FPM instalado en la misma máquina.



## Estructura del Proyecto

A continuación en el `vagrantfile` podemos ver que las maquinas tienen todas manualmente una dirección de red siendo de manera publica el balanceador y el resto privadas
utilizamos el puerto 9090 por tema de conflictos con otros puertos y los provisionamientos los iré destacanado mas adelante en sus respectivos apartados.

**Vagrantfile**: Archivo de configuración para el aprovisionamiento de las máquinas virtuales.

````
Vagrant.configure("2") do |config|
  # Configuración del box común para todas las máquinas
  config.vm.box = "debian/buster64"

  # Capa 1: Balanceador de carga expuesto a red pública
  config.vm.define "balanceadorArturoLucero" do |lb|
    lb.vm.network "public_network"
    lb.vm.network "forwarded_port", guest: 80, host: 9090
    lb.vm.hostname = "balanceadorArturoLucero"
    lb.vm.network "private_network", ip: "192.168.33.20"
    lb.vm.provision "shell", path: "provision_lb.sh"
  end

  # Capa 2: Máquinas de servidor web
  config.vm.define "serverweb1ArturoLucero" do |web1|
    web1.vm.network "private_network", ip: "192.168.33.21"
    web1.vm.hostname = "serverweb1ArturoLucero"
    web1.vm.provision "shell", path: "provision_web.sh"
 end


  config.vm.define "serverweb2ArturoLucero" do |web2|
    web2.vm.network "private_network", ip: "192.168.33.22"
    web2.vm.hostname = "serverweb2ArturoLucero"
    web2.vm.provision "shell", path: "provision_web.sh"
  end

   Capa 3: Servidor NFS y PHP-FPM en una misma máquina
  config.vm.define "serverNFSArturoLucero" do |nfs|
    nfs.vm.network "private_network", ip: "192.168.33.23"
    nfs.vm.hostname = "serverNFSArturoLucero"
    nfs.vm.provision "shell", path: "provision_nfs.sh"
  end

  # Capa 4: Datos - Base de datos MariaDB
  config.vm.define "serverdatosArturoLucero" do |db|
    db.vm.network "private_network", ip: "192.168.33.24"
    db.vm.hostname = "serverdatosArturoLucero"
    db.vm.provision "shell", path: "provision_db.sh"
  end
end
````

- **Shell Scripts**: Scripts de configuración ejecutados durante el aprovisionamiento.
  
-provision_lb.sh
````  
sudo apt-get update
sudo apt-get upgrade

sudo apt-get install -y nginx

cat <<EOF | sudo tee /etc/nginx/sites-available/default
upstream backend {
    server 192.168.33.21;  # IP del servidor web 1
    server 192.168.33.22;  # IP del servidor web 2
}

server {
    listen 80;
    server_name localhost;

    location / {
        proxy_pass http://backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF


sudo systemctl restart nginx
````

-Provision_web.sh
````
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y apache2 php libapache2-mod-php
sudo apt-get install mariadb-client


sudo mkdir -p /shared_folder

````

-Provision_nfs.sh
````
#!/bin/bash

# Actualizar la lista de paquetes e instalar software necesario
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y nfs-kernel-server

# Crear directorios compartidos
sudo mkdir -p /shared_folder
sudo chown nobody:nogroup /shared_folder
sudo chmod 777 /shared_folder

# Configurar el archivo /etc/exports para exportar el directorio
echo "/shared_folder *(rw,sync,no_subtree_check,no_root_squash)" | sudo tee -a /etc/exports

# Reiniciar el servicio NFS para aplicar la configuración
sudo systemctl restart nfs-kernel-server

````

-Provision_db.sh
````
#!/bin/bash

# Actualizar la lista de paquetes e instalar software necesario
sudo apt-get update
sudo apt-get install -y mariadb-server

# Configurar MariaDB para permitir conexiones remotas+
sudo sed -i 's/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

# Reiniciar el servicio MariaDB para aplicar la configuración
sudo systemctl restart mariadb

# Crear una base de datos y un usuario de ejemplo
sudo mysql -e "CREATE DATABASE IF NOT EXISTS mydatabase;"
sudo mysql -e "CREATE USER 'arturo'@'%' IDENTIFIED BY '1234';"
sudo mysql -e "GRANT ALL PRIVILEGES ON mydatabase.* TO 'arturo'@'%';"
sudo mysql -e "FLUSH PRIVILEGES;"

````

## Capa 1: Balanceador de Carga Nginx

En este caso el balanceador esta todo provisionado desde el shell, podemos realizar comprobaciones abriendo el fichero y efectivamente vemos:

![image](https://github.com/ArturoLucero28/Despliegue-Wordpress-en-Vagrant/assets/146435794/6cd8c15b-bcb3-40ca-8181-904fb1e60e0b)

## Capa 2: BackEnd

Esta capa esta dividida en 3 apartados, empezaremos por el NFS.

## Configuración del Servidor NFS y PHP-FPM

En el shell podemos ver que principalmente creamos la carpeta que queremos usar para compartir y le otorgamos permisos que nos harán falta mas adelante.

![image](https://github.com/ArturoLucero28/Despliegue-Wordpress-en-Vagrant/assets/146435794/1f797067-0212-4d47-a674-bba4c7f99a9c)

Luego en el archivo localizado en `/etc/exports` vamos a añadir la siguiente linea (tambien hecha por el shell)
`echo "/shared_folder *(rw,sync,no_subtree_check,no_root_squash)" | sudo tee -a /etc/exports`

y reiniciamos el nfs-kernel-server

Manualmente lo que haremos será descargarnos el wordpress en la carpeta que vamos a compartir:

![image](https://github.com/ArturoLucero28/Despliegue-Wordpress-en-Vagrant/assets/146435794/4eca4511-f9df-4178-bc58-848828a15b14)

Realizamos la copia del zip wordpress y lo descomprimimos, a continuación desabilitamos el firewall para evitar posibles problemas

A continuación con un `sudo nano /shared_folder/wordpress/wp-config-sample.php ` colocaremos nuestra base de datos creada en: 

![image](https://github.com/ArturoLucero28/Despliegue-Wordpress-en-Vagrant/assets/146435794/076bca9b-c82f-4813-99a7-bd65d1089749)

Finalmente damos los permisos necesarios:

![image](https://github.com/ArturoLucero28/Despliegue-Wordpress-en-Vagrant/assets/146435794/3bf5f3cc-70c2-42bf-b447-c190d5da3282)

## Configuración del Servidor Web

Principalmente el shell lo que nos hace es crear la carpeta compartida,realizaremos un `sudo mount 192.168.33.23:/shared_folder /shared_folder`

![image](https://github.com/ArturoLucero28/Despliegue-Wordpress-en-Vagrant/assets/146435794/73c8bf50-76ca-4f01-8258-21270f79e358)

y en `sudo nano /etc/nginx/sites-available/default` colocamos:

````

server {
    listen 80;
    server_name localhost;

    root /shared_folder;
    index index.php index.html index.htm index.nginx-debian-html;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass 192.168.33.23:9090;
    SCRIPT_FILENAME $document_root$fastcgi_script_name;
    include fastcgi_params;
}

    location ~ /\.ht {
        deny all;
    }

    error_log /var/log/nginx/wordpress_error.log;
    access_log /var/log/nginx/wordpress_access.log;
}


````

Realizamos lo mismo en el `serverweb2ArturoLucero`

## Capa 3: Datos

Aqui principalmente del aprovisamiento podemos destacar la creacion de la base de datos:

![image](https://github.com/ArturoLucero28/Despliegue-Wordpress-en-Vagrant/assets/146435794/7ec57c25-c808-4e94-b244-3b9d92836fa2)

## Error

Y para finalizar esta practica no me ha salido el resultado wordpress debido a este error a pesar de añadirle todos los permisos posibles a las carpetas compartidas, repasar la configuración de nginx, revisor los errores de log .

![image](https://github.com/ArturoLucero28/Despliegue-Wordpress-en-Vagrant/assets/146435794/61ecf3a9-55f4-47be-8653-878a1da47e81)

## Entrega

https://clipchamp.com/watch/7pjWoBt3z08

