return {
  {
    "bluz71/vim-moonfly-colors",
    name = "moonfly",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.moonflyCursorColor = true
      vim.g.moonflyTransparent = true
      vim.g.moonflyNormalFloat = true

      -- Force transparency after colorscheme loads
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "moonfly",
        callback = function()
          -- Transparent statusline
          vim.api.nvim_set_hl(0, "StatusLine", { bg = "none" })
          vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "none" })

          -- Transparent cmdline with teal text and border
          vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", { bg = "none", fg = "#36c692" })
          vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { bg = "none", fg = "#36c692" })
        end,
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "moonfly",
    },
  },
}
