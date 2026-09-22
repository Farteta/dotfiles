# dotfiles

Personal dotfiles for Arch Linux with Hyprland, Waybar, Rofi, SDDM, Kitty, and Zsh.

## Layout

- `desktop/` -> desktop defaults (`mimeapps`, KDE globals, Dolphin)
- `hypr/` -> Hyprland, hyprpaper, hyprlock, hypridle, mako, portal config
- `waybar/` -> Waybar config, style, helper scripts
- `kitty/` -> Kitty terminal config
- `rofi/` -> Rofi application, command, and window launcher
- `sddm/` -> Custom SDDM login theme (hypr-dark) + install script
- `zsh/` -> Zsh and Powerlevel10k config
- `pkglist.txt` -> package snapshot reference

## Quick Start (Arch)

```bash
git clone https://github.com/Farteta/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

`bootstrap.sh` installs packages, backs up existing files that conflict with stow targets, stows configs, deploys the SDDM theme, creates a host override file for Hyprland, installs Hyprland plugins with `hyprpm`, and enables key services.

Existing conflicting files are moved under `~/.local/state/dotfiles-backups/bootstrap-*` before stow runs. Use `--no-packages`, `--no-services`, `--no-sddm`, or `--no-hypr-plugins` to skip those bootstrap phases.

## Manual Stow

```bash
cd ~/dotfiles
stow -t ~ desktop hypr kitty rofi waybar zsh
```

### Kitty Linux overrides

`kitty.conf` includes Linux-specific overrides from `~/.config/kitty/kitty.linux.conf`.

macOS dotfiles live in the separate `mac-dotfiles` repo.

### SDDM theme (hypr-dark)

The `sddm/` directory contains a custom SDDM theme that matches the hyprlock aesthetic. It is installed with a dedicated root-owned script instead of stow because it writes into system paths.

Manual deploy:

```bash
sudo ./sddm/install.sh
```

What `sddm/install.sh` does:

- copies `sddm/themes/hypr-dark` to `/usr/share/sddm/themes/hypr-dark`
- installs JetBrainsMono Nerd Font into `/usr/local/share/fonts/JetBrainsMonoNerdFont` when it is available in the calling user's local font directory, so the `sddm` user can render the theme correctly
- writes `/etc/sddm.conf.d/zz-hypr-dark.conf` to make `hypr-dark` the active theme and set the cursor/font defaults

Edit `sddm/themes/hypr-dark/theme.conf` to change the wallpaper path or accent colour.

## Hyprland Lua Configuration

`hyprland.lua` is the entry point. The configuration is split into focused
modules under `~/.config/hypr/config/` for monitors, environment, autostart,
plugins, appearance, layouts, input, bindings, and window rules.

The previous `hyprland.conf` remains in the repository as a rollback reference
during the migration and is ignored whenever `hyprland.lua` is present.

## Host Overrides (Hyprland)

Machine-specific settings are loaded from:

- `~/.config/hypr/host.lua`

The LG C5's everyday 4K/144 Hz, scale-2, 8-bit SDR profile now lives in
`hypr/.config/hypr/config/monitors/lg_c5.lua`. Use `host.lua` only for overrides
that should not be committed to the dotfiles.

Template location in repo:

- `hypr/.config/hypr/host.lua.example`

### Scrolling layout and keyboard modes

Scrolling is the global tiling layout (not assigned to particular workspaces).
The most useful bindings are:

| Keys | Action |
| --- | --- |
| `Super` + `Left` / `Right` | Focus the previous / next column |
| `Super` + `Alt` + `Left` / `Right` | Scroll the viewport by one column |
| `Super` + `Alt` + `Up` / `Down` | Make the focused column wider / narrower |
| `Super` + `Shift` + `Left` / `Right` | Swap the focused column with its neighbor |
| `Super` + `Alt` + `C` | Center the focused column |
| `Super` + `J` | Move a window into the next column, or back out |
| `Super` + `Shift` + `J` | Give the focused window its own column |

`Super` + `Shift` + `R` enters **resize mode**: arrow keys or `H/J/K/L` resize
the focused window in 20-pixel steps. `Super` + `G` enters **groups mode**:
`G` creates/toggles a tabbed group, `H/L` moves a window into a neighboring
group, `N/P` changes group tab, `U` removes a window from its group, and `K`
locks/unlocks the active group. In either mode, `Escape` or `Return` exits;
Waybar displays the active mode. If a mode ever gets stuck, run
`hyprctl dispatch 'hl.dsp.submap("reset")'` in a terminal.

Smart gaps remove gaps, borders, and rounding when an ordinary workspace has
one visible tiled window or a maximized window. Special workspaces keep their
normal appearance.

### LG C5 color experiments

The regular profile remains 8-bit SDR. To briefly test a single change from a
terminal, run one of these commands:

```sh
~/.config/hypr/scripts/lg-c5-display-test.sh 10bit 20
~/.config/hypr/scripts/lg-c5-display-test.sh hdr 20
```

The first keeps sRGB/SDR and tests only 10-bit output. The second tests 10-bit
HDR. Each automatically restores the normal profile after 20 seconds via a
Hyprland reload, so wait if the TV briefly loses signal. HDR is experimental;
judge it on the TV itself, since screenshots cannot establish how its panel
looks. Leave the regular profile in place until the picture and relevant apps
have been checked in person.

## Midnight Aurora Theme

The desktop uses a shared dark palette chosen to match the blue/cyan wallpaper:

- background: `#11141c`
- surface: `#191d27`
- foreground: `#e6eaf2`
- muted text: `#929cad`
- accent: `#7dcfff`
- success: `#9ece6a`
- warning: `#e0af68`
- error: `#f7768e`

Matching colors are applied to Hyprland, Waybar, Rofi, Kitty, Mako,
Hyprlock, and the custom SDDM theme. When changing the palette, keep the
semantic roles consistent so states remain recognizable across the desktop.

## Hyprland Plugins

`bootstrap.sh` installs and enables [`hypr-edgehover`](https://github.com/gfhdhytghd/hypr-edgehover) through `hyprpm`. The Hyprland config runs `hyprpm reload -n` on startup so enabled plugins load automatically.

## Update Flow

```bash
cd ~/dotfiles
git pull --rebase
./bootstrap.sh
```

## Recovery

On a Btrfs installation, `sudo ./recovery/setup-snapshots.sh` creates a root
Snapper configuration, a first read-only snapshot, and enables the timeline and
cleanup timers. It keeps a small rolling history (2 hourly, 5 daily, 1 weekly)
and leaves any existing root Snapper configuration untouched. Inspect snapshots
with `sudo snapper -c root list` and timer status with
`systemctl status snapper-timeline.timer snapper-cleanup.timer`.

The root snapshot does **not** include the separate `/home` Btrfs subvolume or
the `/boot` EFI partition. With systemd-boot, it is not an automatic boot-menu
rollback. Keep an independent backup of personal files and a recovery USB;
snapshots on the same SSD cannot protect against drive failure. The external
backup destination is intentionally not configured by this script.
