# Settings panel in the island

> Tracked as issue #1 in this repo's tracker.

**Type:** feature · **Priority:** later

A Settings page inside the island (like Panacea / Impasto / Brain_Shell) so everyday preferences don't need editing files:

- Theme: dark/light, accent source (wallpaper / fixed colour), wallpaper folder
- Island: perspectives on/off and order, hover delay, side buttons, screen-corner radius, spring feel (stiffness/damping)
- Weather location + units, night-light temperature and schedule (auto / fixed times)
- Notifications: timeout, DND schedule
- Launcher: which sources (apps / calculator / URLs / translation), default translation languages
- Keybinds: read-only overview with conflict check (editing later)

**Approach:** a `Settings` service that reads/writes `~/.config/kessel/settings.json` (JSON, watched live) and overlays the defaults in `Config.qml`; generated files keep coming from `theme.sh`. Must keep working without the panel (file stays the source of truth).
