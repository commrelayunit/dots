-- SPDX-License-Identifier: GPL-3.0-or-later
-- Global tiling ↔ floating layout mode.
--
--   floating mode: every existing window floats, and new windows open floating
--                  (a catch-all window rule that is switched on/off at runtime)
--   tiling mode:   windows this mode floated go back to tiling; windows that were
--                  already floating (pavucontrol, pickers, your own floats) stay
--
-- Bound to SUPER+SHIFT+F; the island's "Floating" tile calls the global
-- KesselToggleFloat via `hyprctl dispatch KesselToggleFloat`.
-- The mode survives config reloads (stored in $XDG_RUNTIME_DIR, so it resets at login).

local M = {}

local STATE = (os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/kessel-layout-mode"

local function read_state()
    local f = io.open(STATE, "r")
    if not f then return false end
    local v = f:read("*l"); f:close()
    return v == "floating"
end
local function write_state(on)
    local f = io.open(STATE, "w")
    if f then f:write(on and "floating\n" or "tiling\n"); f:close() end
end

M.floating = read_state()
M.floated = {}           -- addresses this mode floated (to un-float them later)

local rule = hl.window_rule({ name = "kessel-float-mode", match = { class = ".*" }, float = true })
rule:set_enabled(M.floating)

local function each_window(fn)
    local ok, wins = pcall(hl.get_windows)
    if not ok or type(wins) ~= "table" then return end
    for _, w in ipairs(wins) do pcall(fn, w) end
end

function M.set(on)
    M.floating = on
    rule:set_enabled(on)
    write_state(on)
    if on then
        M.floated = {}
        each_window(function(w)
            if not w.floating then
                M.floated[w.address] = true
                hl.dispatch(hl.dsp.window.float({ action = "enable", window = "address:" .. w.address }))
            end
        end)
    else
        each_window(function(w)
            if w.floating and M.floated[w.address] then
                hl.dispatch(hl.dsp.window.float({ action = "disable", window = "address:" .. w.address }))
            end
        end)
        M.floated = {}
    end
    -- tell the island (no-op if it is not running)
    hl.exec_cmd("qs -c kessel ipc call island layoutMode " .. (on and "floating" or "tiling"))
end

function M.toggle() M.set(not M.floating) end

-- reachable from outside: hyprctl dispatch KesselToggleFloat
_G.KesselToggleFloat = function() M.toggle() end

return M
