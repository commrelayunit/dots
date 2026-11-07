-- SPDX-License-Identifier: GPL-3.0-or-later
-- Startup safety: protected module loading, error reporting, rescue binds.

local M = { failures = {} }

local STRICT = os.getenv("KESSEL_STRICT") == "1"

-- Binds that must always exist, independent of Quickshell and of the
-- registry. They are only applied here if the registry did not bind them.
M.RESCUE = {
    { keys = "SUPER + Return",         cmd = "kitty",              desc = "Terminal (kitty)" },
    { keys = "SUPER + SHIFT + Return", cmd = "kitty bash --norc",  desc = "Recovery shell (kitty + bash)" },
    { keys = "SUPER + R",              cmd = "fuzzel",             desc = "Launcher (fuzzel)" },
}

M.bound = {}  -- keys successfully bound, filled by lib/binder.lua

-- Note: Hyprland wraps require() itself — a module that throws is shown in
-- Hyprland's own config-error banner and loading continues. This module adds
-- strict mode (KESSEL_STRICT=1, for --verify-config) and the rescue binds.
local function report(name, err)
    local msg = ("[kessel] module '%s' failed: %s"):format(name, tostring(err))
    table.insert(M.failures, msg)
    print(msg)
    if STRICT then error(msg, 0) end
end

--- Load a module by name in protected mode.
--- @param name string         module name (file <name>.lua next to hyprland.lua)
--- @param after? function     called with the module's return value
--- @param opts? {optional?: boolean}
function M.load(name, after, opts)
    opts = opts or {}
    package.loaded[name] = nil -- make config reloads pick up edits
    local ok, result = pcall(require, name)
    if not ok then
        if opts.optional and tostring(result):find("module '" .. name .. "' not found", 1, true) then
            return nil
        end
        report(name, result)
        return nil
    end
    if after then
        local ok2, err = pcall(after, result)
        if not ok2 then report(name, err) end
    end
    return result
end

function M.finish()
    for _, r in ipairs(M.RESCUE) do
        if not M.bound[r.keys] then
            local ok, err = pcall(hl.bind, r.keys, hl.dsp.exec_cmd(r.cmd), { description = "rescue: " .. r.desc })
            print(("[kessel] rescue bind %s -> %s (%s)"):format(r.keys, r.cmd, ok and "ok" or tostring(err)))
        end
    end
    if #M.failures > 0 then
        pcall(hl.notification.create, {
            text = table.concat(M.failures, "\n"),
            timeout = 15000,
            color = "rgba(e06c75ff)",
        })
    end
end

return M
