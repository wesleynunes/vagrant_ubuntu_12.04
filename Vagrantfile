Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/precise64"
    config.vm.hostname = "precise"    
    # config.vm.network :forwarded_port, guest: 80, host: 8083
    # config.vm.network "forwarded_port", guest: 3306, host: 3307  
    config.vm.network :private_network, ip: "192.168.33.83"  
    config.vm.synced_folder "./", "/var/www/html", type: "nfs"
    config.vm.provider "virtualbox" do |machine|
    	machine.memory = 1024
        machine.cpus = 1
    	machine.name = "precise"
    end
    config.vm.provision :shell, path: "setup.sh"
end
