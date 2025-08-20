#!/bin/bash
set -e

echo "=== Настройка хранилища (LVM) ==="

# Поиск дополнительного диска
DISK=""
for disk in /dev/vdb /dev/sdb /dev/nvme0n2; do
    if [ -b "$disk" ]; then
        DISK="$disk"
        break
    fi
done

# Если дополнительный диск не найден, создаем файл-образ
if [ -z "$DISK" ]; then
    echo "Дополнительный диск не найден, создаем файл-образ для LVM..."
    
    # Создание файла-образа 5GB
    dd if=/dev/zero of=/opt/lvm-disk.img bs=1M count=5120
    
    # Настройка loop устройства
    LOOP_DEVICE=$(losetup -f)
    losetup "$LOOP_DEVICE" /opt/lvm-disk.img
    DISK="$LOOP_DEVICE"
    
    echo "Создан loop-диск: $DISK"
fi

echo "Использование диска: $DISK"

# Создание раздела
echo "Создание раздела на $DISK..."
parted -s $DISK mklabel gpt
parted -s $DISK mkpart primary 0% 100%
parted -s $DISK set 1 lvm on

# Ожидание создания device node
sleep 2
PARTITION="${DISK}1"

# Создание PV, VG и LV
echo "Создание LVM структуры..."
pvcreate $PARTITION
vgcreate opt $PARTITION
lvcreate -l 100%FREE -n devops opt

# Создание файловой системы
echo "Создание XFS файловой системы..."
mkfs.xfs /dev/opt/devops

# Создание точки монтирования и монтирование
mkdir -p /opt/devops
mount /dev/opt/devops /opt/devops

# Добавление в fstab
echo "/dev/opt/devops /opt/devops xfs defaults 0 2" >> /etc/fstab

# Создание флага
echo "FLAG: DOAUTOMATEREPEATE" > /opt/devops/flag.txt
chown root:root /opt/devops/flag.txt
chmod 644 /opt/devops/flag.txt

echo "Настройка хранилища завершена"
