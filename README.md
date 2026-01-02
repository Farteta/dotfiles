# dotfiles

My personal dotfiles for macOS and Linux, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## What's Included

- **Zsh** - Shell config with aliases, completions, and modern CLI tools
- **Neovim** - [LazyVim](https://www.lazyvim.org/) setup with transparent Tokyo Night theme
- **Kitty** - GPU-accelerated terminal with Moonfly colorscheme

## Structure

```
dotfiles/
├── common/              # Cross-platform configs
│   ├── nvim/            # Neovim (LazyVim)
│   └── zsh/             # Zsh config
├── macos/               # macOS-specific
│   └── kitty/           # Kitty with macOS settings
├── linux/               # Linux-specific
│   └── kitty/           # Kitty without macOS settings
├── scripts/
│   ├── deps-macos.sh    # Homebrew dependencies
│   └── deps-linux.sh    # apt/dnf/pacman dependencies
└── install.sh           # Main installer
```

Stow creates symlinks from each package to your home directory. For example, `common/zsh/.zshrc` becomes `~/.zshrc`.

## Installation

### Fresh Machine

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh --deps    # Install dependencies + symlink configs
```

### Already Have Dependencies

```bash
./install.sh           # Just symlink configs
```

## Tools

These are installed by the dependency scripts:

| Tool | Description |
|------|-------------|
| [starship](https://starship.rs/) | Cross-shell prompt |
| [eza](https://github.com/eza-community/eza) | Modern `ls` replacement |
| [bat](https://github.com/sharkdp/bat) | `cat` with syntax highlighting |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smarter `cd` |
| [fastfetch](https://github.com/fastfetch-cli/fastfetch) | System info |
| [neovim](https://neovim.io/) | Text editor |
| [kitty](https://sw.kovidgoyal.net/kitty/) | Terminal emulator |

## Key Aliases

```bash
ls, ll, la, lt    # eza variants
cat               # bat
cd                # zoxide
g, gs, ga, gc...  # git shortcuts
```

## Theme

- **Terminal**: Moonfly (via [Gogh](https://gogh-co.github.io/Gogh/))
- **Neovim**: Tokyo Night (transparent)
- **Font**: JetBrains Mono Nerd Font
