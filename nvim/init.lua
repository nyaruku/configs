--####################
--### NVIM OPTIONS ###
--####################
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.cindent = true
vim.o.mouse = 'a'
vim.o.showmode = false
-- Leader
vim.g.mapleader = " "
vim.g.maplocalleader = ' '
-- Optional: other general options
-- Show line numbers
vim.o.number = true
vim.o.relativenumber = true
vim.o.termguicolors = true
-- Enable break indent
vim.o.breakindent = true
-- Enable undo/redo changes even after closing and reopening a file
vim.o.undofile = true
-- Use system clipboard
vim.opt.clipboard = "unnamedplus"
-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true
-- Show tabs, spaces and nbsp's
vim.o.list = true
vim.opt.listchars = {
  tab = '» ',
  trail = '·',
  nbsp = '␣'
}

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
    "nyoom-engineering/oxocarbon.nvim",
    config = function()
      vim.cmd([[colorscheme oxocarbon]])
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup()
    end,
  },
  {
    "romgrk/barbar.nvim",
      dependencies = {
        "lewis6991/gitsigns.nvim", -- OPTIONAL: for git status
        "nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
      },
    init = function() vim.g.barbar_auto_setup = false end,
    opts = {},
  },
  {
    'norcalli/nvim-colorizer.lua',
  },
}
-- Setup plugins with lazy.nvim
require("lazy").setup(plugins)

require 'colorizer'.setup()

vim.keymap.set('n', 'p', '"+p', { noremap = true, silent = true })
vim.keymap.set('n', 'P', '"+P', { noremap = true, silent = true })
vim.keymap.set('x', 'p', '"+p', { noremap = true, silent = true })
vim.keymap.set('x', 'P', '"+P', { noremap = true, silent = true })

-- Move the current line or selected lines up with Alt+Up
vim.api.nvim_set_keymap('n', '<A-Up>', ':m .-2<CR>==', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<A-Up>', ":m '<-2<CR>gv=gv", { noremap = true, silent = true })

-- Move the current line or selected lines down with Alt+Down
vim.api.nvim_set_keymap('n', '<A-Down>', ':m .+1<CR>==', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<A-Down>', ":m '>+1<CR>gv=gv", { noremap = true, silent = true })

-- Visual indenting without losing selection
vim.keymap.set("v", "<", "<gv", { noremap = true, silent = true })
vim.keymap.set("v", ">", ">gv", { noremap = true, silent = true })

-- Window navigation
vim.keymap.set("n", "<leader><Left>", "<C-w>h", { noremap = true, silent = true })
vim.keymap.set("n", "<leader><Right>", "<C-w>l", { noremap = true, silent = true })
vim.keymap.set("n", "<leader><Up>", "<C-w>k", { noremap = true, silent = true })
vim.keymap.set("n", "<leader><Down>", "<C-w>j", { noremap = true, silent = true })

-- Open nvim-tree focused file in a new tab
-- vim.keymap.set("n", "<leader>t", ":NvimTreeFindFile<CR>:tabnew %<CR>", { noremap = true, silent = true })

-- Tab navigation with leader + Tab / Shift+Tab
vim.keymap.set("n", "<leader><Tab>", ":tabnext<CR>", { noremap = true, silent = true })        -- next tab
vim.keymap.set("n", "<leader><S-Tab>", ":tabprevious<CR>", { noremap = true, silent = true }) -- previous tab

-- Visual mode dedent with Shift+Tab
vim.keymap.set("v", "<S-Tab>", "<gv", { noremap = true, silent = true })

-- Close all buffers including nvim-tree
vim.keymap.set("n", "<leader>Q", ":NvimTreeClose | qa<CR>", { noremap = true, silent = true })

-- Barbar buffer navigation with <Space> + PageUp/PageDown
vim.keymap.set("n", "<Leader><PageUp>", "<Cmd>BufferPrevious<CR>", { silent = true, noremap = true })
vim.keymap.set("n", "<Leader><PageDown>", "<Cmd>BufferNext<CR>", { silent = true, noremap = true })

-- Clear highlight on ESC
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Paste at current line/position, keep cursor in place
local function paste_keep_cursor(register)
  local reg = register or '+'                      -- default to system clipboard
  local row, col = unpack(vim.api.nvim_win_get_cursor(0)) -- save cursor
  local mode = vim.fn.getregtype(reg)             -- check register type

  if mode:match('V') then
    -- linewise: paste at current line (current line shifts down)
    vim.cmd('normal! m`')                         -- mark position
    vim.cmd('normal! "'..reg..'P')                -- paste before current line
  else
    -- characterwise: paste at cursor
    vim.cmd('normal! m`')
    vim.cmd('normal! "'..reg..'p')
  end

  vim.api.nvim_win_set_cursor(0, {row, col})      -- restore cursor
end
