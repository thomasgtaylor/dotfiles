require('packer').startup(function()
  use 'wbthomason/packer.nvim' -- Package manager
  use 'ellisonleao/gruvbox.nvim' -- Theme
  use 'lewis6991/gitsigns.nvim' -- VCS gutter
  use 'numtostr/BufOnly.nvim' -- Close all buffers except current
  use {
    'nvim-lualine/lualine.nvim', -- Status line
    requires = { 'kyazdani42/nvim-web-devicons' }
  }
  use {
    'akinsho/bufferline.nvim', -- Buffer line
    tag = 'v2.*',
    requires = { 'kyazdani42/nvim-web-devicons' }
  }
  use {
    'nvim-telescope/telescope.nvim', -- File search
    requires = { 'nvim-lua/plenary.nvim' }
  }
  use {
    'kyazdani42/nvim-tree.lua', -- File tree
    requires = { 'kyazdani42/nvim-web-devicons' }
  }
  use 'neovim/nvim-lspconfig' -- Language Server Protocol
  use 'hrsh7th/nvim-cmp' -- Completion engine
  use 'hrsh7th/cmp-nvim-lsp' -- Completion engine integration
  use 'L3MON4D3/LuaSnip' -- Snipping
  use 'saadparwaiz1/cmp_luasnip' -- Nvim-cmp snipping integration
  use 'jose-elias-alvarez/null-ls.nvim' -- Linting LSP integration
  use 'ejholmes/vim-forcedotcom' -- Apex Language Highlighting
end)

vim.opt.number = true
vim.opt.hidden = true
vim.opt.wrap = false
vim.opt.cursorline = true
vim.opt.clipboard:prepend {"unnamedplus"}
vim.opt.tabstop = 2
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.showtabline = 2
vim.opt.background = 'dark'
vim.opt.termguicolors = true
vim.opt.completeopt = {'menu', 'menuone', 'noselect'}
vim.cmd([[colorscheme gruvbox]])
vim.g.mapleader = ','

local function map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then 
        options = vim.tbl_extend('force', options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

local function nmap(lhs, rhs, opts)
    map('n', lhs, rhs, opts)
end

nmap('<Leader><Space>', ':nohls<CR>')
nmap('<Leader>ff', '<cmd>:NvimTreeToggle<CR>')
nmap('<Leader>fs', '<cmd>:Telescope find_files<CR>')
nmap('<Leader>fg', '<cmd>:Telescope live_grep<CR>')
nmap('<C-k>', ':wincmd k<CR>')
nmap('<C-j>', ':wincmd j<CR>')
nmap('<C-h>', ':wincmd h<CR>')
nmap('<C-l>', ':wincmd l<CR>')

require('gitsigns').setup()
require('bufferline').setup()
require('lualine').setup {
    options = { theme = 'gruvbox' }
}
require('nvim-tree').setup {
    renderer = {
        indent_markers = {
            enable = true,
            icons = {
                corner = "└ ",
                edge = "│ ",
                none = "  ",
            }
        }
    }
}

local cmp = require('cmp')
cmp.setup({
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
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
    })
})

require("null-ls").setup({
    sources = {
        require("null-ls").builtins.diagnostics.eslint,
        require("null-ls").builtins.completion.spell,
    },
})

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
local lspconfig = require('lspconfig')
lspconfig.apex_ls.setup {
    apex_jar_path = '/Users/thomastaylor/.local/share/nvim/lsp_servers/apex_ls/apex-jorje-lsp.jar',
    apex_jvm_max_heap = '8192m',
    filetypes = { 'st' },
    on_attach = on_attach,
    capabilities = capabilities
}
lspconfig.tsserver.setup{
    on_attach = on_attach,
    capabilities = capabilities
}

local on_attach = function(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)
end
