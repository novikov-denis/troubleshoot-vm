#!/bin/bash
set -e

echo "=== Установка приложений и сервисов ==="

# Создание systemd unit файлов
echo "Создание systemd сервисов..."

# Echo service
cat > /lib/systemd/system/echo.service << 'EOF'
[Unit]
Description=Simple Network Server with TCP Listener
After=network-online.target
Wants=network-online.target
StartLimitIntervalSec=10
StartLimitBurst=5

[Service]
Type=simple
ExecStart=/usr/local/bin/echo
Restart=on-failure
RestartSec=1s
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target
EOF

# Locker service
cat > /lib/systemd/system/locker.service << 'EOF'
[Unit]
Description=Simple File Locker
StartLimitIntervalSec=10
StartLimitBurst=5

[Service]
Type=simple
ExecStart=/usr/local/bin/watcher
Restart=on-failure
RestartSec=1s

[Install]
WantedBy=multi-user.target
EOF

# Watcher service
cat > /lib/systemd/system/watcher.service << 'EOF'
[Unit]
Description=Simple File Watcher

[Service]
Type=oneshot
ExecStart=/bin/systemctl restart locker
EOF

# Watcher path
cat > /lib/systemd/system/watcher.path << 'EOF'
[Unit]
Description=Monitor lockfile file for changes

[Path]
PathChanged=/locks/lockfile.lock

[Install]
WantedBy=multi-user.target
EOF

# Перезагрузка systemd и включение сервисов
systemctl daemon-reload
systemctl enable echo.service
systemctl enable locker.service
systemctl enable watcher.path

# Запуск сервисов
systemctl start echo.service
systemctl start locker.service  
systemctl start watcher.path

echo "Сервисы установлены и запущены"
