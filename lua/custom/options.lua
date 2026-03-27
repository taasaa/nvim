-- Tab settings
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true

-- Search settings
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Clipboard: use custom OSC 52 provider with BEL terminator for tmux compat.
-- See custom/osc52-bel.lua for the full backstory.
vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('custom.osc52-bel').copy('+'),
    ['*'] = require('custom.osc52-bel').copy('*'),
  },
  paste = {
    ['+'] = require('custom.osc52-bel').paste('+'),
    ['*'] = require('custom.osc52-bel').paste('*'),
  },
}
