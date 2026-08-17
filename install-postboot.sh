#! /usr/bin/env bash
set -euo pipefail

sudo timedatectl set-timezone Europe/Paris
sudo localectl set-keymap fr
sudo localectl set-x11-keymap fr

if command -v yay &> /dev/null; then
    echo "yay already installed, skipping"
else
    echo "Installing yay"
    sudo pacman -S --noconfirm --needed git base-devel
    tmpdir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay-bin.git --depth 1 "$tmpdir/yay-bin"
    (cd "$tmpdir/yay-bin" && makepkg -si --noconfirm)
    rm -rf "$tmpdir"
fi

echo "Installing fonts"
sudo pacman -S --noconfirm --needed inter-font noto-fonts-cjk ttf-dejavu ttf-hack ttf-jetbrains-mono ttf-jetbrains-mono-nerd ttf-opensans ttf-roboto