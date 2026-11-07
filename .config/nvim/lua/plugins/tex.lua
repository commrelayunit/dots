-- SPDX-License-Identifier: GPL-3.0-or-later
-- LaTeX: vimtex (compile/view/errors) + texlab (completion, from the lang.tex extra).
-- Keys (localleader = \): \ll compile continuously on save · \lv jump to the spot
-- in the PDF · \le errors · \lc clean aux files · \lt table of contents.
-- Engine: pdflatex by default; put `%!TEX program = xelatex` (or lualatex) on the
-- first line of a file to switch for that document.
return {
  {
    "lervag/vimtex",
    init = function()
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk = {
        aux_dir = ".build",                 -- keep .aux/.log/.synctex out of the way
        options = { "-verbose", "-file-line-error", "-synctex=1", "-interaction=nonstopmode", "-shell-escape" },
      }
      vim.g.vimtex_compiler_latexmk_engines = { _ = "-pdf", pdflatex = "-pdf", xelatex = "-xelatex", lualatex = "-lualatex" }
      -- zathura: forward search (\lv) and Ctrl+click in the PDF jumps back to the source.
      -- Without xdotool (Wayland), the simple variant still opens and refreshes the PDF.
      vim.g.vimtex_view_method = vim.fn.executable("xdotool") == 1 and "zathura" or "zathura_simple"
      vim.g.vimtex_quickfix_open_on_warning = 0   -- only pop the error list for errors
      vim.g.vimtex_syntax_conceal_disable = 0
    end,
  },
}
