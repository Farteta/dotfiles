#!/bin/bash

set -e

echo "Installing dotfiles..."

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
else
    echo "Unsupported OS"
    exit 1
fi

echo "Detected OS: $OS"

# Check if stow is installed
if ! command -v stow &> /dev/null; then
    echo "GNU Stow is not installed!"
    if [[ "$OS" == "macos" ]]; then
        echo "Install with: brew install stow"
    else
        echo "Install with: sudo apt install stow  (or your package manager)"
    fi
    exit 1
fi

# Stow common configs
echo "Installing common configs..."
cd ~/dotfiles/common
stow -t ~ nvim zsh yazi

# Stow OS-specific configs
echo "Installing $OS-specific configs..."
cd ~/dotfiles/$OS
stow -t ~ kitty

echo "✓ Dotfiles installed successfully!"
echo ""
echo "Don't forget to:"
echo "  - Restart your terminal (or run: source ~/.zshrc)"
echo "  - Restart Neovim and Kitty"
