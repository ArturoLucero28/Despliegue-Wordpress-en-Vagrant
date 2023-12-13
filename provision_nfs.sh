
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


