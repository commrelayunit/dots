-- SPDX-License-Identifier: GPL-3.0-or-later
-- Bootstrap lazy.nvim (the plugin manager) and load LazyVim.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n", "ErrorMsg" }, { out, "WarningMsg" } }, true, {})
    return
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "plugins" },
  },
  defaults = { lazy = false, version = false },
  install = { colorscheme = { "habamax" } },
  concurrency = 4,                                  -- few parallel clones: dozens at once failed on a slow link
  git = { timeout = 300 },                          -- seconds per git operation (default 120)
  checker = { enabled = true, notify = false, concurrency = 2 },  -- update check, quietly (:Lazy to update)
  change_detection = { notify = false },
  rocks = { enabled = false },                      -- no luarocks needed
  performance = {
    rtp = { disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" } },
  },
})
