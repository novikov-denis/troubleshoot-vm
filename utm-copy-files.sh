#!/bin/bash
set -e

echo "📦 Копирование файлов проекта в UTM VM"
echo "======================================"

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Проверка подключения к VM
status "Проверка подключения к VM..."
if ! ssh -p 2222 -o ConnectTimeout=5 -o BatchMode=yes vagrant@localhost exit 2>/dev/null; then
    error "Не удается подключиться к VM. Убедитесь что:"
    echo "  1. VM запущена в UTM"
    echo "  2. SSH сервер установлен и запущен"
    echo "  3. Port forwarding настроен (Host 2222 → Guest 22)"
    echo ""
    echo "Попробуйте подключиться вручную:"
    echo "  ssh -p 2222 vagrant@localhost"
    exit 1
fi
success "Подключение к VM установлено"

# Создание директории в VM
status "Создание директории проекта в VM..."
ssh -p 2222 vagrant@localhost "mkdir -p /home/vagrant/troubleshoot-vm-master"

# Копирование файлов
status "Копирование файлов проекта..."

# Список файлов и папок для копирования
FILES_TO_COPY=(
    "trouble-apps-go/"
    "scripts/"
    "ansible/"
    "utm-install.sh"
    "UTM_SETUP.md"
    "README.md"
    "Makefile"
    "go.mod"
    "go.sum" 
    "requirements.txt"
    "requirements.yml"
    "ansible.cfg"
)

for item in "${FILES_TO_COPY[@]}"; do
    if [ -e "$item" ]; then
        status "Копирование: $item"
        scp -P 2222 -r "$item" vagrant@localhost:/home/vagrant/troubleshoot-vm-master/
    else
        warning "Файл не найден: $item"
    fi
done

success "Все файлы скопированы"

# Настройка прав
status "Настройка прав доступа..."
ssh -p 2222 vagrant@localhost "
    cd /home/vagrant/troubleshoot-vm-master
    chmod +x utm-install.sh 2>/dev/null || true
    chmod +x scripts/*.sh 2>/dev/null || true
"

success "Права настроены"

echo ""
echo "✅ Копирование завершено!"
echo ""
echo "🔧 Следующий шаг - запуск автоматической настройки:"
echo "   ssh -p 2222 vagrant@localhost"
echo "   cd troubleshoot-vm-master"
echo "   bash utm-install.sh"
echo ""
echo "📋 Или выполните команды настройки прямо сейчас:"
read -p "Хотите запустить автоматическую настройку прямо сейчас? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    status "Запуск автоматической настройки..."
    ssh -p 2222 vagrant@localhost "cd troubleshoot-vm-master && bash utm-install.sh"
    success "Настройка завершена!"
    echo ""
    echo "🌐 Troubleshoot VM готова к использованию:"
    echo "   SSH: ssh -p 2222 vagrant@localhost"
    echo "   HTTP: http://localhost:8080"
else
    echo "💡 Настройку можно запустить позже вручную"
fi
