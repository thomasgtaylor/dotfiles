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

-- Options
vim.opt.background = 'dark'
vim.opt.clipboard:prepend {'unnamedplus'}
vim.opt.cursorline = true
vim.opt.completeopt = {'menu', 'menuone', 'noselect'}
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
    'nvim-lualine/lualine.nvim',
    lazy = false,
    dependencies = {
      'kyazdani42/nvim-web-devicons',
    },
    config = function()
      require('lualine').setup {
        options = { theme = 'catppuccin' },
      }
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
  { 'lewis6991/gitsigns.nvim', event = 'VeryLazy' },

  -- Buffer management
  { 'numtostr/BufOnly.nvim', cmd = 'BufOnly' },

  -- Browser
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim'
    },
    config = function()
      local telescope = require('telescope')
      telescope.setup{
        defaults = {
          file_ignore_patterns = {
            "node_modules",
          },
        },
        extensions = {
          file_browser = {
              hijack_netrw = true,
          },
        },
      }
      telescope.load_extension "file_browser"
      vim.keymap.set('n', '<Leader>ff', '<cmd>:Telescope file_browser<CR>')
      vim.keymap.set('n', '<Leader>fs', '<cmd>:Telescope find_files<CR>')
      vim.keymap.set('n', '<Leader>fg', '<cmd>:Telescope live_grep<CR>')
      vim.keymap.set('n', '<Leader>fb', '<cmd>:Telescope buffers<CR>')
      vim.keymap.set('n', '<Leader>gs', '<cmd>:Telescope git_status<CR>')
    end,
  },
  { 'nvim-telescope/telescope-file-browser.nvim' },

  -- Code editing
  { 'sheerun/vim-polyglot' },
  { 'numtostr/Comment.nvim', event = 'VeryLazy' },
  {
    'neovim/nvim-lspconfig',
    ft = {
      'typescript',
      'go',
    },
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local lspconfig = require('lspconfig')
      local on_attach = function(client, bufnr)
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
        local bufopts = { noremap=true, silent=true, buffer=bufnr }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
        vim.keymap.set('n', '<C-s>', vim.lsp.buf.signature_help, bufopts)
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
        vim.keymap.set('n', '<space>wl', function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, bufopts)
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
        vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
        vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
        vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, bufops)
      end

      local lsp_defaults = {
          capabilities = capabilities,
          on_attach = on_attach,
      }

      lspconfig.util.default_config = vim.tbl_deep_extend(
          'force',
          lspconfig.util.default_config,
          lsp_defaults
      )

      lspconfig.tsserver.setup{}
      lspconfig.gopls.setup{}
    end,
  },
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup{
          snippet = {
            expand = function(args)
                require('luasnip').lsp_expand(args.body)
            end,
          },
          mapping = cmp.mapping.preset.insert({
              ['<C-b>'] = cmp.mapping.scroll_docs(-4),
              ['<C-f>'] = cmp.mapping.scroll_docs(4),
              ['<C-Space>'] = cmp.mapping.complete(),
              ['<C-e>'] = cmp.mapping.abort(),
              ['<CR>'] = cmp.mapping.confirm({ select = true }),
              ["<Tab>"] = cmp.mapping.select_next_item({behavior=cmp.SelectBehavior.Insert}),
              ["<S-Tab>"] = cmp.mapping.select_prev_item({behavior=cmp.SelectBehavior.Insert}),
          }),
          sources = cmp.config.sources{
              { name = 'nvim_lsp' },
          },
      }
    end,
  },
  { 
    'L3MON4D3/LuaSnip',
    dependencies = {
      'saadparwaiz1/cmp_luasnip',
    },
  },
  {
    'jose-elias-alvarez/null-ls.nvim',
    config = function()
      require('null-ls').setup{
        sources = {
          require('null-ls').builtins.diagnostics.eslint,
        }
      }
    end,
  },
})
