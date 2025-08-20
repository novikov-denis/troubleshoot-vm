# 🖥️ Troubleshoot VM - Универсальный образ

## 📦 Описание образа

Этот образ содержит полностью настроенную Ubuntu 22.04 систему с предустановленными инструментами для практики troubleshooting.

**Что включено:**
- ✅ Ubuntu Server 22.04 LTS
- ✅ Go приложения с багами для практики
- ✅ Системные сервисы (echo, watcher, locker)
- ✅ LVM конфигурация для практики с дисками
- ✅ Намеренно внесенные проблемы для обучения

## 🖥️ Системные требования

- **RAM:** минимум 2GB, рекомендуется 4GB
- **Диск:** 25GB свободного места
- **CPU:** любой x86_64 процессор
- **Сеть:** доступ в интернет для обновлений

## 🚀 Использование образа

### UTM (macOS)

```bash
1. Скачайте troubleshoot-vm.utm
2. Двойной клик для импорта в UTM
3. Настройте Port Forwarding:
   - Host 2222 → Guest 22 (SSH)
   - Host 8080 → Guest 8080 (HTTP)
4. Запустите VM
```

### VirtualBox (любая ОС)

```bash
1. Скачайте troubleshoot-vm-universal.qcow2
2. VirtualBox → New → Expert Mode
3. Name: troubleshoot-vm
4. Type: Linux, Version: Ubuntu (64-bit)
5. Memory: 2048MB
6. Hard disk: Use existing → выберите .qcow2 файл
7. Settings → Network → Port Forwarding:
   - Host 2222 → Guest 22
   - Host 8080 → Guest 8080
```

### QEMU/KVM (Linux)

```bash
# Прямой запуск
qemu-system-x86_64 \\
    -hda troubleshoot-vm-universal.qcow2 \\
    -m 2G \\
    -netdev user,id=net0,hostfwd=tcp::2222-:22,hostfwd=tcp::8080-:8080 \\
    -device e1000,netdev=net0

# Или импорт в virt-manager
virt-manager → New VM → Import existing disk image
```

### VMware (Windows/macOS/Linux)

```bash
1. Конвертируйте QCOW2 в VMDK:
   qemu-img convert -f qcow2 -O vmdk troubleshoot-vm-universal.qcow2 troubleshoot-vm.vmdk

2. VMware → Create New VM → Custom
3. Guest OS: Linux → Ubuntu 64-bit
4. Use existing disk → выберите .vmdk файл
5. Network: NAT с port forwarding
```

## 🔑 Доступ к системе

**Учетные данные:**
- **Пользователь:** ubuntu
- **Пароль:** ubuntu
- **Root доступ:** sudo без пароля

**Подключение:**
```bash
# SSH (если настроен port forwarding)
ssh -p 2222 ubuntu@localhost

# Веб-приложение
open http://localhost:8080
```

## 🎯 Что практиковать

### 1. Проблемы с сервисами
```bash
sudo systemctl status echo.service
sudo systemctl status watcher.service
sudo systemctl status locker.service
```

### 2. Проблемы с дисками
```bash
df -h
lsblk
sudo lvdisplay
```

### 3. Проблемы с сетью
```bash
netstat -tulpn
ss -tulpn
sudo iptables -L
```

### 4. Проблемы с процессами
```bash
ps aux | grep trouble
top
htop
```

### 5. Анализ логов
```bash
journalctl -xe
tail -f /var/log/syslog
dmesg
```

## 🔄 Сброс системы

Для возврата к начальному состоянию:

1. **С снапшотом:** восстановите снапшот в гипервизоре
2. **Без снапшота:** повторно разверните образ
3. **Частичный сброс:** перезапустите проблемные сервисы

## 📚 Дополнительные ресурсы

- [GitHub репозиторий](https://github.com/novikov-denis/troubleshoot-vm)
- [Документация по troubleshooting](./README.md)
- [Список известных проблем](./KNOWN_ISSUES.md)

## 💡 Советы по использованию

1. **Делайте снапшоты** перед началом практики
2. **Документируйте** найденные проблемы и решения
3. **Экспериментируйте** с различными инструментами диагностики
4. **Не бойтесь сломать** - система специально для этого создана!

---
*Версия образа: 1.0*  
*Дата создания: $(date +%Y-%m-%d)*  
*Автор: Denis Novikov*
