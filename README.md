# dots

Arch Linux + **Hyprland** (Lua config) + **Quickshell** desktop, built around a morphing **dynamic island**, with colours that follow your wallpaper (matugen) on a pitch-black or eggshell base. GPL-3.0-or-later.

> **Personal dotfiles. Use at your own risk.** This is the setup I run day to day, shared as-is. It is tuned to my habits and hardware, changes without notice, and comes with no support or guarantees. Read the scripts before running them, start with `--dry-run`, and keep a backup.

- **Terminal:** kitty running fish + Starship (end-4-style prompt).
- **Launchers:** the island launcher (`SUPER+R`: apps, calculator, URLs, offline translation) and fuzzel (`SUPER+SHIFT+Space`), which always works, even without Quickshell.
- **Keys:** end-4/dots-hyprland muscle memory. Press `SUPER+/` for the full list.
- **Safety first:** everything is a symlink into this repo, every install is reversible, and nothing depends on Quickshell to keep working.

New here? Start with **Install** below. Want to change something? Read [`AGENTS.md`](AGENTS.md) (repo map and pitfalls) and [`CONTRIBUTING.md`](CONTRIBUTING.md).

```
dots/
├── install.sh · installer/        # idempotent installer (packages, config links, theme, checks, rollback)
├── profiles/minimal.links         # repo path → ~ path for every linked config
├── pkglist.txt                    # official packages
├── pkglist-aur.txt                # optional AUR (--with-aur, via yay): OmniGlyph, Bibata cursor
├── pkglist-laptop.txt             # optional laptop extras (--with-laptop)
├── .config/
│   ├── hypr/                      # Hyprland (Lua): hyprland.lua loads monitors · env · general ·
│   │   │                          #   input · workspaces · exec · keybinds (THE registry) · custom
│   │   ├── lib/                   #   safety (rescue binds) · binder · floatmode
│   │   ├── scripts/               #   island · theme · lock · translate · screenshot · clipboard · …
│   │   └── hypridle.conf hyprlock.conf hyprpaper.conf (fallback)
│   ├── quickshell/kessel/         # the island: services/ (logic) · ui/ (views, panels, perspectives) · components/
│   ├── quickshell/kessel-lock/    # lock screen (separate process; hyprlock fallback)
│   ├── kitty/ fish/ starship.toml fuzzel/ dunst/
│   └── fontconfig/ gtk-3.0/ gtk-4.0/ omniglyph/
├── sddm-theme/kessel/             # login screen matching the lock screen
├── scripts/                       # = ~/Scripts: install · update · uninstall · backup · sddm-theme · gen-shortcuts
├── services/                      # future systemd units (never deployed automatically)
├── docs/                          # SHORTCUTS.md (generated) · THEME.md · DESIGN.md · backlog/
├── AGENTS.md · CONTRIBUTING.md · INSPIRATIONS.md · .github/   # contributor docs, credits, issue/PR templates
└── LICENSE                        # GPL-3.0-or-later
```

## The island

A dynamic island built from scratch on Quickshell (`.config/quickshell/kessel`). It **rests** on workspaces · music · clock · weather · CPU/RAM/network · battery, with live chips for recording, timers, Do Not Disturb and notifications. **Perspectives:** scroll over the island to rotate between them:
**Overview** (the default: workspaces, clock, weather, system),
**Time** (clock, full date, current weather, the next three days, any running timer),
**Music** (spinning cover, scrolling title · artist, a live cava visualizer that rests as a dot row when paused, time left, play/pause, and a progress line along the bottom edge; only while a player is open),
**Metrics** (CPU/RAM/↓/↑ sparklines, uptime) and
**Minimal** (time and date only).
Music switches in by itself when playback starts and back out after 8 s paused. Panels opened from another panel get a **← back** button (where the gear sits; also `Alt+←` or the mouse back button). Morphing uses spring physics (`springStiffness` / `springDamping` in `Theme.qml`).

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

