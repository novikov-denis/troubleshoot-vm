#!/bin/bash
set -e

echo "=== Настройка системы ==="

# Обновление пакетов
apt-get update
apt-get upgrade -y

# Установка необходимых пакетов для работы
apt-get install -y parted lvm2 xfsprogs

# Переключение на multi-user.target
systemctl set-default multi-user.target

# Создание пользователя 'any'
useradd -r -s /sbin/nologin -M any || true

# Создание директории для блокировок
mkdir -p /locks
chown any:any /locks
chmod 777 /locks
touch /locks/lockfile.lock
chown any:any /locks/lockfile.lock
chmod 777 /locks/lockfile.lock

echo "Базовая настройка системы завершена"
