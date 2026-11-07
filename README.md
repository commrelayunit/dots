# dot-files: Kessel

A minimal, modular Arch Linux + Hyprland (Lua) + Quickshell desktop for **Kessel**, a persistent Arch VM. This README covers installing, updating, verifying and rolling back. GPL-3.0-or-later.

Fixed choices: **Kitty** is the only terminal. **Fuzzel** is the Quickshell-independent launcher (SUPER+R, and the fallback for SUPER+Space). Keybindings follow the **end-4/dots-hyprland** layout.

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

## The island

A dynamic island built from scratch on Quickshell (`.config/quickshell/kessel`). It **rests** on workspaces · music · clock · weather · CPU/RAM/network · battery, with live chips for recording, timers, Do Not Disturb and notifications. **Perspectives:** scroll over the island to rotate between them:
**Overview** (the default: workspaces, clock, weather, system),
**Time** (clock, full date, current weather, the next three days, any running timer),
**Music** (spinning cover, scrolling title · artist, a live cava visualizer that rests as a dot row when paused, time left, play/pause, and a progress line along the bottom edge; only while a player is open),
**Metrics** (CPU/RAM/↓/↑ sparklines, uptime) and
**Minimal** (time and date only).
Music switches in by itself when playback starts and back out after 8 s paused. Morphing uses spring physics (`springStiffness` / `springDamping` in `Theme.qml`).

Two round buttons float beside it: **⚙ left** opens quick settings, and **🔔 right** opens notifications (with a count badge; it shows a crossed-out bell while Do Not Disturb is on). It **morphs** into:

| Opens with | Panel |
| --- | --- |
| hover | Glance: avatar, time/date, weather, music controller, system |
| `SUPER+A` (or click it) | Quick settings: you (`~/.face`), Wi‑Fi, Bluetooth, output + mic sliders with device pickers, brightness, battery + power modes, wallpaper strip, Do Not Disturb, stay-awake, light/dark, notes, colour picker, screenshot, region/screen recording, timer, session |
| `SUPER+N` | Notifications (click = focus the app, × = dismiss) + calendar + weather forecast |
| `SUPER+Space` | Launcher (fuzzel if the island is down) |
| `SUPER+V` | Clipboard history with image thumbnails |
| `SUPER+Tab` | Overview: every workspace with live window previews; click to focus, drag to move |
| `SUPER+G` | Notes (`~/Documents/notes/kessel.md`) |
| `CTRL+SUPER+T` | Wallpaper & theme picker |
| `CTRL+ALT+Delete` | Session: lock · standby · log out · restart · shut down (destructive ones need a second press) |
| `SUPER+ALT+T` | Timer + stopwatch |

Hardware-dependent sections (battery, power profiles, brightness, Wi‑Fi, Bluetooth) appear only when the hardware and its service exist, so the same config runs on Kessel (VM) and on a laptop. **Notifications:** while the island runs, it is the notification server. dunst stays installed and D-Bus activates automatically whenever the island is stopped or has crashed.

## Theme: light / dark from the wallpaper

`~/.config/hypr/scripts/theme.sh` (also `CTRL+SUPER+SHIFT+D`, the quick-settings tile, the wallpaper picker):

- **Dark** = pitch black (`#000000`). **Light** = eggshell (`#F0EAD6`). Only the *accents* come from the wallpaper (matugen, cached per image).
- It writes `~/.local/state/kessel/theme/{colors.json,kitty.conf,fuzzel.ini,hyprland.lua}`. kitty reloads live, and fish + the Starship prompt follow kitty's palette. Hyprland borders, fuzzel, the island and GTK's colour scheme follow too.
- Wallpapers: drop images in `~/Pictures/Wallpapers`.

## Lock screen & login screen

- **Lock (`SUPER+L`)**: `kessel-lock`, a separate Quickshell config that runs only while locked. It has a blurred wallpaper, a frosted card (time, date, avatar, `$ whoami`, user), a "Locked" pill, and a bottom toolbar (keyboard layout · password · battery / sleep / shut down / restart; shut down and restart need the password). `CTRL+Enter` unlocks and keeps the session awake. Passwords are checked by PAM (`/etc/pam.d/hyprlock`). `lock.sh` falls back to **hyprlock** if the Quickshell lock can't confirm a secure lock within 3 s.
- **If a locker ever dies** (Hyprland shows "the lockscreen app died"), recover from SSH or another TTY: `hyprctl --instance 0 eval 'hl.clear_crashed_lockscreen()'`, or start hyprlock (`allow_session_lock_restore` is on). Tested.
- **Login (SDDM)**: `sddm-theme/kessel` is the same design for the Qt6 greeter, with a session picker and user switching. `~/Scripts/sddm-theme.sh test` previews it in a window; `install` / `uninstall` (sudo) copy the theme, current wallpaper and `~/.face`, and select it via `/etc/sddm.conf.d/10-kessel.conf`.
- **Cursor**: Bibata-Modern-Classic, as in end-4 (AUR `bibata-cursor-theme-bin`, installed with `--with-aur`).

