#!/bin/bash
set -e

echo "Installing Sway dotfiles..."

BACKUP_DIR="$HOME/.config/bak-dotfiles-$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

# Backup existing configs
for dir in sway waybar wofi alacritty scripts; do
    if [ -d "$HOME/.config/$dir" ]; then
        mv "$HOME/.config/$dir" "$BACKUP_DIR/"
    fi
done

# Create symlinks
for dir in sway waybar wofi alacritty scripts; do
    ln -sfn "$(pwd)/$dir" "$HOME/.config/$dir"
done

# Make scripts executable
if [ -d "$HOME/.config/scripts" ]; then
    chmod +x ~/.config/scripts/*.sh
fi

# Install dependencies
sudo apt update
sudo apt install -y sway waybar wofi alacritty network-manager jq

# Install Nerd Font
FONTS_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONTS_DIR"
wget -O "$FONTS_DIR/JetBrainsMono.zip" \
"https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/JetBrainsMono.zip"
unzip -o "$FONTS_DIR/JetBrainsMono.zip" -d "$FONTS_DIR"
rm "$FONTS_DIR/JetBrainsMono.zip"
fc-cache -fv

echo "Done! Restart Sway."
