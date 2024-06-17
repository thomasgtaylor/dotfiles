-- Plugin manager initialization
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Mappings
vim.g.mapleader = ','
vim.keymap.set('n', '<Leader><Space>', ':nohls<CR>')
vim.keymap.set('n', '<C-k>', ':wincmd k<CR>')
vim.keymap.set('n', '<C-j>', ':wincmd j<CR>')
vim.keymap.set('n', '<C-h>', ':wincmd h<CR>')
vim.keymap.set('n', '<C-l>', ':wincmd l<CR>')
vim.keymap.set("n", "<D-p>", "<cmd>Telescope find_files<CR>")
vim.keymap.set("n", "<DS-F>", "<cmd>Telescope live_grep<CR>")
vim.keymap.set("n", "<DA-T>", "<cmd>BufOnly<CR>")
vim.keymap.set('n', '<S-j>', ':bp<CR>')
vim.keymap.set('n', '<S-k>', ':bn<CR>')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')

-- Options
vim.opt.background = 'dark'
vim.opt.clipboard:prepend { 'unnamedplus' }
vim.opt.cursorline = true
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
vim.opt.expandtab = true
vim.opt.hidden = true
vim.opt.number = true
vim.opt.shiftwidth = 2
vim.opt.showtabline = 2
vim.opt.smarttab = true
vim.opt.softtabstop = 2
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.tabstop = 2
vim.opt.termguicolors = true
vim.opt.wrap = false

-- Plugins
require('lazy').setup({
    -- UI
    {
        'catppuccin/nvim',
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd.colorscheme 'catppuccin-frappe'
        end,
    },
    {
        'akinsho/bufferline.nvim',
        lazy = false,
        version = '*',
        dependencies = {
            'kyazdani42/nvim-web-devicons',
            'catppuccin/nvim',
        },
        config = function()
            require('bufferline').setup {
                highlights = require('catppuccin.groups.integrations.bufferline').get(),
                options = {
                    show_buffer_close_icons = false,
                },
            }
        end,
    },

    -- Version control
    {
        'lewis6991/gitsigns.nvim',
        config = function()
            require('gitsigns').setup()
        end,
    },
    {
        'f-person/git-blame.nvim',
        event = "VeryLazy",
        init = function()
            vim.g.gitblame_enabled = 0
        end,
    },

    -- Buffer management
    { 'numtostr/BufOnly.nvim', cmd = 'BufOnly' },

    -- Browser
    {
      'nvim-telescope/telescope.nvim',
      tag = '0.1.8',
      dependencies = { 'nvim-lua/plenary.nvim' }
    },

    -- Code editing
    {
        'williamboman/mason.nvim',
        config = function()
            require("mason").setup()
        end,
    },
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        config = function()
            local lsp_zero = require('lsp-zero')
            lsp_zero.extend_lspconfig()
            lsp_zero.on_attach(function(client, bufnr)
                lsp_zero.default_keymaps({ buffer = bufnr })
            end)
        end,
    },
    { 'neovim/nvim-lspconfig' },
    { 'hrsh7th/nvim-cmp' },
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'L3MON4D3/LuaSnip' },
})

local lspconfig = require('lspconfig')
lspconfig.pyright.setup {}
lspconfig.ruff.setup {}
