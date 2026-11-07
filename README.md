# dot-files: Kessel

A minimal, modular Arch Linux + Hyprland (Lua) + Quickshell desktop for **Kessel**, a persistent Arch VM. This README covers installing, updating, verifying and rolling back. GPL-3.0-or-later.

Fixed choices: **Kitty** is the only terminal and **Fuzzel** is the only launcher. Neither depends on Quickshell.

```
dot-files/
├── install.sh                 # idempotent installer (see below)
├── installer/                 # installer steps: common, packages, config, checks
├── profiles/minimal.links     # which repo paths get symlinked into ~
├── pkglist.txt                # official packages (minimal profile)
├── pkglist-aur.txt            # OPTIONAL AUR packages (only with --with-aur, via yay)
├── .config/
│   ├── hypr/                  # Hyprland Lua config (entry: hyprland.lua)
│   │   ├── hyprland.lua       #   tiny loader
│   │   ├── monitors.lua       #   displays
│   │   ├── env.lua            #   environment
│   │   ├── general.lua        #   UI / aesthetic
│   │   ├── input.lua          #   keyboard / pointer
│   │   ├── workspaces.lua     #   workspace, window, layer rules
│   │   ├── exec.lua           #   autostart (+ feature toggles)
│   │   ├── keybinds.lua       #   THE keybinding registry
│   │   ├── custom.lua         #   personal tweaks, loaded last
│   │   ├── lib/               #   safety (rescue binds) + binder (registry → binds + views)
│   │   ├── scripts/           #   screenshot, clipboard, shortcuts, omniglyph, island
│   │   └── hypridle.conf hyprlock.conf hyprpaper.conf
│   ├── quickshell/kessel/     # the island (ui/ + services/)
│   ├── kitty/ fuzzel/ dunst/ fish/ starship.toml
│   ├── fontconfig/ gtk-3.0/ gtk-4.0/ omniglyph/
├── scripts/gen-shortcuts.sh   # regenerate docs/SHORTCUTS.md from keybinds.lua
├── services/                  # FUTURE systemd units — never deployed by install.sh
└── docs/                      # MIGRATION_PLAN.md, SHORTCUTS.md, THEME.md
```

## Install (fresh machine)

```sh
sudo pacman -S --needed git
git clone <repo> ~/dot-files && cd ~/dot-files

./install.sh --dry-run --profile minimal --apply-config   # 1. preview (changes nothing)
./install.sh --profile minimal                           # 2. official packages (sudo pacman)
./install.sh --profile minimal --apply-config            # 3. link configs (backs up what it replaces)
./install.sh --check                                     # 4. verify
```

Optional extras, each one opt-in:

| Flag | What it does |
| --- | --- |
| `--with-aur` | Installs `pkglist-aur.txt` with **yay** (currently: `omniglyph`) |
| `--set-shell` | `chsh -s /usr/bin/fish`. Run it only after the shell checks below |
| `--skip-packages` | Config only |
| `--rollback [ts]` | Undo a config deployment (latest, or the given timestamp) |

**AUR helper (yay), one-time bootstrap:**

```sh
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin && (cd /tmp/yay-bin && makepkg -si)
```

The installer **never** enables services, touches SSH, networking or the firewall, installs Flatpak/Snap, or handles secrets. Re-running it is safe: anything already correct is reported with ✓ and left alone.

### How config deployment works

Each entry in `profiles/minimal.links` becomes a **symlink** from `~` into this repo. Edits made through `~/.config/...` therefore land in git, and `git status` shows them.

- If something already exists at a link target, it is **moved** (never deleted) to `~/.local/state/dot-files/backups/<timestamp>/`, with a diff preview printed first.
- Every run that changes something writes `backups/<timestamp>/MANIFEST`, which is what `--rollback` replays.
- gsettings font and colour values are recorded too, so rollback restores the previous values.

## Update

