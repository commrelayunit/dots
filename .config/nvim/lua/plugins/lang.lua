-- SPDX-License-Identifier: GPL-3.0-or-later
-- Languages beyond LazyVim's extras: HTML/CSS (+ emmet), bash, QML.
-- (JS/TS, Python, LaTeX, Markdown, JSON, TOML come from lazyvim.json extras.)
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "html", "css", "scss", "bash", "qmljs", "latex", "bibtex",
      "javascript", "typescript", "tsx", "python", "markdown", "markdown_inline", "json",
      "toml", "yaml", "lua", "regex", "diff", "gitcommit", "csv" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        html = {},
        cssls = {},
        emmet_language_server = {},
        bashls = {},
        -- QML language server ships with Qt (qt6-declarative), not with Mason.
        qmlls = { mason = false, cmd = { "/usr/lib/qt6/bin/qmlls" } },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "shellcheck", "shfmt" } },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = { sh = { "shfmt" }, bash = { "shfmt" }, qml = { "qmlformat" } },
      formatters = {
        shfmt = { prepend_args = { "-i", "4", "-ci" } },
        qmlformat = { command = "/usr/lib/qt6/bin/qmlformat", args = { "-i", "$FILENAME" }, stdin = false },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = { linters_by_ft = { sh = { "shellcheck" }, bash = { "shellcheck" } } },
  },
}
