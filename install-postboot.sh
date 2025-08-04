#! /usr/bin/env bash

sudo timedatectl set-timezone Europe/Paris
sudo localectl set-keymap fr
sudo localectl set-x11-keymap fr

echo "Installing yay"
cd /tmp
sudo pacman -S --noconfirm --needed git base-devel
git clone https://aur.archlinux.org/yay-bin.git --depth 1
cd yay-bin
makepkg -si
cd "$HOME" || exit

echo "Installing fonts"
sudo pacman -S --noconfirm --needed inter-font noto-fonts-cjk ttf-dejavu ttf-hack ttf-jetbrains-mono ttf-jetbrains-mono-nerd ttf-opensans ttf-roboto