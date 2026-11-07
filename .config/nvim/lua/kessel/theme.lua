-- SPDX-License-Identifier: GPL-3.0-or-later
-- Neovim colours from the desktop theme: ~/.local/state/kessel/theme/nvim.json
-- (written by theme.sh: pitch black / eggshell base, wallpaper accents), applied
-- with mini.base16. The file is watched, so a theme switch recolours open editors.
local M = {}
local path = (vim.env.XDG_STATE_HOME or (vim.env.HOME .. "/.local/state")) .. "/kessel/theme/nvim.json"

local fallback = { mode = "dark", palette = {
  base00 = "#000000", base01 = "#0b0b0b", base02 = "#262626", base03 = "#5a5a5a",
  base04 = "#9a9a9a", base05 = "#e8e8e8", base06 = "#f0f0f0", base07 = "#ffffff",
  base08 = "#e06c75", base09 = "#c6a0f6", base0A = "#eed49f", base0B = "#a6da95",
  base0C = "#8bd5ca", base0D = "#8aadf4", base0E = "#c6a0f6", base0F = "#5a5a5a" } }

local function read()
  local f = io.open(path, "r")
  if not f then return fallback end
  local ok, data = pcall(vim.json.decode, f:read("*a")); f:close()
  return (ok and type(data) == "table" and data.palette) and data or fallback
end

function M.apply()
  local t = read()
  vim.o.background = t.mode == "light" and "light" or "dark"
  require("mini.base16").setup({ palette = t.palette, use_cterm = false })
  vim.g.colors_name = "kessel"
  local p = t.palette
  local hl = function(g, o) vim.api.nvim_set_hl(0, g, o) end
  -- the editor sits on the same base as the terminal; panels a step up
  hl("Normal", { fg = p.base05, bg = p.base00 })
  hl("NormalNC", { fg = p.base05, bg = p.base00 })
  hl("SignColumn", { bg = p.base00 })
  hl("LineNr", { fg = p.base03, bg = p.base00 })
  hl("CursorLineNr", { fg = p.base0D, bg = p.base01, bold = true })
  hl("NormalFloat", { fg = p.base05, bg = p.base01 })
  hl("FloatBorder", { fg = p.base02, bg = p.base01 })
  hl("WinSeparator", { fg = p.base02, bg = p.base00 })
  hl("NeoTreeNormal", { fg = p.base05, bg = p.base00 })
  hl("NeoTreeNormalNC", { fg = p.base05, bg = p.base00 })
  hl("Visual", { bg = p.base02 })
  hl("Comment", { fg = p.base03, italic = true })
end

-- re-apply when theme.sh rewrites the file
function M.watch()
  if M._w then return end
  local w = (vim.uv or vim.loop).new_fs_event()
  if not w then return end
  M._w = w
  w:start(vim.fn.fnamemodify(path, ":h"), {}, vim.schedule_wrap(function(_, file)
    if file == "nvim.json" then pcall(M.apply) end
  end))
end

return M
