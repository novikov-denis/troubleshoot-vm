# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Базовый образ
  config.vm.box = "ubuntu/jammy64"  # Ubuntu 22.04 LTS
  
  # Настройки VM
  config.vm.provider "virtualbox" do |vb|
    vb.name = "troubleshoot-vm"
    vb.memory = "2048"
    vb.cpus = 2
    
    # Увеличиваем размер диска до 20GB
    unless File.exist?("./disk.vdi")
      vb.customize ["createhd", "--filename", "./disk.vdi", "--size", 20480]
    end
    vb.customize ["storageattach", :id, "--storagectl", "SCSI", "--port", 2, "--device", 0, "--type", "hdd", "--medium", "./disk.vdi"]
    
    # Отключаем GUI
    vb.gui = false
  end
  
  # Настройка сети
  config.vm.network "private_network", ip: "192.168.56.10"
  config.vm.network "forwarded_port", guest: 8080, host: 8080, host_ip: "127.0.0.1"
  
  # Синхронизация папок
  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"
  
  # Отключаем автообновления
  config.vm.provision "shell", inline: <<-SHELL
    systemctl disable apt-daily.timer
    systemctl disable apt-daily-upgrade.timer
    systemctl stop apt-daily.timer
    systemctl stop apt-daily-upgrade.timer
  SHELL
  
  # Компиляция Go приложений
  config.vm.provision "shell", path: "build-apps.sh"
  
  # Основная настройка системы
  config.vm.provision "shell", path: "setup-system.sh"
  
  # Настройка storage
  config.vm.provision "shell", path: "setup-storage.sh"
  
  # Установка приложений
  config.vm.provision "shell", path: "install-apps.sh"
  
  # Сломать систему (в конце)
  config.vm.provision "shell", path: "break-system.sh"
end
