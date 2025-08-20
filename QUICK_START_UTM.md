# 🚀 Быстрый запуск Troubleshoot VM в UTM

## ✨ Автоматическая подготовка (выполнена)

Автоматическая подготовка завершена! Ubuntu ISO скачан и все скрипты готовы.

## 📋 Пошаговая инструкция

### 1. Откройте UTM
```bash
open /Applications/UTM.app
```

### 2. Создайте новую VM
- **Create New Virtual Machine** → **Virtualize** → **Linux**
- **Name:** `troubleshoot-vm`
- **Architecture:** `x86_64`
- **Memory:** `2048 MB`
- **CPU Cores:** `2`
- **Drive Size:** `25 GB`

### 3. Настройте загрузку
- **Boot ISO:** `/Users/novikov-denis/Downloads/troubleshoot-vm-master/iso/ubuntu-22.04.4-live-server-amd64.iso`
- **Boot Order:** CD/DVD, Hard Disk

### 4. Настройте сеть
- **Network Mode:** Shared Network
- **Port Forward:**
  - `Host 8080` → `Guest 8080`
  - `Host 2222` → `Guest 22`

### 5. Установите Ubuntu
- Запустите VM
- **Language:** English
- **Username:** `vagrant`
- **Password:** `vagrant`
- **Hostname:** `troubleshoot-vm`
- **Install SSH server:** ✅ YES

### 6. Настройте VM после установки

Перезагрузитесь и выполните:

```bash
# Подключение к VM по SSH
ssh -p 2222 vagrant@localhost

# Или используйте готовый скрипт копирования:
./utm-copy-files.sh
```

### 7. Автоматическая настройка

После копирования файлов:

```bash
ssh -p 2222 vagrant@localhost
cd troubleshoot-vm-master
bash utm-install.sh
```

## 🎯 Результат

После завершения у вас будет:

- ✅ **Troubleshoot VM** готова к использованию
- 🌐 **HTTP сервер** доступен на `http://localhost:8080`
- 🔧 **SSH доступ** через `ssh -p 2222 vagrant@localhost`
- 🚨 **Система сломана** для обучения траблшутингу

## 🔍 Проверка работы

```bash
# Проверка сервисов
ssh -p 2222 vagrant@localhost '
sudo systemctl status echo.service
sudo systemctl status locker.service
curl http://localhost:8080
'

# Веб-браузер
open http://localhost:8080
```

## 📁 Структура флагов

Флаги размещены в:
- `/opt/devops/flag.txt` - `DOAUTOMATEREPEATE`
- `/etc/nsswitch.conf` - `YANDEXPRACTICUM`
- `/etc/apt/sources.list` - `DEVOPSCOURSE`
- `/etc/default/grub` - `ITISNOTAFLAG`
- `/dev/opt/devops` - `WHOISEVGFITIL`

## 🛠️ Альтернативные команды

### Только копирование файлов:
```bash
./utm-copy-files.sh
```

### Ручная настройка в VM:
```bash
ssh -p 2222 vagrant@localhost
sudo apt update && sudo apt upgrade -y
# Далее выполните скрипты из scripts/
```

## 📚 Документация

- **Подробная инструкция:** `UTM_SETUP.md`
- **Vagrant версия:** `LOCAL_SETUP.md`
- **Оригинальный README:** `README.md`

---

💡 **Совет:** Создайте снапшот в UTM после настройки для быстрого восстановления!
