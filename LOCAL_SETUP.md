# Локальная установка Troubleshoot VM

Данное руководство поможет создать локальную виртуальную машину с теми же характеристиками, что и оригинальный образ для Yandex Cloud.

## Требования

- VirtualBox 6.0+ или VMware
- Vagrant 2.2+
- Минимум 4GB свободной оперативной памяти
- 25GB свободного места на диске

## Быстрый старт

1. **Установка Vagrant (если не установлен):**
   ```bash
   # macOS
   brew install vagrant
   
   # Ubuntu/Debian
   sudo apt-get install vagrant
   
   # Windows
   # Скачайте с https://www.vagrantup.com/downloads
   ```

2. **Клонирование проекта и запуск:**
   ```bash
   cd troubleshoot-vm-master
   vagrant up
   ```

3. **Подключение к ВМ:**
   ```bash
   vagrant ssh
   ```

## Архитектура ВМ

### Базовая конфигурация
- **ОС:** Ubuntu 22.04 LTS (jammy64)
- **RAM:** 2GB
- **CPU:** 2 ядра  
- **Диск:** 20GB (основной) + дополнительный диск для LVM
- **Сеть:** 192.168.56.10 (private network)
- **Порты:** 8080 (проброшен на хост)

### Установленные компоненты

#### Go приложения:
1. **echo** - HTTP сервер на порту 8080
   - Расположение: `/usr/local/bin/echo`
   - Systemd сервис: `echo.service`
   - Автозапуск: включен

2. **watcher** - Блокировщик файлов
   - Расположение: `/usr/local/bin/watcher`
   - Systemd сервис: `locker.service`
   - Мониторинг: `watcher.path` (следит за `/locks/lockfile.lock`)

3. **trouble** - Веб-сервер с проверками безопасности
   - Расположение: `/opt/devops/bin/trouble`
   - Запуск: только не от root пользователя
   - Проверки: ulimit, блокировка файлов

#### LVM структура:
- Дополнительный раздел на `/dev/sdb`
- Volume Group: `opt`
- Logical Volume: `devops`
- Файловая система: XFS
- Точка монтирования: `/opt/devops`

### Намеренные проблемы (для траблшутинга)

#### 1. Сетевые проблемы
- **Файл:** `/etc/nsswitch.conf`
- **Проблема:** Отключен DNS резолвинг (`hosts: files` вместо `files dns`)
- **Флаг:** `YANDEXPRACTICUM`

#### 2. Проблемы с пакетами
- **Файл:** `/etc/apt/sources.list`
- **Проблема:** Заменен содержимым флага
- **Флаг:** `DEVOPSCOURSE`

#### 3. Проблемы с ограничениями
- **Файл:** `/etc/security/limits.conf` 
- **Проблема:** Ограничение на 1024 открытых файла для всех пользователей

#### 4. Проблемы с GRUB
- **Файл:** `/etc/default/grub`
- **Проблема:** Настройка последовательной консоли + флаг
- **Флаг:** `ITISNOTAFLAG`

#### 5. Проблемы с файловой системой
- **Устройство:** `/dev/opt/devops`
- **Проблема:** Поврежден XFS суперблок
- **Флаг:** `WHOISEVGFITIL`

#### 6. Проблемы с флагом
- **Файл:** `/opt/devops/flag.txt`
- **Флаг:** `DOAUTOMATEREPEATE`

#### 7. Удаленные пакеты
Критичные пакеты удалены:
- `lvm2`, `openssh-server`, `wget`, `git`, `nano`
- `cloud-init`, `snapd`, `xfsprogs`
- И многие другие...

## Управление ВМ

### Основные команды Vagrant:
```bash
# Запуск ВМ
vagrant up

# Подключение по SSH
vagrant ssh

# Остановка ВМ
vagrant halt

# Перезапуск ВМ
vagrant reload

# Полное удаление ВМ
vagrant destroy

# Просмотр статуса
vagrant status
```

### Сетевой доступ:
- **SSH:** `vagrant ssh` или `ssh vagrant@192.168.56.10` (пароль: vagrant)
- **HTTP:** `http://localhost:8080` или `http://192.168.56.10:8080`

### Проверка сервисов:
```bash
# Статус приложений
sudo systemctl status echo.service
sudo systemctl status locker.service  
sudo systemctl status watcher.path

# Проверка портов
sudo netstat -tulpn | grep :8080

# Проверка LVM
sudo lvdisplay
sudo vgdisplay
```

## Восстановление системы

### Резервные копии:
Перед "поломкой" создаются резервные копии:
- `/etc/nsswitch.conf.backup`
- `/etc/security/limits.conf.backup`
- `/etc/apt/sources.list.backup`
- `/etc/default/grub.backup`

### Восстановление DNS:
```bash
sudo cp /etc/nsswitch.conf.backup /etc/nsswitch.conf
```

### Восстановление APT:
```bash
sudo cp /etc/apt/sources.list.backup /etc/apt/sources.list
sudo apt-get update
```

### Восстановление LVM раздела:
```bash
sudo umount /opt/devops
sudo mkfs.xfs -f /dev/opt/devops
sudo mount /opt/devops
```

## Отладка

### Логи сервисов:
```bash
journalctl -u echo.service -f
journalctl -u locker.service -f
journalctl -u watcher.path -f
```

### Проверка блокировок:
```bash
lsof /locks/lockfile.lock
```

### Проверка лимитов:
```bash
ulimit -n
```

## Альтернативные способы развертывания

### Ручная установка в VirtualBox:

1. Создайте ВМ с Ubuntu 22.04
2. Скопируйте скрипты из папки `scripts/`
3. Выполните скрипты в порядке:
   ```bash
   sudo ./setup-system.sh
   sudo ./build-apps.sh  
   sudo ./setup-storage.sh
   sudo ./install-apps.sh
   sudo ./break-system.sh
   ```

### Использование с VMware:
Замените провайдер в Vagrantfile:
```ruby
config.vm.provider "vmware_desktop" do |vmware|
  vmware.vmx["memsize"] = "2048"
  vmware.vmx["numvcpus"] = "2"
end
```

## Поддержка

При возникновении проблем:
1. Проверьте логи: `vagrant up --debug`
2. Убедитесь в наличии свободного места (25GB+)
3. Проверьте версии VirtualBox и Vagrant
4. Попробуйте пересоздать ВМ: `vagrant destroy && vagrant up`