```sh
cd ~/dot-files && git pull                   # or edit in place
./install.sh --profile minimal --apply-config  # picks up new links/packages; idempotent
hyprctl reload                               # Hyprland also auto-reloads on save
scripts/gen-shortcuts.sh                     # after editing keybinds.lua
```

Before deploying any Hyprland change, validate it offline:

```sh
KESSEL_STRICT=1 Hyprland --verify-config -c ~/dot-files/.config/hypr/hyprland.lua
```

## Keybindings

There is a single source of truth: `.config/hypr/keybinds.lua`. From that registry, `lib/binder.lua`:

- creates the real binds,
- writes the in-session view (**SUPER + /**, opened in fuzzel),
- writes `docs/SHORTCUTS.md` (via `scripts/gen-shortcuts.sh`).

Duplicate keys in the registry are reported as config errors.

The essentials:

| Keys | Action |
| --- | --- |
| `SUPER + Return` | Kitty |
| `SUPER + SHIFT + Return` | Recovery shell (`kitty bash --norc`) |
| `SUPER + R` | Fuzzel |
| `SUPER + /` | Show all shortcuts |
| `SUPER + Q` | Close window (**never** the terminal) |
| `SUPER + V` | Clipboard history |
| `SUPER + SHIFT + S` / `Print` | Region screenshot → clipboard + `~/Pictures/Screenshots` |
| `SUPER + L` | Lock |
| `SUPER + .` | OmniGlyph (optional; shows a notification if not installed) |
| `SUPER + CTRL + R` | Reload Hyprland |

## Operational verification

```sh
./install.sh --check        # config verifies, links OK, sshd active, WayVNC loopback-only,
                            # live binds present, no Hyprland config errors
ss -ltnp | grep 5900        # must show 127.0.0.1:5900 only
qs -c kessel ipc call island status
```

Remote desktop: WayVNC listens **only** on `127.0.0.1:5900`. Reach it through an SSH tunnel:

```sh
ssh -L 5900:127.0.0.1:5900 velitchko@kessel   # then point a VNC client at localhost:5900
```

## Recovery

| Problem | Fix |
| --- | --- |
| Quickshell broken or missing | Nothing else depends on it. `SUPER + CTRL + Q` restarts it; `~/.config/hypr/scripts/island.sh stop` stops it; set `ENABLE_ISLAND = false` in `exec.lua` to disable |
| Hyprland module error | A red banner names the file. Other modules and the **rescue binds** (`SUPER+Return`, `SUPER+SHIFT+Return`, `SUPER+R`) still work. Fix the file and press `SUPER+CTRL+R` |
| Keybinds gone entirely | SSH in and run `KESSEL_STRICT=1 Hyprland --verify-config -c ~/.config/hypr/hyprland.lua` to see the error |
| Fish broken | `SUPER + SHIFT + Return` gives plain bash. Over SSH: `ssh -t kessel bash --norc`. Revert the login shell with `chsh -s /usr/bin/bash` |
| Locked out of the lock screen | SSH in: `pkill -USR1 hyprlock` (unlocks) |

## Rollback

```sh
./install.sh --rollback --dry-run      # preview the latest rollback
./install.sh --rollback                # remove links, restore backed-up files + gsettings
./install.sh --rollback 20261107-124529  # a specific deployment (e.g. the very first Hyprland swap)
ls ~/.local/state/dot-files/backups/   # all backups
hyprctl reload
```

The original autogenerated `hyprland.lua` (before this repo existed) is in `~/.local/state/dot-files/backups/20261107-124529/.config/hypr/`.

## Licensing

GPL-3.0-or-later (see `LICENSE`). The reference projects (Panacea, Brain_Shell, ActivSpot, Impasto, end-4/dots-hyprland) were used as **inspiration only**, and no code or assets were copied from them. OmniGlyph (GPL-3.0-only) is an external AUR dependency and is not vendored.
