## What & why


## How I tested it
<!-- What you actually ran/clicked, and what you could NOT test (hardware, audio, laptop…). -->


## Checklist
- [ ] `KESSEL_STRICT=1 Hyprland --verify-config -c ~/.config/hypr/hyprland.lua` → `config ok`
- [ ] `bash -n` on changed scripts; `./install.sh --dry-run --with-aur --apply-config` changes nothing
- [ ] Island restarts cleanly (`island.sh restart`), no new `ERROR` in `qs log -c kessel`
- [ ] Keybinds only in `keybinds.lua` and `scripts/gen-shortcuts.sh` re-run (if keys changed)
- [ ] New deps listed in the right `pkglist*.txt` with a reason
- [ ] Colours via `theme.sh` / `Theme.qml` (nothing hard-coded)
- [ ] No services enabled, no SSH/network changes, no secrets, no copied code
- [ ] Docs updated (`README.md` / `docs/`) if behaviour or keys changed
- [ ] New files carry the SPDX header (GPL-3.0-or-later)