Hardware-dependent sections (battery, power profiles, brightness, Wi‑Fi, Bluetooth) appear only when the hardware and its service exist, so the same config runs on a desktop, a laptop or a VM. **Notifications:** while the island runs, it is the notification server. dunst stays installed and D-Bus activates automatically whenever the island is stopped or has crashed.

## Theme: light / dark from the wallpaper

`~/.config/hypr/scripts/theme.sh` (also `CTRL+SUPER+SHIFT+D`, the quick-settings tile, the wallpaper picker):

- **Dark** = pitch black (`#000000`). **Light** = eggshell (`#F0EAD6`). Only the *accents* come from the wallpaper (matugen, cached per image).
- It writes `~/.local/state/kessel/theme/{colors.json,kitty.conf,fuzzel.ini,hyprland.lua}`. kitty reloads live, and fish + the Starship prompt follow kitty's palette. Hyprland borders, fuzzel, the island and GTK's colour scheme follow too.
- Wallpapers: drop images in `~/Pictures/Wallpapers`. **awww** draws them with an animated transition and remembers the last one (hyprpaper is the fallback); the island caches small thumbnails in `~/.cache/kessel/thumbs`.
- Switching is smooth: island colours animate, and the whole screen crossfades from a snapshot while apps repaint.

## Lock screen & login screen

- **Lock (`SUPER+L`)**: `kessel-lock`, a separate Quickshell config that runs only while locked. It has a blurred wallpaper, a frosted card (time, date, avatar, `$ whoami`, user), a "Locked" pill, and a bottom toolbar (keyboard layout · password · battery / sleep / shut down / restart; shut down and restart need the password). `CTRL+Enter` unlocks and keeps the session awake. Passwords are checked by PAM (`/etc/pam.d/hyprlock`). `lock.sh` falls back to **hyprlock** if the Quickshell lock can't confirm a secure lock within 3 s.
- **If a locker ever dies** (Hyprland shows "the lockscreen app died"), recover from SSH or another TTY: `hyprctl --instance 0 eval 'hl.clear_crashed_lockscreen()'`, or start hyprlock (`allow_session_lock_restore` is on). Tested.
- **Login (SDDM)**: `sddm-theme/kessel` is the same design for the Qt6 greeter, with a session picker and user switching. `~/Scripts/sddm-theme.sh test` previews it in a window; `install` / `uninstall` (sudo) copy the theme, current wallpaper and `~/.face`, and select it via `/etc/sddm.conf.d/10-kessel.conf`.
- **Cursor**: Bibata-Modern-Classic, as in end-4 (AUR `bibata-cursor-theme-bin`, installed with `--with-aur`).
- **Theme reach**: matugen colours flow into the island, Hyprland borders, kitty (16 colours), fish, Starship, fuzzel, Qt (qt6ct, Dolphin), KDE colour scheme, GTK 3/4 + libadwaita (`gtk.css`, e.g. OmniGlyph), btop, yazi, the lock screen and SDDM (on install).

## Performance note (no GPU)

Without a GPU render node (typical for VMs), `general.lua` turns off blur and shadows automatically, because Hyprland draws in software there. The island also keeps its surface a small strip while resting. Together these cut Hyprland's CPU use from ~110% to ~9% in software rendering. Machines with a GPU keep blur and shadows.

## Displays

`monitors.lua` arranges displays left→right and re-applies on hot-plug. With **2** displays the external goes to the right of the laptop. With **3**, the main display sits in the middle (set `MAIN_MONITOR` to its description to choose which one). Every display gets an island; panels open on the focused one.

## Install (fresh machine)

A new Arch install with Hyprland and a display manager (SDDM) is all that's assumed.

