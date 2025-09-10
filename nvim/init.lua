# run scripts/config_nvim.sh to install lazy

vim.opt.expandtab = false        -- keep tabs as tabs
vim.opt.tabstop = 4              -- width of a tab character
vim.opt.shiftwidth = 4           -- width for indentation commands
vim.opt.softtabstop = 4          -- how many spaces a tab feels like
vim.opt.autoindent = true        -- keep previous line's indentation
vim.opt.smartindent = true       -- smart C-like indentation
vim.opt.cindent = true           -- advanced C/C++ indentation
vim.g.mapleader = " "      -- space as leader

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
  {
    "neovim/nvim-lspconfig",   -- LSP support
  },
  {
    "hrsh7th/nvim-cmp",        -- completion engine
  },
  {
    "hrsh7th/cmp-nvim-lsp",    -- LSP source for nvim-cmp
  },
  {
    "hrsh7th/cmp-buffer",      -- buffer source for nvim-cmp
  },
  {
    "L3MON4D3/LuaSnip",        -- snippets
  },
  {
    "saadparwaiz1/cmp_luasnip",-- snippet source
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
    "onsails/lspkind-nvim",   -- shows icons in completion menu
  },
  {
    "lukas-reineke/cmp-under-comparator", -- improves sorting
  },
}
-- Setup plugins with lazy.nvim
require("lazy").setup(plugins)

-- Setup LSP
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Clangd for C/C++
lspconfig.clangd.setup({
  cmd = {
    "clangd",
    "--background-index",           -- index symbols in background
    "--completion-style=detailed",  -- richer completion proposals
    "--header-insertion=never",     -- disable auto header insertion
    "--clang-tidy",                 -- optional: enable clang-tidy suggestions
  },
  init_options = {
    clangdFileStatus = true,
    -- fallbackFlags help single-file buffers or missing entries
    fallbackFlags = { "-std=c++20" },
  },
  capabilities = capabilities,
  filetypes = { "c", "cpp", "objc", "objcpp", "h", "hpp" },
  root_dir = lspconfig.util.root_pattern(
    "compile_commands.json",
    ".clangd",
    ".clang-tidy",
    ".clang-format",
    ".git"
  ),
})

-- Setup nvim-cmp
local cmp = require("cmp")
local lspkind = require("lspkind")
local compare = require("cmp.config.compare")
local cmp_under = require("cmp-under-comparator")

cmp.setup({
  completion = {
    autocomplete = { cmp.TriggerEvent.InsertEnter, cmp.TriggerEvent.TextChangedI },
  },
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-.>"] = cmp.mapping.complete(),        -- manual completion
    ["<CR>"] = cmp.mapping.confirm({ select = false }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
  }, {
    { name = "buffer" },
  }),
  formatting = {
    format = lspkind.cmp_format({
      mode = "symbol_text",  -- show symbol + text
      maxwidth = 50,
    }),
  },
  sorting = {
    comparators = {
      cmp_under.compare,
      compare.offset,
      compare.exact,
      compare.score,
      compare.recently_used,
      compare.locality,
      compare.kind,
      compare.sort_text,
      compare.length,
      compare.order,
    },
  },
})
vim.opt.completeopt = { "menu", "menuone", "noselect" } -- never auto-select

vim.lsp.handlers["textDocument/definition"] = function(_, result, ctx, _)
  if not result or vim.tbl_isempty(result) then
    vim.notify("No definition found", vim.log.levels.WARN)
    return
  end

  local def = result[1]
  local uri = def.uri
  local filename = vim.uri_to_fname(uri)  -- ✅ convert URI to file path

  if filename and filename ~= "" then
    vim.cmd("tabnew " .. filename)  -- open in new Barbar buffer
    vim.lsp.util.jump_to_location(def, "utf-8")
  else
    vim.notify("LSP definition returned an invalid filename", vim.log.levels.ERROR)
  end
end

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

-- Window navigation
vim.keymap.set("n", "<leader><Left>", "<C-w>h", { noremap = true, silent = true })
vim.keymap.set("n", "<leader><Right>", "<C-w>l", { noremap = true, silent = true })
vim.keymap.set("n", "<leader><Up>", "<C-w>k", { noremap = true, silent = true })
vim.keymap.set("n", "<leader><Down>", "<C-w>j", { noremap = true, silent = true })

-- Open nvim-tree focused file in a new tab
vim.keymap.set("n", "<leader>t", ":NvimTreeFindFile<CR>:tabnew %<CR>", { noremap = true, silent = true })

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

