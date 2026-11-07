# Island services

Each service is a QML singleton with no UI. The UI under `ui/` only reads them.

| Service | State | Notes |
| --- | --- | --- |
| `Time.qml` | **implemented** | One `SystemClock` (minute precision) |
| `IslandState.qml` | **implemented** | Visibility/expansion + `IpcHandler` target `island` |
| `Media` (MPRIS) | planned | `Quickshell.Services.Mpris`. Enabled only after it has been verified reliable in the session |
| `Notifications` | planned (not used) | dunst is the single notification path; the island must not register a second server |
| `Audio` | planned | `Quickshell.Services.Pipewire` default sink volume/mute |
| `Launcher` | planned | Would only *call* fuzzel; fuzzel stays independent |
