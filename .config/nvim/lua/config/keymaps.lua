-- SPDX-License-Identifier: GPL-3.0-or-later
-- Extra keys on top of LazyVim's (press <space> and wait to see them all).
local map = vim.keymap.set

-- VS Code-ish
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save" })
map("n", "<C-p>", function() Snacks.picker.files() end, { desc = "Find file" })
map("n", "<C-b>", "<cmd>Neotree toggle<cr>", { desc = "Toggle side panel" })
map("n", "<C-Tab>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next tab" })
map("n", "<C-S-Tab>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous tab" })

-- Open a folder: pick a directory under ~, make it the project, show the tree.
map("n", "<leader>fd", function()
  Snacks.picker.pick({
    title = "Open folder",
    finder = "proc",
    cmd = "fd",
    args = { "--type", "d", "--max-depth", "4", "--hidden", "--exclude", ".git",
             "--exclude", "node_modules", "--exclude", ".cache", ".", vim.env.HOME },
    format = "file",
    transform = function(item) item.file = item.text end,
    confirm = function(picker, item)
      picker:close()
      if not item then return end
      vim.cmd.cd(vim.fn.fnameescape(item.file))
      vim.cmd("Neotree reveal_force_cwd dir=" .. vim.fn.fnameescape(item.file))
    end,
  })
end, { desc = "Open folder" })
