#!/bin/bash
set -e

echo "=== Компиляция Go приложений ==="

# Установка Go если не установлен
if ! command -v go &> /dev/null; then
    echo "Установка Go из репозитория Ubuntu..."
    apt-get update
    apt-get install -y golang-1.20 build-essential
    
    # Создание симлинка для go
    ln -sf /usr/lib/go-1.20/bin/go /usr/local/bin/go
    export PATH=$PATH:/usr/lib/go-1.20/bin
    echo 'export PATH=$PATH:/usr/lib/go-1.20/bin' >> /home/vagrant/.bashrc
fi

# Создание директории для бинарных файлов
sudo mkdir -p /opt/devops/bin
sudo mkdir -p /usr/local/bin

# Определение директории с исходниками
if [ -d "/vagrant/trouble-apps-go" ]; then
    # Vagrant окружение
    SOURCE_DIR="/vagrant/trouble-apps-go"
elif [ -d "/home/vagrant/troubleshoot-vm-master/trouble-apps-go" ]; then
    # UTM окружение
    SOURCE_DIR="/home/vagrant/troubleshoot-vm-master/trouble-apps-go"
elif [ -d "./trouble-apps-go" ]; then
    # Локальная директория
    SOURCE_DIR="./trouble-apps-go"
else
    echo "Ошибка: директория trouble-apps-go не найдена"
    exit 1
fi

echo "Использование исходников из: $SOURCE_DIR"
cd "$SOURCE_DIR"

# Компиляция приложений
echo "Компиляция echo..."
cd cmd/echo
go mod tidy
GOOS=linux GOARCH=amd64 go build -o /tmp/echo main.go
sudo cp /tmp/echo /usr/local/bin/echo
sudo chmod 755 /usr/local/bin/echo

echo "Компиляция watcher..."
cd ../watcher
GOOS=linux GOARCH=amd64 go build -o /tmp/watcher main.go
sudo cp /tmp/watcher /usr/local/bin/watcher
sudo chmod 755 /usr/local/bin/watcher

echo "Компиляция trouble..."
cd ../trouble
GOOS=linux GOARCH=amd64 go build -o /tmp/trouble main.go
sudo cp /tmp/trouble /opt/devops/bin/trouble
sudo chmod 755 /opt/devops/bin/trouble

echo "Go приложения скомпилированы успешно"
