#! /usr/bin/env bash

KERNEL_ARGS="net.iframes=0 biosdevname=0"
pacman -Syu --noconfirm --needed dialog sudo networkmanager nano neovim grub os-prober efibootmgr pacman-contrib reflector pkgfile
HOSTNAME=$(dialog --output-fd 1 --inputbox "Enter the hostname:" 8 40)
USERNAME=$(dialog --output-fd 1 --inputbox "Enter the username:" 8 40)
PASSWORD=$(dialog --insecure --output-fd 1 --passwordbox "Enter the password:" 8 40)
clear

# hostname config
echo "$HOSTNAME" > /etc/hostname
printf "127.0.0.1\tlocalhost\n::1\tlocalhost\n127.0.1.1\t%s\t%s" "$HOSTNAME" "$HOSTNAME" > /etc/hosts
echo "Wrote /etc/hostname:"
cat /etc/hostname
echo "Wrote /etc/hosts:"
cat /etc/hosts

# Account creation
useradd -m "$USERNAME"
chpasswd <<< "$USERNAME:$PASSWORD"
usermod -aG wheel "$USERNAME"
echo "Created user account \"$USERNAME\""

# setting the root password to the user's password then locking root user
chpasswd <<< "root:$PASSWORD"
passwd -l root
# This makes it so that the root user is unlocked in case of a system emergency (like a recovery prompt)
echo "[Service]\nEnvironment=SYSTEMD_SULOGIN_FORCE=1" > /etc/systemd/system/rescue.service.d/SYSTEMD_SULOGIN_FORCE.conf

# Sudo configuriation
echo '%wheel ALL=(ALL:ALL) ALL' > /etc/sudoers.d/00-wheel
chmod 440 /etc/sudoers.d/00-wheel

# Pacman configuration
# Enable multilib
sed -zi "s/#\[multilib\]\n#Include =/\[multilib\]\nInclude =/" /etc/pacman.conf
# Uncomments Color
sed -i "/^#Color/s/^#//" /etc/pacman.conf
pacman-key --populate archlinux
pacman -Sy

# More core for makepkg
sed -i "s/^#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$(nproc --ignore=2)\"/" /etc/makepkg.conf

# Locale Configuration
{
    echo "en_US.UTF-8 UTF-8"
    echo "fr_FR.UTF-8 UTF-8"
} > /etc/locale.gen
locale-gen
{
    echo "LANG=en_US.UTF-8"
    echo "LC_TIME=fr_FR.UTF-8"
    echo "LC_ADDRESS=fr_FR.UTF-8"
    echo "LC_MONETARY=fr_FR.UTF-8"
    echo "LC_MEASUREMENT=fr_FR.UTF-8"
    echo "LC_NUMERIC=fr_FR.UTF-8"
    echo "LC_PAPER=fr_FR.UTF-8"
    echo "LC_TELEPHONE=fr_FR.UTF-8"
} > /etc/locale.conf
{
    echo "KEYMAP=fr"
    echo "XKBLAYOUT=fr"
} > /etc/vconsole.conf

# Enable Services
systemctl enable paccache.timer
systemctl enable reflector.timer
systemctl enable pkgfile-update.timer
systemctl enable NetworkManager

# Install GRUB
sudo grub-install --target=x86_64-efi --efi-directory=/boot/ --bootloader-id=GRUB
sudo sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"\"/GRUB_CMDLINE_LINUX_DEFAULT=\"$KERNEL_ARGS\"/" /etc/default/grub
sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=1/' /etc/default/grub
sudo echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Download the next script
curl -o "/home/$USERNAME/install.sh" https://kensa.fr/arch/install-postboot.sh

echo "You can now reboot and run ~/install.sh"