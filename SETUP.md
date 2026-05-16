# NixOS Flake Setup Guide

All files in this folder have been fixed for flake-based NixOS compatibility.
Clone the repo to `~/nixos-configuration` and follow the steps below.

## What was fixed

| Problem | Fix |
|---|---|
| `<home-manager/nixos>` channel import | Replaced by `flake.nix` — home-manager is now a flake input |
| `stateVersion = "25.11"` (not a real release) | Changed to `"25.05"` in both `configuration.nix` and `home.nix` |
| `python314` (doesn't exist in nixpkgs) | Replaced with `python312` |
| `pkgsCross.mingwW64.stdenv.cc` (pulls GBs, almost never cached) | Commented out with explanation |
| `src = /etc/nixos/…` in Plymouth derivation (impure absolute path) | Now uses `"${self}/…"` from the flake's `self` reference |
| All `/etc/nixos/config/…` hardcoded paths in every module | Replaced with `~/nixos-configuration/` via `config.home.homeDirectory` |
| `hyprland.conf` sourced from `/etc/nixos/…` | Symlinked to `~/.config/hypr/hyprland.conf` instead |
| `nixos-rebuild switch` alias (no flake path) | Now runs `nixos-rebuild switch --flake ~/nixos-configuration#ilyamiro` |
| `home-manager` block duplicated in `configuration.nix` | Removed — wired exclusively through `flake.nix` |

## Quick start

### 1. Clone the repo to your home directory

```sh
git clone https://github.com/ilyamiro/nixos-configuration.git ~/nixos-configuration
```

The path `~/nixos-configuration` is important — all the symlinks point there.

### 2. Replace hardware-configuration.nix

The existing file has the original author's disk UUIDs. Generate your own:

```sh
nixos-generate-config --show-hardware-config | sudo tee /etc/nixos/hardware-configuration.nix
```

Then copy it into the repo:

```sh
cp /etc/nixos/hardware-configuration.nix ~/nixos-configuration/hardware-configuration.nix
```

### 3. Fix GPU bus IDs

Edit `configuration.nix` and find the `hardware.nvidia.prime` block.
Update `nvidiaBusId` and `amdgpuBusId` to match your machine:

```sh
lspci | grep -E "VGA|3D"
# Example output:
#   01:00.0 VGA ... NVIDIA ...   ->  PCI:1:0:0
#   04:00.0 VGA ... AMD ...      ->  PCI:4:0:0
```

### 4. (Optional) Change the username

If your username is not `ilyamiro`, search and replace it in:
- `configuration.nix` (users block, sudo rules)
- `home.nix` (home.username, home.homeDirectory)
- The GTK `@import` URLs in `home.nix`

### 5. Build and switch

```sh
cd ~/nixos-configuration
sudo nixos-rebuild switch --flake .#ilyamiro
```

## About stateVersion

`system.stateVersion` and `home.stateVersion` are both `"25.05"`.
If you installed NixOS with a different release (e.g. `24.11`), set both values
to match your original installation. **Never change stateVersion after first install.**

## Live editing

Modules using `mkOutOfStoreSymlink` (kitty, rofi, matugen, cava, neovim init.lua,
hyprland scripts) point directly into `~/nixos-configuration`. Editing those files
takes effect immediately — just restart the relevant program. No rebuild needed.
