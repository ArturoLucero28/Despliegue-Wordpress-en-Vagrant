# Vagrantfile

Vagrant.configure("2") do |config|
  # Configuración del box común para todas las máquinas
  config.vm.box = "debian/buster64"

  # Capa 1: Balanceador de carga expuesto a red pública
config.vm.define "balanceadorArturoLucero" do |lb|
  lb.vm.network "public_network"
  lb.vm.network "forwarded_port", guest: 80, host: 8081 
  lb.vm.hostname = "balanceadorArturoLucero"
  lb.vm.network "private_network", ip: "192.168.33.10"
  lb.vm.provision "shell", path: "provision_lb.sh"
end


  # Capa 2: BackEnd
  config.vm.define "serverweb1ArturoLucero" do |web1|
    web1.vm.network "private_network", ip: "192.168.33.11"
    web1.vm.hostname = "serverweb1ArturoLucero"
    web1.vm.provision "shell", path: "provision_web.sh"
  end

  config.vm.define "serverweb2ArturoLucero" do |web2|
    web2.vm.network "private_network", ip: "192.168.33.12"
    web2.vm.hostname = "serverweb2ArturoLucero"
    web2.vm.provision "shell", path: "provision_web.sh"
  end

  # Servidor NFS y PHP-FPM en una misma máquina
  config.vm.define "serverNFSArturoLucero" do |nfs|
    nfs.vm.network "private_network", ip: "192.168.33.13"
    nfs.vm.hostname = "serverNFSArturoLucero"
    nfs.vm.provision "shell", path: "provision_nfs.sh"
  end

  # Capa 3: Datos - Base de datos MariaDB
  config.vm.define "serverdatosArturoLucero" do |db|
    db.vm.network "private_network", ip: "192.168.33.14"
    db.vm.hostname = "serverdatosArturoLucero"
    db.vm.provision "shell", path: "provision_db.sh"
  end
end

