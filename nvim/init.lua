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

-- Define plugins in an array
local plugins = {
  {
    "blazkowolf/gruber-darker.nvim",
    config = function()
      vim.cmd([[colorscheme gruber-darker]])
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup()
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
    require("nvim-tree").setup()
    vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
    end,
  },
}

-- Setup plugins with lazy.nvim
require("lazy").setup(plugins)

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

-- Move the current line or selected lines up with Alt+Up
vim.api.nvim_set_keymap('n', '<A-Up>', ':m .-2<CR>==', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<A-Up>', ":m '<-2<CR>gv=gv", { noremap = true, silent = true })

-- Move the current line or selected lines down with Alt+Down
vim.api.nvim_set_keymap('n', '<A-Down>', ':m .+1<CR>==', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<A-Down>', ":m '>+1<CR>gv=gv", { noremap = true, silent = true })

-- Visual indenting without losing selection
vim.keymap.set("v", "<", "<gv", { noremap = true, silent = true })
vim.keymap.set("v", ">", ">gv", { noremap = true, silent = true })

