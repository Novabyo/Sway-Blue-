#!/bin/bash
set -e

echo "Installing Sway dotfiles..."

# 1️⃣ Backup existing configs
BACKUP_DIR="$HOME/.config/bak-dotfiles-$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

for dir in sway waybar wofi alacritty scripts; do
    if [ -d "$HOME/.config/$dir" ]; then
        echo "Backing up existing $dir..."
        mv "$HOME/.config/$dir" "$BACKUP_DIR/"
    fi
done

# 2️⃣ Symlink new configs
for dir in sway waybar wofi alacritty scripts; do
    echo "Linking $dir..."
    mkdir -p "$HOME/.config"
    ln -sfn "$(pwd)/$dir" "$HOME/.config/$dir"
done

# 3️⃣ Make scripts executable
if [ -d "$HOME/.config/scripts" ]; then
    chmod +x ~/.config/scripts/*.sh
fi

# 4️⃣ Install dependencies
sudo apt update
sudo apt install -y sway waybar wofi alacritty network-manager jq

# 5️⃣ Optional: Nerd Fonts for icons
FONTS_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONTS_DIR"
wget -O "$FONTS_DIR/JetBrainsMono.zip" "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/JetBrainsMono.zip"
unzip -o "$FONTS_DIR/JetBrainsMono.zip" -d "$FONTS_DIR"
rm "$FONTS_DIR/JetBrainsMono.zip"
fc-cache -fv

echo "Installation complete! Restart Sway to apply changes."
