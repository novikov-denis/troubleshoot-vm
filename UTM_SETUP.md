# Установка Troubleshoot VM через UTM

UTM - современный гипервизор для macOS, идеально подходящий для Apple Silicon и Intel Mac.

## Быстрый старт

### 1. UTM уже установлен ✅
```bash
# Проверка установки
ls /Applications/UTM.app
```

### 2. Автоматическая настройка

Я создал автоматизированный процесс настройки:

```bash
# Запуск автоматической настройки
./utm-setup.sh
```

## Подробная инструкция

### Этап 1: Создание VM в UTM

1. **Откройте UTM** из Applications
2. **Создание новой VM:**
   - Нажмите "Create a New Virtual Machine"
   - Выберите "Virtualize"
   - Выберите "Linux"

3. **Настройки системы:**
   - **Name:** troubleshoot-vm
   - **Architecture:** x86_64 (для совместимости)
   - **RAM:** 2048 MB
   - **CPU Cores:** 2

4. **Настройки диска:**
   - **Drive Size:** 25 GB
   - **Drive Interface:** VirtIO

5. **Сетевые настройки:**
   - **Network Mode:** Shared Network
   - **Port Forward:** 
     - Host: 8080 → Guest: 8080
     - Host: 2222 → Guest: 22

6. **Boot Configuration:**
   - **Boot ISO:** ubuntu-22.04.4-live-server-amd64.iso
   - **Boot Order:** CD/DVD, Hard Disk

### Этап 2: Установка Ubuntu Server

1. **Скачайте Ubuntu Server 22.04:**
```bash
# Автоматическое скачивание
curl -L -o ubuntu-22.04.4-live-server-amd64.iso \
  https://releases.ubuntu.com/22.04.4/ubuntu-22.04.4-live-server-amd64.iso
```

2. **Установка Ubuntu:**
   - Загрузитесь с ISO
   - Выберите язык: **English**
   - Keyboard: **Done** (по умолчанию)
   - Network: **Done** (DHCP)
   - Proxy: **Done** (пустое поле)
   - Mirror: **Done** (по умолчанию)
   - Storage: **Use entire disk** → **Done**
   - Profile Setup:
     - **Name:** vagrant
     - **Server name:** troubleshoot-vm
     - **Username:** vagrant
     - **Password:** vagrant
   - SSH Setup: **Install OpenSSH server** ✅
   - Snaps: **Done** (пропустить)

3. **После установки:**
   - Перезагрузка
   - Вход: vagrant/vagrant
   - Обновление: `sudo apt update && sudo apt upgrade -y`

### Этап 3: Автоматическая настройка

После установки Ubuntu выполните:

```bash
# Подключение по SSH (удобнее)
ssh -p 2222 vagrant@localhost

# Или прямо в консоли UTM
sudo apt update && sudo apt upgrade -y

# Скачивание и выполнение setup скрипта
curl -L https://raw.githubusercontent.com/user/repo/main/utm-install.sh | bash
```

### Этап 4: Ручная настройка (если нужно)

```bash
# Клонирование проекта
git clone https://github.com/user/repo.git
cd troubleshoot-vm-master

# Выполнение скриптов по порядку
sudo ./setup-system.sh
sudo ./build-apps.sh
sudo ./setup-storage.sh
sudo ./install-apps.sh
sudo ./break-system.sh
```

## Управление VM

### Основные операции:
- **Запуск:** Нажать "Play" в UTM
- **Остановка:** "Stop" в UTM или `sudo shutdown -h now` в VM
- **Подключение:** `ssh -p 2222 vagrant@localhost`
- **Веб-доступ:** http://localhost:8080

### Сетевые сервисы:
- **SSH:** localhost:2222
- **HTTP (echo):** localhost:8080
- **Внутренний IP:** 192.168.64.x (автоматически)

### Проверка сервисов:
```bash
ssh -p 2222 vagrant@localhost '
sudo systemctl status echo.service
sudo systemctl status locker.service
sudo systemctl status watcher.path
sudo netstat -tulpn | grep :8080
'
```

## Преимущества UTM

✅ **Совместимость:** Работает на Apple Silicon и Intel Mac  
✅ **Производительность:** Нативная виртуализация  
✅ **Стабильность:** Нет конфликтов с Docker  
✅ **Простота:** Графический интерфейс  
✅ **Активная разработка:** Регулярные обновления  

## Решение проблем

### VM не запускается:
1. Проверьте архитектуру (x86_64 для совместимости)
2. Увеличьте RAM до 2GB
3. Убедитесь что VirtIO диск включен

### Сеть не работает:
1. Проверьте Port Forwarding в настройках UTM
2. Убедитесь что SSH сервис запущен: `sudo systemctl start ssh`

### Скрипты не работают:
1. Проверьте права: `chmod +x *.sh`
2. Убедитесь в наличии sudo прав
3. Проверьте логи: `journalctl -xe`

## Создание снапшота

После настройки создайте снапшот:
1. Остановите VM
2. В UTM: правый клик на VM → "Snapshot" → "New"
3. Назовите снапшот: "Configured troubleshoot VM"

Теперь вы можете быстро восстанавливать исходное состояние!
