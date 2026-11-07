# Theme: one font, one palette

**Font:** JetBrainsMono Nerd Font (`ttf-jetbrains-mono-nerd`). **Sizes:** UI **11**, mono **12**.

Each tool has its own config format, so these values are repeated in the places listed below. Change them everywhere at once:

```sh
grep -rn "JetBrainsMono Nerd Font" ~/dot-files/.config ~/dot-files/installer
```

| Surface | File | Setting |
| --- | --- | --- |
| Kitty | `.config/kitty/kitty.conf` | `font_size 12.0` (mono) |
| Fuzzel / clipboard / shortcuts view | `.config/fuzzel/fuzzel.ini` | `size=11` |
| Notifications (dunst) | `.config/dunst/dunstrc` | `font = … 11` |
| Quickshell island | `.config/quickshell/kessel/Theme.qml` | `fontUi: 11`, `fontMono: 12` |
| Lock screen | `.config/hypr/hyprlock.conf` | `$font` |
| GTK 3/4 | `.config/gtk-*/settings.ini` | `gtk-font-name … 11` |
| GTK4 / libadwaita | `installer/config.sh` (`GSETTINGS_WANT`) | `font-name … 11`, `monospace-font-name … 12` |
| Qt + everything else | `.config/fontconfig/fonts.conf` | `monospace` and `sans-serif` → JetBrainsMono NF |

**Palette ("Kessel"):** base `#11131a` · surface `#1b1e27` · overlay `#2a2e3a` · text `#d8dae1` · subtext `#8b90a0` · accent `#8aadf4` · green `#a6da95` · red `#e06c75` · yellow `#eed49f` · purple `#c6a0f6`.
