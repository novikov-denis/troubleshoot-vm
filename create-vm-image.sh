#!/bin/bash

# 🖥️ Скрипт создания универсального образа Troubleshoot VM
# Создает образы в различных форматах для максимальной совместимости

set -euo pipefail

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функции для вывода
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Конфигурация
VM_NAME="troubleshoot-vm"
OUTPUT_DIR="$HOME/Downloads/troubleshoot-vm-images"
UTM_DATA_DIR="$HOME/Library/Containers/com.utmapp.UTM/Data/Documents"

# Проверка зависимостей
check_dependencies() {
    info "Проверка зависимостей..."
    
    if ! command -v qemu-img &> /dev/null; then
        error "qemu-img не найден. Установите: brew install qemu"
        exit 1
    fi
    
    success "Все зависимости установлены"
}

# Поиск UTM VM
find_utm_vm() {
    info "Поиск UTM виртуальной машины..."
    
    UTM_VM_PATH=$(find "$UTM_DATA_DIR" -name "*troubleshoot*.utm" -type d | head -1)
    
    if [ -z "$UTM_VM_PATH" ]; then
        error "UTM VM не найдена в $UTM_DATA_DIR"
        error "Убедитесь что VM называется 'troubleshoot-vm' или содержит 'troubleshoot' в названии"
        exit 1
    fi
    
    success "Найдена VM: $UTM_VM_PATH"
    
    # Поиск основного диска
    DISK_PATH=$(find "$UTM_VM_PATH/Images" -name "*.qcow2" | head -1)
    
    if [ -z "$DISK_PATH" ]; then
        error "Диск VM не найден в $UTM_VM_PATH/Images"
        exit 1
    fi
    
    success "Найден диск: $DISK_PATH"
}

# Создание выходной директории
prepare_output_dir() {
    info "Подготовка выходной директории..."
    
    mkdir -p "$OUTPUT_DIR"
    
    if [ -d "$OUTPUT_DIR" ]; then
        warning "Директория $OUTPUT_DIR уже существует"
        read -p "Очистить директорию? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$OUTPUT_DIR"/*
            success "Директория очищена"
        fi
    fi
    
    success "Выходная директория готова: $OUTPUT_DIR"
}

# Создание универсального QCOW2 образа
create_qcow2_image() {
    info "Создание универсального QCOW2 образа..."
    
    local output_file="$OUTPUT_DIR/troubleshoot-vm-universal.qcow2"
    
    # Копирование с оптимизацией
    qemu-img convert -p -O qcow2 -c "$DISK_PATH" "$output_file"
    
    local size=$(ls -lh "$output_file" | awk '{print $5}')
    success "QCOW2 образ создан: $output_file ($size)"
}

# Создание VMDK образа для VMware
create_vmdk_image() {
    info "Создание VMDK образа для VMware..."
    
    local input_file="$OUTPUT_DIR/troubleshoot-vm-universal.qcow2"
    local output_file="$OUTPUT_DIR/troubleshoot-vm-vmware.vmdk"
    
    qemu-img convert -p -f qcow2 -O vmdk "$input_file" "$output_file"
    
    local size=$(ls -lh "$output_file" | awk '{print $5}')
    success "VMDK образ создан: $output_file ($size)"
}

# Создание VDI образа для VirtualBox  
create_vdi_image() {
    info "Создание VDI образа для VirtualBox..."
    
    local input_file="$OUTPUT_DIR/troubleshoot-vm-universal.qcow2"
    local output_file="$OUTPUT_DIR/troubleshoot-vm-virtualbox.vdi"
    
    qemu-img convert -p -f qcow2 -O vdi "$input_file" "$output_file"
    
    local size=$(ls -lh "$output_file" | awk '{print $5}')
    success "VDI образ создан: $output_file ($size)"
}

# Копирование UTM файла
copy_utm_image() {
    info "Копирование UTM образа..."
    
    local output_file="$OUTPUT_DIR/troubleshoot-vm.utm"
    
    cp -R "$UTM_VM_PATH" "$output_file"
    
    local size=$(du -sh "$output_file" | awk '{print $1}')
    success "UTM образ скопирован: $output_file ($size)"
}

# Создание документации
create_documentation() {
    info "Создание документации..."
    
    # Копирование инструкций по использованию
    cp "VM_IMAGE_USAGE.md" "$OUTPUT_DIR/"
    cp "README.md" "$OUTPUT_DIR/" 2>/dev/null || true
    
    # Создание манифеста
    cat > "$OUTPUT_DIR/IMAGE_MANIFEST.txt" << EOF
Troubleshoot VM - Image Manifest
=================================

Created: $(date)
Version: 1.0
Creator: $(whoami)

Files included:
===============

troubleshoot-vm.utm              - UTM format (macOS)
troubleshoot-vm-universal.qcow2  - Universal QEMU format  
troubleshoot-vm-vmware.vmdk      - VMware format
troubleshoot-vm-virtualbox.vdi   - VirtualBox format
VM_IMAGE_USAGE.md               - Usage instructions
README.md                       - Project documentation
IMAGE_MANIFEST.txt              - This file

System Information:
==================

Base OS: Ubuntu Server 22.04 LTS
Username: ubuntu / Password: ubuntu
Services: echo, watcher, locker
Ports: SSH(22), HTTP(8080)
Disk size: ~25GB allocated

Checksums:
==========

$(cd "$OUTPUT_DIR" && find . -name "*.qcow2" -o -name "*.vmdk" -o -name "*.vdi" | xargs shasum -a 256 2>/dev/null || echo "Checksums not available")

EOF
    
    success "Документация создана"
}

# Показать итоги
show_summary() {
    echo
    success "🎉 Создание образов завершено!"
    echo
    echo "📁 Местоположение: $OUTPUT_DIR"
    echo
    echo "📋 Созданные файлы:"
    ls -lh "$OUTPUT_DIR"
    echo
    echo "🔧 Использование:"
    echo "  • UTM (macOS):      troubleshoot-vm.utm"
    echo "  • QEMU/KVM:         troubleshoot-vm-universal.qcow2"  
    echo "  • VMware:           troubleshoot-vm-vmware.vmdk"
    echo "  • VirtualBox:       troubleshoot-vm-virtualbox.vdi"
    echo
    echo "📖 Инструкции:       VM_IMAGE_USAGE.md"
    echo
    warning "⚠️  Убедитесь что VM была корректно выключена перед созданием образа!"
}

# Основная функция
main() {
    echo
    info "🖥️  Troubleshoot VM - Image Creator"
    echo "=================================="
    echo
    
    check_dependencies
    find_utm_vm
    prepare_output_dir
    
    # Проверка что VM выключена
    if pgrep -f "$VM_NAME" > /dev/null; then
        error "VM $VM_NAME сейчас запущена!"
        error "Остановите VM в UTM перед созданием образа"
        exit 1
    fi
    
    create_qcow2_image
    create_vmdk_image
    create_vdi_image
    copy_utm_image
    create_documentation
    
    show_summary
}

# Запуск
main "$@"
