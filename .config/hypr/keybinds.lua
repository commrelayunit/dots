-- SPDX-License-Identifier: GPL-3.0-or-later
-- Kessel — THE single source of truth for keybindings.
--
-- This file is data only. lib/binder.lua turns it into:
--   * real Hyprland binds (hl.bind)
--   * the shortcuts view   ($XDG_RUNTIME_DIR/kessel-shortcuts.txt, SUPER+/)
--   * docs/SHORTCUTS.md    (scripts/gen-shortcuts.sh)
--
-- Entry fields:
--   keys    "MODS + KEY"                      (required)
--   desc    human description                 (required)
--   group   section in the shortcuts view     (required)
--   exec    shell command string              (one of exec / dsp)
--   dsp     function() return hl.dsp.… end    (lazy: hl only exists inside Hyprland)
--   opts    hl.bind options (locked, repeating, mouse, …)
--   hidden  true → bound but not listed (used for expanded ranges)
--   doc     true → listed but not bound (summary line for a range)

local S = os.getenv("HOME") .. "/.config/hypr/scripts/"

local apps = {
    terminal = "kitty",
    recovery = "kitty bash --norc",
    launcher = "fuzzel",
    lock     = "pidof hyprlock || hyprlock",
}

local b = {}
local function add(e) b[#b + 1] = e end

-- Apps -----------------------------------------------------------------------
add { group = "Apps", keys = "SUPER + Return",         exec = apps.terminal, desc = "Terminal (kitty)" }
add { group = "Apps", keys = "SUPER + SHIFT + Return", exec = apps.recovery, desc = "Recovery shell (kitty + plain bash)" }
add { group = "Apps", keys = "SUPER + R",              exec = apps.launcher, desc = "App launcher (fuzzel)" }
add { group = "Apps", keys = "SUPER + V",              exec = S .. "clipboard.sh", desc = "Clipboard history (cliphist → fuzzel)" }
add { group = "Apps", keys = "SUPER + period",         exec = S .. "omniglyph.sh", desc = "Emoji / symbol picker (OmniGlyph, optional AUR)" }
add { group = "Apps", keys = "SUPER + slash",          exec = S .. "shortcuts.sh", desc = "Show this shortcuts list" }

-- Windows --------------------------------------------------------------------
add { group = "Windows", keys = "SUPER + Q",         dsp = function() return hl.dsp.window.close() end, desc = "Close window" }
add { group = "Windows", keys = "SUPER + C",         dsp = function() return hl.dsp.window.close() end, desc = "Close window (legacy)" }
add { group = "Windows", keys = "SUPER + F",         dsp = function() return hl.dsp.window.fullscreen() end, desc = "Toggle fullscreen" }
add { group = "Windows", keys = "SUPER + SHIFT + F", dsp = function() return hl.dsp.window.float({ action = "toggle" }) end, desc = "Toggle floating" }
add { group = "Windows", keys = "SUPER + P",         dsp = function() return hl.dsp.window.pseudo() end, desc = "Toggle pseudotile" }
add { group = "Windows", keys = "SUPER + J",         dsp = function() return hl.dsp.layout("togglesplit") end, desc = "Toggle split (dwindle)" }

for _, d in ipairs({ "left", "right", "up", "down" }) do
    add { group = "Windows", hidden = true, keys = "SUPER + " .. d,
          dsp = function() return hl.dsp.focus({ direction = d }) end, desc = "Focus " .. d }
    add { group = "Windows", hidden = true, keys = "SUPER + SHIFT + " .. d,
          dsp = function() return hl.dsp.window.move({ direction = d }) end, desc = "Move window " .. d }
end
add { group = "Windows", doc = true, keys = "SUPER + ←↑→↓",         desc = "Move focus" }
add { group = "Windows", doc = true, keys = "SUPER + SHIFT + ←↑→↓", desc = "Move window" }

add { group = "Windows", keys = "SUPER + mouse:272", dsp = function() return hl.dsp.window.drag() end,   opts = { mouse = true }, desc = "Drag window (LMB)" }
add { group = "Windows", keys = "SUPER + mouse:273", dsp = function() return hl.dsp.window.resize() end, opts = { mouse = true }, desc = "Resize window (RMB)" }

-- Workspaces -----------------------------------------------------------------
for i = 1, 10 do
    local key = tostring(i % 10)
    add { group = "Workspaces", hidden = true, keys = "SUPER + " .. key,
          dsp = function() return hl.dsp.focus({ workspace = i }) end, desc = "Workspace " .. i }
    add { group = "Workspaces", hidden = true, keys = "SUPER + SHIFT + " .. key,
          dsp = function() return hl.dsp.window.move({ workspace = i }) end, desc = "Move to workspace " .. i }
end
add { group = "Workspaces", doc = true, keys = "SUPER + 1…0",         desc = "Go to workspace 1–10" }
add { group = "Workspaces", doc = true, keys = "SUPER + SHIFT + 1…0", desc = "Move window to workspace 1–10" }
add { group = "Workspaces", keys = "SUPER + S",         dsp = function() return hl.dsp.workspace.toggle_special("magic") end, desc = "Toggle scratchpad" }
add { group = "Workspaces", keys = "SUPER + ALT + S",   dsp = function() return hl.dsp.window.move({ workspace = "special:magic" }) end, desc = "Move window to scratchpad" }
add { group = "Workspaces", keys = "SUPER + mouse_down", dsp = function() return hl.dsp.focus({ workspace = "e+1" }) end, desc = "Next workspace (scroll)" }
add { group = "Workspaces", keys = "SUPER + mouse_up",   dsp = function() return hl.dsp.focus({ workspace = "e-1" }) end, desc = "Previous workspace (scroll)" }

-- Screenshots ----------------------------------------------------------------
add { group = "Screenshots", keys = "SUPER + SHIFT + S", exec = S .. "screenshot.sh region", desc = "Region → clipboard + ~/Pictures/Screenshots" }
add { group = "Screenshots", keys = "Print",             exec = S .. "screenshot.sh region", desc = "Region → clipboard + file" }
add { group = "Screenshots", keys = "SHIFT + Print",     exec = S .. "screenshot.sh full",   desc = "Full screen → clipboard + file" }

-- Session --------------------------------------------------------------------
add { group = "Session", keys = "SUPER + L",           exec = apps.lock, desc = "Lock screen (hyprlock)" }
add { group = "Session", keys = "SUPER + CTRL + R",    dsp = function() return hl.dsp.reload_config() end, desc = "Reload Hyprland config" }
add { group = "Session", keys = "SUPER + CTRL + Q",    exec = S .. "island.sh restart", desc = "Restart Quickshell island" }
add { group = "Session", keys = "SUPER + SHIFT + M",   dsp = function() return hl.dsp.exit() end, desc = "Exit Hyprland" }

-- Media / hardware keys (work while locked) ------------------------------------
local L, LR = { locked = true }, { locked = true, repeating = true }
add { group = "Media", keys = "XF86AudioRaiseVolume", exec = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+", opts = LR, desc = "Volume up" }
add { group = "Media", keys = "XF86AudioLowerVolume", exec = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-",      opts = LR, desc = "Volume down" }
add { group = "Media", keys = "XF86AudioMute",        exec = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",     opts = L,  desc = "Mute output" }
add { group = "Media", keys = "XF86AudioMicMute",     exec = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle",   opts = L,  desc = "Mute microphone" }
add { group = "Media", keys = "XF86AudioPlay",        exec = "playerctl play-pause", opts = L, desc = "Play / pause" }
add { group = "Media", keys = "XF86AudioPause",       exec = "playerctl play-pause", opts = L, desc = "Play / pause", hidden = true }
add { group = "Media", keys = "XF86AudioNext",        exec = "playerctl next",       opts = L, desc = "Next track" }
add { group = "Media", keys = "XF86AudioPrev",        exec = "playerctl previous",   opts = L, desc = "Previous track" }

return { apps = apps, binds = b }
