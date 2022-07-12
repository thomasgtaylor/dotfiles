local function get_config(name)
    return string.format('require("config/%s")', name)
end

local packer = require('packer')
packer.init({
    display = {
        open_fn = function()
            return require('packer.util').float({border = 'rounded'})
        end,
    }
})

packer.startup(function(use)
    use({ 
        'wbthomason/packer.nvim', -- Package manager 
    })
    use({
        'ellisonleao/gruvbox.nvim', -- Theme
        config = get_config('gruvbox'),
    })
    use({
        'lewis6991/gitsigns.nvim', -- VCS gutter
        config = get_config('gitsigns'),
    })
    use({
        'numtostr/BufOnly.nvim', -- Close all buffers except current
    }) 	
    use({
        'nvim-lualine/lualine.nvim', -- Status line
        requires = { 'kyazdani42/nvim-web-devicons' },
        config = get_config('lualine'),
    })
    use({
        'akinsho/bufferline.nvim', -- Buffer line
        tag = 'v2.*',
        requires = { 'kyazdani42/nvim-web-devicons' },
        config = get_config('bufferline'),
        after = 'gruvbox.nvim',
    })
    use({
        'nvim-telescope/telescope.nvim', -- File search
        requires = { 'nvim-lua/plenary.nvim' },
        config = get_config('telescope'),
    })
    use({
        'kevinhwang91/rnvimr', -- File search
        config = get_config('ranger'),
    })
    use({
        'neovim/nvim-lspconfig', -- Language Server Protocol
        config = get_config('lspconfig'),
    })
    use({
        'hrsh7th/nvim-cmp', -- Completion engine
        config = get_config('cmp'),
    })
    use({
        'hrsh7th/cmp-nvim-lsp', -- Completion engine integration
    })	
    use({
        'L3MON4D3/LuaSnip', -- Snipping
    })
    use({
        'saadparwaiz1/cmp_luasnip', -- Nvim-cmp snipping integration 
    })
    use({
        'jose-elias-alvarez/null-ls.nvim', -- Linting LSP integration
        config = get_config('null-ls'), 
    })
end)

