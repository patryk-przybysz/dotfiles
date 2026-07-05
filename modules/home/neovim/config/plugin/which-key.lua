require('which-key').setup {
  delay = 0,
  icons = {
    mappings = vim.g.have_nerd_font,
    keys = vim.g.have_nerd_font and {} or nil,
  },
  spec = {
    { '<leader>s', group = '[S]earch' },
    { '<leader>t', group = '[T]oggle' },
  },
}
