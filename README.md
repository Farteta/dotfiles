# dotfiles

Personal dotfiles for Linux (Hyprland + Waybar) and Kitty/Zsh, with macOS Kitty clipboard extras.

## Layout

- `desktop/` -> desktop defaults (`mimeapps`, KDE globals, Dolphin)
- `hypr/` -> Hyprland, hyprpaper, hyprlock, hypridle, mako, portal config
- `waybar/` -> Waybar config, style, helper scripts
- `kitty/` -> Kitty terminal config
- `macos/` -> macOS-only helpers (LaunchAgent + clipboard feedback script)
- `zsh/` -> Zsh and Powerlevel10k config
- `pkglist.txt` -> package snapshot reference

## Quick Start (Arch)

```bash
git clone https://github.com/Farteta/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

`bootstrap.sh` installs packages, stows configs, creates host override file for Hyprland, and enables key services.

## Manual Stow

```bash
cd ~/dotfiles
stow -t ~ desktop hypr kitty waybar zsh
```

### macOS extras

```bash
cd ~/dotfiles
stow -t ~ macos
launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/io.farteta.kitty-clipboard-feedback.plist"
launchctl kickstart -k "gui/$(id -u)/io.farteta.kitty-clipboard-feedback"
```

### Kitty OS overrides

`kitty.conf` loads per-OS overrides via `globinclude kitty.${KITTY_OS}.conf`.

- Linux: `~/.config/kitty/kitty.linux.conf`
- macOS: `~/.config/kitty/kitty.macos.conf`

## Host Overrides (Hyprland)

Main config sources:

- `~/.config/hypr/host.local.conf`

Use this file for machine-specific overrides like monitor layout/scale, device-specific input settings, etc.

Template location in repo:

- `hypr/.config/hypr/host.local.conf.example`

## Update Flow

```bash
cd ~/dotfiles
git pull --rebase
./bootstrap.sh
```
