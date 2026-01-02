#!/bin/bash
set -e

echo "Setting up Debian/Proxmox environment..."

# Detect if we need sudo
if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
else
    if command -v sudo &>/dev/null; then
        SUDO="sudo"
    else
        echo "ERROR: Not running as root and sudo is not installed."
        echo "Please run as root first: su -"
        echo "Then install sudo: apt install sudo"
        echo "Then add your user to sudo group: usermod -aG sudo $USER"
        exit 1
    fi
fi

# Get script directory (where dotfiles are)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Detect architecture for binary downloads
ARCH=$(uname -m)
case "$ARCH" in
    x86_64) ARCH_DEB="amd64"; ARCH_TAR="x86_64" ;;
    aarch64) ARCH_DEB="arm64"; ARCH_TAR="aarch64" ;;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

echo ""
echo "==> Updating package lists..."
$SUDO apt update

echo ""
echo "==> Installing essential packages..."
$SUDO apt install -y git curl wget unzip micro bat fzf

echo ""
echo "==> Installing bash-it..."
if [ ! -d "$HOME/.bash_it" ]; then
    git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it
    # Don't run install.sh as it overwrites bashrc - we have our own
else
    echo "    bash-it already installed, skipping"
fi

echo ""
echo "==> Installing starship..."
if ! command -v starship &>/dev/null; then
    curl -sS https://starship.rs/install.sh | $SUDO sh -s -- -y
else
    echo "    starship already installed, skipping"
fi

echo ""
echo "==> Installing zoxide..."
if ! command -v zoxide &>/dev/null; then
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
else
    echo "    zoxide already installed, skipping"
fi

echo ""
echo "==> Installing eza..."
if ! command -v eza &>/dev/null; then
    # eza is not in Debian repos, download from GitHub
    EZA_VERSION=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
    EZA_VERSION_NUM="${EZA_VERSION#v}"  # Remove 'v' prefix

    wget -qO /tmp/eza.tar.gz "https://github.com/eza-community/eza/releases/download/${EZA_VERSION}/eza_${ARCH_TAR}-unknown-linux-gnu.tar.gz"
    tar -xzf /tmp/eza.tar.gz -C /tmp
    $SUDO mv /tmp/eza /usr/local/bin/
    $SUDO chmod +x /usr/local/bin/eza
    rm /tmp/eza.tar.gz
    echo "    Installed eza ${EZA_VERSION}"
else
    echo "    eza already installed, skipping"
fi

echo ""
echo "==> Installing fastfetch..."
if ! command -v fastfetch &>/dev/null; then
    # fastfetch from GitHub releases
    FF_VERSION=$(curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest | grep '"tag_name"' | cut -d'"' -f4)

    wget -qO /tmp/fastfetch.deb "https://github.com/fastfetch-cli/fastfetch/releases/download/${FF_VERSION}/fastfetch-linux-${ARCH_DEB}.deb"
    $SUDO dpkg -i /tmp/fastfetch.deb || $SUDO apt install -f -y
    rm /tmp/fastfetch.deb
    echo "    Installed fastfetch ${FF_VERSION}"
else
    echo "    fastfetch already installed, skipping"
fi

echo ""
echo "==> Setting up bash configuration..."
cp "$SCRIPT_DIR/linux/bash/.bashrc" ~/

echo ""
echo "==> Enabling bash-it plugins..."
# Source bash-it directly to enable plugins
export BASH_IT="$HOME/.bash_it"
export BASH_IT_THEME='bobby'
source "$BASH_IT/bash_it.sh"
bash-it enable plugin git history 2>/dev/null || true
bash-it enable completion git system 2>/dev/null || true

echo ""
echo "============================================"
echo "Setup complete!"
echo "============================================"
echo ""
echo "Run 'source ~/.bashrc' or open a new terminal to activate."
echo ""
