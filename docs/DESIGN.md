# Design decisions

Why the dots are built the way they are. For *how* to use them see the [README](../README.md); for the repo map and pitfalls see [AGENTS.md](../AGENTS.md); for colours see [THEME.md](THEME.md).

## Safety first

- **Nothing depends on Quickshell.** Every island keybind has a fallback (fuzzel, cliphist, hyprlock, dunst), and `lib/safety.lua` registers rescue binds (`SUPER+Return` kitty, `SUPER+SHIFT+Return` plain bash) before any other module loads.
- **Never break remote access.** The installer doesn't touch SSH, the firewall, networking or the login shell (`--set-shell` only on request). WayVNC, if used, is bound to `127.0.0.1` and reached through an SSH tunnel.
- **Bash stays the recovery shell.** fish is the interactive shell; bash is always one keybind away.
- **`SUPER+Q` closes windows, never opens a terminal**, so a reflex can't spawn shells.

## Deployment = symlinks

Each entry in `profiles/minimal.links` is a symlink from `~` into the repo, so edits land in git and drift shows in `git status`. Anything already at a target is **moved** (never deleted) into a timestamped backup with a `MANIFEST`, which is what `--rollback` and `uninstall.sh` replay. A `--dry-run` previews every change.

## Packages

- Official repos first (`pkglist.txt`). AUR only via `pkglist-aur.txt` and an explicit `--with-aur` (yay). No Flatpak or Snap.
- Every command the dots call comes from a package list. Undeclared runtime dependencies get a commented entry (e.g. `gtk4-layer-shell` for OmniGlyph).
- Hardware extras (`pkglist-laptop.txt`) are opt-in, and their services are never enabled automatically.

## Hyprland: modular Lua

`hyprland.lua` only loads modules, each in a protected call: `monitors` · `env` · `general` · `input` · `workspaces` · `exec` · `keybinds` · `custom`. A broken module shows a banner while the rest still applies. `keybinds.lua` is **pure data**: `lib/binder.lua` turns it into binds, the `SUPER+/` list and `docs/SHORTCUTS.md`, so the three can't disagree. Layout follows end-4/dots-hyprland for muscle memory. Every change is checked with `KESSEL_STRICT=1 Hyprland --verify-config` first.

## The island

One morphing surface instead of a bar: resting perspectives (Overview, Time, Music, Metrics, Minimal) and panels that grow out of it. Logic lives in `services/` singletons, visuals in `ui/` and `components/`. The surface stays a small strip while resting, because a large transparent layer is expensive without a GPU. The island owns notifications while it runs; dunst D-Bus-activates whenever it doesn't, so there's always exactly one notification server.

## Lock and login

The lock screen is a separate Quickshell config (`kessel-lock`) that runs only while locked, so an island crash can't take the lock down with it. `lock.sh` falls back to hyprlock if a secure lock isn't confirmed within 3 s. The SDDM theme mirrors the lock screen and is installed only by an explicit script (sudo).

## Theme

One pipeline (`theme.sh`): fixed bases (pitch black / eggshell) with accents from the wallpaper via matugen, written into every app that supports it. Generated files are never edited by hand. Details in [THEME.md](THEME.md).

## Services

`services/` is a placeholder. Nothing there is deployed or enabled by the installer. Any future unit is its own opt-in step with a reviewed unit file, a dry run and an explicit `systemctl enable`. Units that open network ports, hold credentials or store data need a separate safety review (localhost binding, secret storage, shutdown behaviour).

## Licensing

GPL-3.0-or-later. Projects in [INSPIRATIONS.md](../INSPIRATIONS.md) are inspiration only: no code or assets copied, and AGPL code is never imported.
