#!/bin/bash

set -e

echo "Installing macOS dependencies..."

# Check for Homebrew
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# CLI tools
brew install \
    stow \
    neovim \
    starship \
    eza \
    bat \
    fzf \
    zoxide \
    fastfetch \
    zsh-autosuggestions \
    zsh-syntax-highlighting

# Terminal
brew install --cask kitty

# Fonts
brew install --cask font-jetbrains-mono-nerd-font

echo "macOS dependencies installed!"
