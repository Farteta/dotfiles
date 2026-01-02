#!/bin/bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# Install dependencies if --deps flag is passed
if [[ "$1" == "--deps" ]]; then
    echo "Installing dependencies..."
    "$DOTFILES_DIR/scripts/deps-$OS.sh"
    echo ""
fi

# Check if stow is installed
if ! command -v stow &> /dev/null; then
    echo "GNU Stow is not installed!"
    echo "Run: ./install.sh --deps"
    exit 1
fi

# Stow common configs
echo "Installing common configs..."
cd ~/dotfiles/common
stow -t ~ nvim zsh

# Stow OS-specific configs
echo "Installing $OS-specific configs..."
cd ~/dotfiles/$OS
stow -t ~ kitty

echo "✓ Dotfiles installed successfully!"
echo ""
echo "Don't forget to:"
echo "  - Restart your terminal (or run: source ~/.zshrc)"
echo "  - Restart Neovim and Kitty"
echo ""
echo "Tip: Run './install.sh --deps' to install all dependencies"
