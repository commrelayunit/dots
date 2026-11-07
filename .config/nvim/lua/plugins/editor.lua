-- SPDX-License-Identifier: GPL-3.0-or-later
-- VS Code-like workflow: side panel, images/PDF, git history, CSV tables.
return {
  -- Side panel (project tree). `nvim some/folder` opens straight into it.
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        hijack_netrw_behavior = "open_current",
        follow_current_file = { enabled = true },
        filtered_items = { visible = true, hide_dotfiles = false, hide_gitignored = false,
                           hide_by_name = { ".git", "node_modules" } },
        use_libuv_file_watcher = true,
      },
      window = { width = 32 },
    },
  },

  -- Images (and PDFs, first page) right in the editor, via kitty's graphics protocol.
  -- Opening an image/PDF shows it; markdown/LaTeX images and math render inline.
  {
    "folke/snacks.nvim",
    opts = {
      image = { enabled = true, doc = { inline = true, float = true } },
      picker = { hidden = true, sources = { files = { hidden = true } } },
      dashboard = { preset = { header = [[
 ██╗  ██╗███████╗███████╗███████╗███████╗██╗
 ██║ ██╔╝██╔════╝██╔════╝██╔════╝██╔════╝██║
 █████╔╝ █████╗  ███████╗███████╗█████╗  ██║
 ██╔═██╗ ██╔══╝  ╚════██║╚════██║██╔══╝  ██║
 ██║  ██╗███████╗███████║███████║███████╗███████╗
 ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝]] } },
    },
  },

  -- Git history: file / repo history and side-by-side diffs (lazygit: <leader>gg).
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Repo history" },
      { "<leader>gD", "<cmd>DiffviewOpen<cr>", desc = "Diff view (working tree)" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close diff view" },
    },
    opts = { enhanced_diff_hl = true },
  },

  -- CSV/TSV shown as an aligned table (toggle: <leader>uv).
  {
    "hat0uma/csvview.nvim",
    ft = { "csv", "tsv" },
    opts = { view = { display_mode = "border" } },
    config = function(_, opts)
      require("csvview").setup(opts)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "csv", "tsv" },
        callback = function(ev) require("csvview").enable(ev.buf) end,
      })
      if vim.tbl_contains({ "csv", "tsv" }, vim.bo.filetype) then require("csvview").enable(0) end
    end,
    keys = { { "<leader>uv", "<cmd>CsvViewToggle<cr>", desc = "Toggle CSV table view" } },
  },
}