```sh
sudo pacman -S --needed git
git clone <repo> ~/dots && cd ~/dots          # any folder works; links point at wherever you cloned it

./install.sh --dry-run --with-aur --with-translate --apply-config   # 1. preview everything (changes nothing)
./install.sh --with-aur --apply-config                             # 2. packages (pacman + yay, bootstraps yay) + config links + theme
./install.sh --skip-packages --with-translate                      # 3. optional: offline translation (downloads ~150 MB)
./install.sh --set-shell                                           # 4. optional: fish as login shell
~/Scripts/sddm-theme.sh install                                    # 5. optional: matching login screen (sudo)
./install.sh --check                                               # 6. verify
```

Log out and back in once so Hyprland picks up the environment (Qt theme, cursor, menus).
After that, `~/Scripts/update.sh` keeps everything current.

| Flag | What it does |
| --- | --- |
| `--apply-config` | Link configs into `~` (backs up anything replaced) and generate the theme |
| `--with-aur` | `pkglist-aur.txt` via **yay** (installs yay-bin first if needed): OmniGlyph, Bibata cursor |
| `--with-laptop` | `pkglist-laptop.txt` (bluez, power-profiles-daemon, laptop audio firmware). It does **not** enable their services: run `sudo systemctl enable --now bluetooth` yourself |
| `--with-translate` | Offline translation runtime + EN↔DE, EN↔BG models (see below) |
| `--set-shell` | `chsh -s /usr/bin/fish` |
| `--skip-packages` | Config / extras only |
| `--rollback [ts]` | Undo a config deployment |

### Offline translation (launcher)

Needs a CPU with **AVX2**. Any recent laptop or desktop has it; on a VM, set the CPU type to `host`.

Type in the launcher (`SUPER+R`): `>de good morning` (EN→DE), `>bg …` (EN→BG), `>en …` (→EN, Cyrillic is detected as Bulgarian), or an explicit pair like `>de-bg Hallo`. Enter copies the result. It runs **entirely locally** using Bergamot, the same engine and models as translateLocally and Firefox's offline translation. A private Python 3.10 managed by `uv` holds it, so nothing needs compiling.

```sh
~/.config/hypr/scripts/translate.sh available     # every downloadable model
~/.config/hypr/scripts/translate.sh add en-fr     # add a language (pairs via English are automatic)
~/.config/hypr/scripts/translate.sh installed
~/.config/hypr/scripts/translate.sh remove en-fr-tiny
```

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
cd ~/dots && git pull                        # wherever you cloned the repo
./install.sh --profile minimal --apply-config  # picks up new links/packages; idempotent
hyprctl reload                               # Hyprland also auto-reloads on save
scripts/gen-shortcuts.sh                     # after editing keybinds.lua
```

Before deploying any Hyprland change, validate it offline:

```sh
KESSEL_STRICT=1 Hyprland --verify-config -c ~/.config/hypr/hyprland.lua
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
| `SUPER + Return` / `SUPER + T` | Kitty (runs fish) |
| `SUPER + SHIFT + Return` | Recovery shell (`kitty bash --norc`) |
| tap `SUPER` · `SUPER + R` / `SUPER + SHIFT + Space` | Island launcher (calculator, URLs) / fuzzel |
| `SUPER + E` · `SUPER + O` · `SUPER + C` · `SUPER + W` | Dolphin · Obsidian · Neovim · browser |
| `SUPER + Q` | Close window (**never** the terminal) |
| `SUPER + F` / `SUPER + D` / `SUPER + SHIFT + F` | Fullscreen / detach (float) this window / all windows floating |
| `SUPER + 1…0`, `CTRL + SUPER + 1…0` / `SUPER + ALT + 1…0` | Go to / send window to workspace |
| `SUPER + S` / `SUPER + ALT + S` | Scratchpad / send window there |
| `SUPER + ←↑→↓` / `SUPER + SHIFT + ←↑→↓` | Focus / move window |
| `SUPER + LMB drag` / `SUPER + RMB drag` | Move / resize window |
| `SUPER + ;` / `SUPER + '` | Narrower / wider |
| `SUPER + Space` | Focus mode (hide the island) |
| `SUPER + ALT + ←/→` | Previous / next island perspective (or scroll / two-finger swipe on the island) |
| `SUPER + A` / `SUPER + ALT + N` | Quick settings / notifications |
| `SUPER + G` / `SUPER + SHIFT + G` | Notes / kanban board |
| `SUPER + M` / `SUPER + SHIFT + V` | Media player / volume mixer |
| `SUPER + P` · `SUPER + N` · `SUPER + SHIFT + N` | Play-pause · next · previous |
| `CTRL + SUPER + V` / `SUPER + ALT + M` | Mute output / mute mic |
| `SUPER + V` · `SUPER + .` | Clipboard · emoji picker |
| `SUPER + SHIFT + S` · `SUPER + SHIFT + C` · `SUPER + SHIFT + R` | Screenshot region · colour picker · record region |
| `SUPER + =` / `SUPER + −` | Zoom in / out |
| `SUPER + L` / `SUPER + SHIFT + L` | Lock / standby |
| `CTRL + SUPER + R` | Reload Hyprland + restart the island |
| `SUPER + /` | All shortcuts |

