#!/bin/bash
set -e

echo "Installing Sway dotfiles..."

############################
# Detect Distro
############################

if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "Cannot detect distro."
    exit 1
fi

DISTRO=$ID
echo "Detected distro: $DISTRO"

############################
# Package Installation
############################

install_packages_debian() {
    sudo apt update
    sudo apt install -y \
        sway waybar wofi alacritty \
        network-manager jq git curl wget unzip

    install_nerd_font_manual
}

install_packages_fedora() {
    sudo dnf install -y \
        sway waybar wofi alacritty \
        NetworkManager jq git curl wget unzip

    install_nerd_font_manual
}

install_packages_arch() {
    echo "Installing official packages (Arch)..."

    sudo pacman -Sy --needed --noconfirm \
        sway waybar wofi alacritty \
        networkmanager jq git curl wget unzip base-devel

    ################################
    # Detect AUR Helper
    ################################

    if command -v yay &> /dev/null; then
        AUR_HELPER="yay"
    elif command -v paru &> /dev/null; then
        AUR_HELPER="paru"
    else
        echo "No AUR helper found. Installing yay..."

        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay
        makepkg -si --noconfirm
        cd -
        rm -rf /tmp/yay

        AUR_HELPER="yay"
    fi

    ################################
    # Install Nerd Font via AUR
    ################################

    echo "Installing JetBrainsMono Nerd Font (AUR)..."

    $AUR_HELPER -S --needed --noconfirm \
        ttf-jetbrains-mono-nerd

    fc-cache -fv > /dev/null
}

############################
# Nerd Font Manual Installer (Debian/Fedora)
############################

install_nerd_font_manual() {
    echo "Installing JetBrainsMono Nerd Font..."

    FONTS_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONTS_DIR"

    wget -q -O "$FONTS_DIR/JetBrainsMono.zip" \
    "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/JetBrainsMono.zip"

    unzip -o "$FONTS_DIR/JetBrainsMono.zip" -d "$FONTS_DIR" > /dev/null
    rm "$FONTS_DIR/JetBrainsMono.zip"

    fc-cache -fv > /dev/null
}

############################
# Run Distro Installer
############################

case "$DISTRO" in
    debian|ubuntu|linuxmint)
        install_packages_debian
        ;;
    fedora)
        install_packages_fedora
        ;;
    arch|endeavouros|manjaro)
        install_packages_arch
        ;;
    *)
        echo "Unsupported distro: $DISTRO"
        exit 1
        ;;
esac

############################
# Backup Existing Configs
############################

BACKUP_DIR="$HOME/.config/bak-dotfiles-$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

for dir in sway waybar wofi alacritty scripts; do
    if [ -d "$HOME/.config/$dir" ]; then
        echo "Backing up $dir..."
        mv "$HOME/.config/$dir" "$BACKUP_DIR/"
    fi
done

############################
# Symlink Dotfiles
############################

for dir in sway waybar wofi alacritty scripts; do
    echo "Linking $dir..."
    ln -sfn "$(pwd)/$dir" "$HOME/.config/$dir"
done

if [ -d "$HOME/.config/scripts" ]; then
    chmod +x ~/.config/scripts/*.sh
fi

############################
# Install pfetch (Proper Method)
############################

echo "Installing pfetch..."

if ! command -v pfetch &> /dev/null; then
    curl -sL https://raw.githubusercontent.com/dylanaraps/pfetch/master/pfetch \
        -o /tmp/pfetch
    sudo install -m 755 /tmp/pfetch /usr/local/bin/pfetch
    rm /tmp/pfetch
fi

############################
# Enable NetworkManager
############################

sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager

############################

echo "Installation complete!"
echo "Restart Sway to apply changes."
