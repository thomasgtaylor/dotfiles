-- Dependencies (one-time setup):
--   brew install tree-sitter-cli    (treesitter parser compilation)
--   brew install ripgrep            (telescope live_grep)
--   :Copilot setup                  (GitHub authentication)

-- Language configuration
local lsp_servers = { 'pyright', 'ruff' }
local treesitter_parsers = { 'python', 'lua' }

-- Plugin manager initialization
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
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
vim.keymap.set('n', '<Leader><Space>', ':nohls<CR>', { silent = true })
vim.keymap.set('n', '<C-k>', ':wincmd k<CR>', { silent = true })
vim.keymap.set('n', '<C-j>', ':wincmd j<CR>', { silent = true })
vim.keymap.set('n', '<C-h>', ':wincmd h<CR>', { silent = true })
vim.keymap.set('n', '<C-l>', ':wincmd l<CR>', { silent = true })
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { silent = true })
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<CR>', { silent = true })
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<CR>', { silent = true })
vim.keymap.set('n', '<leader>bo', '<cmd>BufOnly<CR>', { silent = true })
vim.keymap.set('n', '<S-j>', ':bp<CR>', { silent = true })
vim.keymap.set('n', '<S-k>', ':bn<CR>', { silent = true })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { silent = true })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { silent = true })
vim.keymap.set('n', 'n', 'nzz', { silent = true })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { silent = true })
vim.keymap.set('n', 'N', 'Nzz', { silent = true })


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
            'nvim-tree/nvim-web-devicons',
            'catppuccin/nvim',
        },
        config = function()
            require('bufferline').setup {
                highlights = require('catppuccin.special.bufferline').get_theme(),
                options = {
                    show_buffer_close_icons = false,
                },
            }
        end,
    },
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        opts = {},
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
      branch = 'master',
      dependencies = { 'nvim-lua/plenary.nvim' }
    },

    -- File management
    {
        'stevearc/oil.nvim',
        lazy = false,
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        keys = {
            { '-', '<cmd>Oil<CR>', desc = 'Open parent directory' },
        },
        opts = {},
    },

    -- Session management
    {
        'folke/persistence.nvim',
        event = 'BufReadPre',
        opts = {},
    },

    -- Copilot
    { 'github/copilot.vim' }, 

    -- Markdown
    {
      "iamcco/markdown-preview.nvim",
      ft = "markdown",
      build = ":call mkdp#util#install()",
    },

    -- Comments
    { 'numToStr/Comment.nvim' },

    -- Syntax highlighting
    {
        'nvim-treesitter/nvim-treesitter',
        lazy = false,
        build = ':TSUpdate',
        config = function()
            require('nvim-treesitter').install(treesitter_parsers)
        end,
    },

    -- LSP
    { 'neovim/nvim-lspconfig' },
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
        },
        config = function()
            local cmp = require('cmp')
            cmp.setup({
                sources = {
                    { name = 'nvim_lsp' },
                },
                mapping = cmp.mapping.preset.insert({
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                    ['<S-Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                }),
            })
        end,
    },
})

-- LSP (native Neovim 0.11+ API)
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        local opts = { buffer = args.buf, silent = true }
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    end,
})

vim.lsp.enable(lsp_servers)

-- Treesitter highlighting (auto-enables for any filetype with a parser)
vim.api.nvim_create_autocmd('FileType', {
    callback = function() pcall(vim.treesitter.start) end,
})
