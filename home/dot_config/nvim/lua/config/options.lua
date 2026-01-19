-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

-- Slightly more context when scrolling
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Show which line you're on
opt.cursorline = true

-- Use spaces for tabs (LazyVim default is 2)
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2

-- Better search
opt.ignorecase = true
opt.smartcase = true

-- Better splits
opt.splitright = true
opt.splitbelow = true

-- Enable persistent undo
opt.undofile = true
opt.undolevels = 10000

-- LazyVim-specific settings
vim.g.autoformat = true -- Enable format on save (toggle with <leader>uf)
vim.g.lazyvim_picker = "snacks" -- Use Snacks picker instead of telescope
