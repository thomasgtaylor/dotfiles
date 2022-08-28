local telescope = require('telescope')

telescope.setup({
  defaults = {
    file_ignore_patterns = {
      "node_modules"
    }
  }
})

vim.keymap.set('n', '<Leader>fs', '<cmd>:Telescope find_files<CR>')
vim.keymap.set('n', '<Leader>fg', '<cmd>:Telescope live_grep<CR>')
vim.keymap.set('n', '<Leader>fb', '<cmd>:Telescope buffers<CR>')
