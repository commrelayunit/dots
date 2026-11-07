-- SPDX-License-Identifier: GPL-3.0-or-later
-- pi coding agent (https://pi.dev). Two ways in:
--   <leader>ai  ask pi about the current file (visual: about the selection);
--               pi edits files, Neovim reloads them  (pablopunk/pi.nvim)
--   <leader>aP  pi's full interactive session in a terminal split
-- Needs the `pi` command on $PATH (and your own provider/API key set up in pi).
local function have_pi()
  if vim.fn.executable("pi") == 1 then return true end
  vim.notify("pi is not installed (https://pi.dev)", vim.log.levels.WARN)
  return false
end

return {
  {
    "pablopunk/pi.nvim",
    cmd = { "PiAsk", "PiAskSelection", "PiCancel", "PiLog", "PiToggleSession" },
    opts = { context = { diagnostics = { enabled = true } } },
    keys = {
      { "<leader>ai", function() if have_pi() then vim.cmd("PiAsk") end end, desc = "Ask pi (file)" },
      { "<leader>ai", ":<C-u>PiAskSelection<cr>", mode = "v", desc = "Ask pi (selection)" },
      { "<leader>ac", "<cmd>PiCancel<cr>", desc = "Cancel pi" },
      { "<leader>al", "<cmd>PiLog<cr>", desc = "pi log" },
      { "<leader>aP", function() if have_pi() then Snacks.terminal("pi", { win = { position = "right", width = 0.4 } }) end end, desc = "pi session (terminal)" },
    },
  },
  { "folke/which-key.nvim", opts = { spec = { { "<leader>a", group = "ai (pi)" } } } },
}
