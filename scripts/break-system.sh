#!/bin/bash
set -e

echo "=== Применение намеренных поломок системы ==="

# Создание резервных копий
cp /etc/nsswitch.conf /etc/nsswitch.conf.backup
cp /etc/security/limits.conf /etc/security/limits.conf.backup
cp /etc/apt/sources.list /etc/apt/sources.list.backup
cp /etc/default/grub /etc/default/grub.backup

# 1. Поломка nsswitch.conf (отключение DNS)
cat > /etc/nsswitch.conf << 'NSSWITCH'
# /etc/nsswitch.conf
#
# Example configuration of GNU Name Service Switch functionality.
# If you have the \`glibc-doc-reference' and \`info' packages installed, try:
# \`info libc "Name Service Switch"' for information about this file.

passwd:         files systemd
group:          files systemd
shadow:         files
gshadow:        files

# FLAG: YANDEXPRACTICUM
hosts:          files

networks:       files

protocols:      db files
services:       db files
ethers:         db files
rpc:            db files

netgroup:       nis
NSSWITCH

# 2. Настройка limits.conf (ограничение файлов)
cat > /etc/security/limits.conf << 'LIMITS'
# /etc/security/limits.conf
#
#Each line describes a limit for a user in the form:
#
#<domain>        <type>  <item>  <value>
#
#Where:
#<domain> can be:
#        - a user name
#        - a group name, with @group syntax
#        - the wildcard *, for default entry
#        - the wildcard %, can be also used with %group syntax,
#                 for maxlogin limit
#        - NOTE: group and wildcard limits are not applied to root.
#          To apply a limit to the root user, <domain> must be
#          the literal username root.
#
#<type> can have the two values:
#        - "soft" for enforcing the soft limits
#        - "hard" for enforcing hard limits
#
#<item> can be one of the following:
#        - core - limits the core file size (KB)
#        - data - max data size (KB)
#        - fsize - maximum filesize (KB)
#        - memlock - max locked-in-memory address space (KB)
#        - nofile - max number of open file descriptors
#        - rss - max resident set size (KB)
#        - stack - max stack size (KB)
#        - cpu - max CPU time (MIN)
#        - nproc - max number of processes
#        - as - address space limit (KB)
#        - maxlogins - max number of logins for this user
#        - maxsyslogins - max number of logins on the system
#        - priority - the priority to run user process with
#        - locks - max number of file locks the user can hold
#        - sigpending - max number of pending signals
#        - msgqueue - max memory used by POSIX message queues (bytes)
#        - nice - max nice priority allowed to raise to values: [-20, 19]
#        - rtprio - max realtime priority
#        - chroot - change root to directory (Debian-specific)
#
#<domain>      <type>  <item>         <value>
#


#*               soft    core            0
#root            hard    core            100000
#*               hard    rss             10000
#@student        hard    nproc           20
#@faculty        soft    nproc           20
#@faculty        hard    nproc           50
#ftp             hard    nproc           0
#ftp             -       chroot          /ftp
#@student        -       maxlogins       4

*               soft    nofile            1024
*               hard    nofile            1024

# End of file
LIMITS

# 3. Поломка APT sources
echo "FLAG: DEVOPSCOURSE" > /etc/apt/sources.list

# 4. Настройка GRUB
cat > /etc/default/grub << 'GRUB'
# If you change this file, run 'update-grub' afterwards to update
# /boot/grub/grub.cfg.
# For full documentation of the options in this file, see:
#   info -f grub -n 'Simple configuration'

GRUB_DEFAULT=0
GRUB_HIDDEN_TIMEOUT_QUIET=false
GRUB_TIMEOUT_STYLE=menu
GRUB_TIMEOUT=10
GRUB_DISTRIBUTOR="FLAG: ITISNOTAFLAG"
GRUB_CMDLINE_LINUX_DEFAULT="net.ifnames=0 biosdevname=0 console=ttyS0"
GRUB_CMDLINE_LINUX="console=tty0 console=ttyS0,115200n8 rootdelay=10"

# Uncomment to enable BadRAM filtering, modify to suit your needs
# This works with Linux (no patch required) and with any kernel that obtains
# the memory map information from GRUB (GNU Mach, kernel of FreeBSD ...)
#GRUB_BADRAM="0x01234567,0xfefefefe,0x89abcdef,0xefefefef"

# Uncomment to disable graphical terminal (grub-pc only)
GRUB_TERMINAL="console serial"
GRUB_SERIAL_COMMAND="serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1"

# The resolution used on graphical terminal
# note that you can use only modes which your graphic card supports via VBE
# you can see them in real GRUB with the command \`vbeinfo'
#GRUB_GFXMODE=640x480

# Uncomment if you don't want GRUB to pass "root=UUID=xxx" parameter to Linux
GRUB_DISABLE_LINUX_UUID=true

# Uncomment to disable generation of recovery mode menu entries
GRUB_DISABLE_RECOVERY="true"
GRUB_DISABLE_SUBMENU=y

# Uncomment to get a beep at grub start
#GRUB_INIT_TUNE="480 440 1"
GRUB

# Обновление GRUB
update-grub

# 5. Поломка LVM раздела (имитация поврежденной файловой системы)
if [ -b /dev/opt/devops ]; then
    echo "Повреждение файловой системы на /dev/opt/devops..."
    umount /opt/devops || true
    # Стираем первый суперблок
    dd if=/dev/zero of=/dev/opt/devops bs=512 count=1 conv=fsync
    # Записываем флаг
    echo -n "XFS FLAG: WHOISEVGFITIL" | dd of=/dev/opt/devops conv=fsync
fi

# 6. Удаление критически важных пакетов (ОСТОРОЖНО!)
echo "Удаление пакетов..."
apt-get remove -y --purge \
    lvm2 \
    snapd \
    nano \
    open-vm-tools \
    open-iscsi \
    ufw \
    telnet \
    wget \
    tmux \
    htop \
    git \
    multipath-tools \
    xfsprogs \
    screen \
    sosreport \
    cloud-init \
    cloud-guest-utils \
    cloud-initramfs-growroot \
    cloud-initramfs-copymods \
    cloud-initramfs-dyn-netconf \
    update-manager-core \
    unattended-upgrades \
    openssh-client \
    openssh-sftp-server \
    openssh-server \
    2>/dev/null || true

apt-get autoremove -y || true

echo "=== Система успешно сломана для целей траблшутинга ==="
echo "Флаги размещены в:"
echo "  - /opt/devops/flag.txt"
echo "  - /etc/nsswitch.conf"
echo "  - /etc/apt/sources.list"
echo "  - /etc/default/grub"
echo "  - /dev/opt/devops (XFS суперблок)"