## Operational verification

```sh
./install.sh --check        # config verifies, links OK, sshd active, WayVNC loopback-only,
                            # live binds present, no Hyprland config errors
ss -ltnp | grep 5900        # must show 127.0.0.1:5900 only
qs -c kessel ipc call island status
```

Remote desktop (optional): WayVNC listens **only** on `127.0.0.1:5900`. Reach it through an SSH tunnel:

```sh
ssh -L 5900:127.0.0.1:5900 <user>@<host>   # then point a VNC client at localhost:5900
```

## Recovery

| Problem | Fix |
| --- | --- |
| Quickshell broken or missing | Nothing else depends on it: every island bind falls back (fuzzel, cliphist) and dunst takes over notifications. `CTRL + SUPER + R` restarts it; `~/.config/hypr/scripts/island.sh stop` stops it (works over SSH too); set `ENABLE_ISLAND = false` in `exec.lua` to disable |
| Hyprland module error | A red banner names the file. Other modules and the **rescue binds** (`SUPER+Return`, `SUPER+SHIFT+Return`, `SUPER+R`) still work. Fix the file; Hyprland reloads on save (or `CTRL+SHIFT+SUPER+R`) |
| Keybinds gone entirely | SSH in and run `KESSEL_STRICT=1 Hyprland --verify-config -c ~/.config/hypr/hyprland.lua` to see the error |
| Fish broken | `SUPER + SHIFT + Return` gives plain bash. Over SSH: `ssh -t <host> bash --norc`. Revert the login shell with `chsh -s /usr/bin/bash` |
| Locked out of the lock screen | SSH in: `pkill -USR1 hyprlock` (unlocks) |

## Rollback

```sh
./install.sh --rollback --dry-run      # preview the latest rollback
./install.sh --rollback                # remove links, restore backed-up files + gsettings
./install.sh --rollback 20260101-120000  # a specific deployment (timestamp from the list below)
ls ~/.local/state/dot-files/backups/   # all backups
hyprctl reload
```

Your original configs (from before the first `--apply-config`) are in the oldest backup folder.

## Inspirations

Built on ideas from end-4/dots-hyprland, Panacea, ActivSpot, impasto, Brain_Shell, hyprwave and more. The full list, with links and what each one inspired, is in [`INSPIRATIONS.md`](INSPIRATIONS.md).

## Contributing

Bug reports and pull requests: see [`CONTRIBUTING.md`](CONTRIBUTING.md). Agents and newcomers: [`AGENTS.md`](AGENTS.md) maps the repo and lists known pitfalls.

## Licensing

GPL-3.0-or-later (see `LICENSE`). The projects in [`INSPIRATIONS.md`](INSPIRATIONS.md) were used as **inspiration only**, and no code or assets were copied from them. OmniGlyph (GPL-3.0-only) is an external AUR dependency and is not vendored.
