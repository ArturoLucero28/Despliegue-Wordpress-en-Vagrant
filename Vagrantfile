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