## Performance note (VMs)

Without a GPU render node (Kessel has none), `general.lua` turns off blur and shadows automatically, because Hyprland draws in software there. The island also keeps its surface a small strip while resting. Together these took Hyprland from ~110% to ~9% CPU on Kessel. Real hardware keeps blur and shadows.

## Displays

`monitors.lua` arranges displays left→right and re-applies on hot-plug. With **2** displays the external goes to the right of the laptop. With **3**, the main display sits in the middle (set `MAIN_MONITOR` to its description to choose which one). Every display gets an island; panels open on the focused one.

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
| `--with-laptop` | Installs `pkglist-laptop.txt` (bluez, power-profiles-daemon). It does **not** enable their services |
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

## ~/Scripts

`~/Scripts` is a symlink to this repo's `scripts/`, so you can edit it in either place. Every script supports `--dry-run`.

| Script | What it does |
| --- | --- |
| `~/Scripts/install.sh` | Fresh install / re-apply (packages + config links). Passes any `install.sh` flag through |
| `~/Scripts/update.sh` | Pull (if a remote exists) → re-apply config → regenerate shortcuts → reload Hyprland, restart island, re-apply theme. `--system` adds `pacman -Syu`, `--aur` adds `yay -Sua` |
| `~/Scripts/backup.sh` | `~/Backups/kessel/kessel-<ts>.tar.zst`: repo as a git bundle, package lists, theme/install state, notes, `~/.face`, wallpapers. Keeps 10 (`--keep N`). No secrets |
| `~/Scripts/uninstall.sh` | Undo every deployment newest-first, restoring the original files. Asks first; `--purge` also removes generated state. Never removes packages |
| `~/Scripts/sddm-theme.sh` | Login screen: `test` (window preview), `install` / `uninstall` (sudo) |
| `~/Scripts/gen-shortcuts.sh` | Rebuild `docs/SHORTCUTS.md` from `keybinds.lua` |

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

The essentials (end-4 layout; full list in `docs/SHORTCUTS.md` or **SUPER + /**):

| Keys | Action |
| --- | --- |
| `SUPER + Return` / `SUPER + T` | Kitty |
| `SUPER + SHIFT + Return` | Recovery shell (`kitty bash --norc`) |
| `SUPER + R` / `SUPER + SHIFT + Space` | Island launcher / fuzzel |
| `SUPER + Space` | Focus mode: hide / show the island |
| `SUPER + Q` | Close window (**never** the terminal) |
| `SUPER + C` / `SUPER + W` | Neovim / browser |
| `SUPER + 1…0`, `CTRL + SUPER + 1…0` | Go to workspace |
| `SUPER + ALT + 1…0` | Send window to workspace |
| `SUPER + S` / `SUPER + ALT + S` | Toggle scratchpad / send window there |
| `SUPER + ←↑→↓` / `SUPER + SHIFT + ←↑→↓` | Focus / move window |
| `SUPER + ;` / `SUPER + '` | Narrower / wider |
| `SUPER + V`, `SUPER + .` | Clipboard, emoji picker |
| `SUPER + SHIFT + S`, `SUPER + SHIFT + C`, `SUPER + SHIFT + R` | Screenshot region, colour picker, record region |
| `SUPER + L` / `SUPER + SHIFT + L` | Lock / standby |
| `SUPER + /` | All shortcuts |

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
| Quickshell broken or missing | Nothing else depends on it: every island bind falls back (fuzzel, cliphist) and dunst takes over notifications. `CTRL + SUPER + R` restarts it; `~/.config/hypr/scripts/island.sh stop` stops it (works over SSH too); set `ENABLE_ISLAND = false` in `exec.lua` to disable |
| Hyprland module error | A red banner names the file. Other modules and the **rescue binds** (`SUPER+Return`, `SUPER+SHIFT+Return`, `SUPER+R`) still work. Fix the file; Hyprland reloads on save (or `CTRL+SHIFT+SUPER+R`) |
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
