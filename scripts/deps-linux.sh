#!/bin/bash

set -e

echo "Installing Linux dependencies..."

# Detect package manager
if command -v apt &> /dev/null; then
    PKG_MANAGER="apt"
    INSTALL_CMD="sudo apt install -y"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
    INSTALL_CMD="sudo dnf install -y"
elif command -v pacman &> /dev/null; then
    PKG_MANAGER="pacman"
    INSTALL_CMD="sudo pacman -S --noconfirm"
else
    echo "Unsupported package manager"
    exit 1
fi

echo "Detected package manager: $PKG_MANAGER"

# Core tools (available in most repos)
$INSTALL_CMD \
    stow \
    neovim \
    kitty \
    fzf \
    bat \
    zsh-autosuggestions \
    zsh-syntax-highlighting

# Tools that may need special handling per distro
if [[ "$PKG_MANAGER" == "apt" ]]; then
    # Ubuntu/Debian
    # eza (formerly exa) - needs separate repo on older Ubuntu
    if ! command -v eza &> /dev/null; then
        sudo apt install -y gpg
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo apt update
        sudo apt install -y eza
    fi

    # zoxide
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

    # starship
    curl -sS https://starship.rs/install.sh | sh -s -- -y

    # fastfetch
    sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch
    sudo apt update
    sudo apt install -y fastfetch

elif [[ "$PKG_MANAGER" == "pacman" ]]; then
    # Arch
    $INSTALL_CMD eza zoxide starship fastfetch

elif [[ "$PKG_MANAGER" == "dnf" ]]; then
    # Fedora
    $INSTALL_CMD eza zoxide starship fastfetch
fi

# Fonts - JetBrains Mono Nerd Font
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
if [[ ! -f "$FONT_DIR/JetBrainsMonoNerdFont-Regular.ttf" ]]; then
    echo "Installing JetBrains Mono Nerd Font..."
    curl -fLo "/tmp/JetBrainsMono.zip" \
        https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
    unzip -o /tmp/JetBrainsMono.zip -d "$FONT_DIR"
    fc-cache -fv
    rm /tmp/JetBrainsMono.zip
fi

echo "Linux dependencies installed!"
