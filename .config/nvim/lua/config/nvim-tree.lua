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

vim.keymap.set('n', '<Leader>ff', '<cmd>:NvimTreeToggle<CR>')
