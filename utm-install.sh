#!/bin/bash
set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo "🔧 Настройка Troubleshoot VM внутри системы"
echo "==========================================="

# Определение рабочей директории
if [ -d "/vagrant" ]; then
    # Vagrant окружение
    WORK_DIR="/vagrant"
elif [ -d "/home/vagrant/troubleshoot-vm-master" ]; then
    # UTM окружение с пользователем vagrant
    WORK_DIR="/home/vagrant/troubleshoot-vm-master"
elif [ -d "/home/ubuntu/troubleshoot-vm-master" ]; then
    # UTM окружение с пользователем ubuntu
    WORK_DIR="/home/ubuntu/troubleshoot-vm-master"
elif [ -d "$(pwd)" ] && [ -f "setup-system.sh" ]; then
    # Текущая директория (если в ней есть scripts)
    WORK_DIR="$(pwd)"
elif [ -d "./troubleshoot-vm-master" ]; then
    # Поддиректория troubleshoot-vm-master
    WORK_DIR="./troubleshoot-vm-master"
else
    error "Директория проекта не найдена!"
    echo "Убедитесь что файлы проекта скопированы в VM"
    echo "Поддерживаемые пути:"
    echo "  - /vagrant"
    echo "  - /home/vagrant/troubleshoot-vm-master"
    echo "  - /home/ubuntu/troubleshoot-vm-master"
    echo "  - текущая директория (если содержит setup-system.sh)"
    exit 1
fi

status "Использование рабочей директории: $WORK_DIR"
cd "$WORK_DIR"

# Проверка наличия скриптов
if [ ! -d "scripts" ]; then
    error "Директория scripts не найдена!"
    exit 1
fi

# Обновление системы
status "Обновление системы..."
sudo apt-get update
sudo apt-get upgrade -y

# Установка дополнительных пакетов
status "Установка необходимых пакетов..."
sudo apt-get install -y golang-1.20 build-essential parted lvm2 xfsprogs

# Выполнение скриптов настройки
status "Настройка прав доступа..."
sudo chmod +x *.sh

status "Выполнение setup-system.sh..."
sudo ./setup-system.sh

status "Выполнение build-apps.sh..."
sudo ./build-apps.sh

status "Выполнение setup-storage.sh..."
sudo ./setup-storage.sh

status "Выполнение install-apps.sh..."
sudo ./install-apps.sh

status "Выполнение break-system.sh..."
sudo ./break-system.sh

success "Настройка завершена!"
echo ""
echo "🎯 Troubleshoot VM готова к использованию:"
echo "   🌐 HTTP сервер: http://localhost:8080"
echo "   🔍 Флаги размещены в системе для траблшутинга"
echo "   📋 Проверка сервисов: sudo systemctl status echo.service"
echo ""
echo "🚨 Система намеренно сломана для обучения траблшутингу!"
