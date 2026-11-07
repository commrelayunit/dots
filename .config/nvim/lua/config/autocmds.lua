-- SPDX-License-Identifier: GPL-3.0-or-later
-- Plain text: soft-wrap and spell check, like a note editor.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "text", "markdown", "tex", "gitcommit" },
  callback = function() vim.opt_local.wrap = true; vim.opt_local.linebreak = true; vim.opt_local.spell = true end,
})
