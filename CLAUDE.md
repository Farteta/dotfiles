# CLAUDE.md

## Project

Personal dotfiles for CachyOS (Arch-based), centered on Hyprland, Waybar,
Rofi, Kitty, Zsh, and a custom SDDM login theme. GNU Stow manages the
home-directory configuration. macOS dotfiles live in a separate repository.

## Repository layout

- `hypr/`: Hyprland Lua config, hyprpaper, hyprlock, hypridle, Mako,
  xdg-desktop-portal config, and helper scripts.
- `waybar/`: bar config, CSS, and status/interaction scripts.
- `rofi/`, `kitty/`, `zsh/`, `desktop/`: launcher, terminal, shell, and desktop
  defaults. These are Stow packages alongside `hypr/` and `waybar/`.
- `sddm/`: theme and installer; it writes system files and is **not** stowed.
- `recovery/`: optional Btrfs/Snapper setup script; it is **not** stowed.
- `starship/`, `nvim/`, `yazi/`: present but not currently included in the
  bootstrap Stow package list.
- `pkglist.txt`: package snapshot for reference, not the bootstrap package list.

## Hyprland

`hypr/.config/hypr/hyprland.lua` is the active entry point. Its focused modules
are under `hypr/.config/hypr/config/` (monitors, environment, autostart,
plugins, appearance, layouts, input, bindings, and rules). The older
`hyprland.conf` is kept as a rollback reference and is ignored while the Lua
entry point exists. Do not make a change only in that legacy file.

The everyday LG C5 profile is in `config/monitors/lg_c5.lua`: 4K/144 Hz,
scale 2, 8-bit SDR. The 10-bit/HDR script is for temporary experiments, not
the default profile. Scrolling is the global layout; resize and groups are
keyboard submaps. Keep Waybar's submap indicator in sync if changing them.

Machine-local overrides belong in `~/.config/hypr/host.lua`, created from
`hypr/.config/hypr/host.lua.example` by the bootstrap script. Do not commit
the local override file.

## Setup and recovery

`bootstrap.sh` installs packages, backs up conflicting Stow targets under
`~/.local/state/dotfiles-backups/`, stows the six active packages, installs
the SDDM theme, creates `host.lua` if absent, installs/enables the
`hypr-edgehover` plugin through `hyprpm`, and enables services. It may invoke
`sudo` and alter system state; do not run it just to test a small config edit.
It supports `--no-packages`, `--no-services`, `--no-sddm`, and
`--no-hypr-plugins`.

`sddm/install.sh` **copies** the theme to `/usr/share/sddm/themes/hypr-dark`,
prepares a system-readable wallpaper and optional font, and writes
`/etc/sddm.conf.d/zz-hypr-dark.conf`. It does not deploy a symlink.

`recovery/setup-snapshots.sh` configures Snapper for the Btrfs root subvolume
and enables timeline/cleanup timers. Root snapshots do not include the separate
`/home` or `/boot` filesystems and are not an independent backup. Do not run a
rollback or delete snapshots without identifying the exact target and impact.

## Working conventions

- Preserve existing user changes; inspect `git status` before editing.
- Put scripts next to their parent config and mark executable when appropriate.
- Match the shared Midnight Aurora palette across Hyprland, Waybar, Rofi,
  Kitty, Mako, Hyprlock, and SDDM when changing colors.
- For Hyprland Lua changes, syntax-check with `luac -p` and inspect live errors
  with `hyprctl configerrors`. For shell scripts, use `bash -n` or `sh -n`.
- Use imperative, descriptive Git commit summaries. Do not push or rewrite
  history unless requested.
