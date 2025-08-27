# run scripts/config_nvim.sh to install lazy

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- Syntax highlighting and filetype plugins
vim.cmd("syntax on")
vim.cmd("filetype plugin indent on")

-- Bootstrap lazy.nvim (in case not installed)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Setup plugins with lazy.nvim
require("lazy").setup({
  {
    "nyoom-engineering/oxocarbon.nvim",
    config = function()
      vim.cmd([[colorscheme oxocarbon]])
    end,
  },
})

-- Optional: other general options
vim.o.number = true         -- Show line numbers
vim.o.relativenumber = true -- relative line number
vim.o.termguicolors = true  -- Enable true color support

-- Keybinds
-- Use system clipboard for all yank/paste
vim.opt.clipboard = "unnamedplus"

-- Copy to clipboard with Alt+C in visual mode
vim.api.nvim_set_keymap('v', '<A-c>', '"+y', { noremap = true, silent = true })

-- Paste from clipboard with Alt+V in normal mode, no prompt
vim.api.nvim_set_keymap('n', '<A-v>', ':set paste<CR>"+p:set nopaste<CR>', { noremap = true, silent = true })

-- Paste from clipboard with Alt+V in insert mode, no prompt
vim.api.nvim_set_keymap('i', '<A-v>', '<Esc>:set paste<CR>"+pa:set nopaste<CR>', { noremap = true, silent = true })

