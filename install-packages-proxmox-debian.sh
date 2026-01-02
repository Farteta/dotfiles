#!/bin/bash
set -e

echo "🚀 Setting up Linux environment..."

# Update system
apt update

# Install essentials
echo "📦 Installing essential packages..."
apt install -y git curl micro bat fzf fastfetch

# Install bash-it
if [ ! -d "$HOME/.bash_it" ]; then
    echo "🎨 Installing bash-it..."
    git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it
    ~/.bash_it/install.sh --silent
fi

# Install starship
if ! command -v starship &> /dev/null; then
    echo "⭐ Installing starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# Install zoxide
if ! command -v zoxide &> /dev/null; then
    echo "🗂️  Installing zoxide..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi

# Copy bashrc
echo "⚙️  Setting up bash configuration..."
cp linux/bash/.bashrc ~/

# Enable bash-it plugins
bash-it enable plugin git history
bash-it enable completion git system

echo "✅ Setup complete! Run 'source ~/.bashrc' to activate."
