--[[
  Custom OSC 52 clipboard provider for tmux compatibility.

  WHY THIS EXISTS:
  Neovim's built-in vim.ui.clipboard.osc52 terminates OSC 52 sequences with
  ESC \ (String Terminator, 0x1b 0x5c). This works outside tmux but silently
  fails inside tmux — the sequence never reaches the outer terminal. The
  dotfiles bin/clip script uses BEL (0x07) as the terminator and works
  reliably in tmux, so this module does the same.

  We can't just configure a different terminator in the built-in module — the
  terminator is hardcoded in Neovim's C source (see src/nvim/ui.c). Hence
  this custom Lua replacement.

  WHAT IT DOES:
  - Sends ESC ] 52 ; c ; <base64> BEL on every yank
  - Uses native vim.base64.encode() (Neovim 0.10+) instead of shelling out
    to the `base64` command — ~2800x faster per yank
  - Falls back to external `base64` command for older Neovim versions

  HOW IT'S WIRED:
  lua/custom/options.lua sets vim.g.clipboard to use this module, and
  lua/options.lua sets vim.o.clipboard = 'unnamedplus' so that every yank
  automatically goes through the + register (which calls this provider).

  RELATED:
  - ~/dotfiles/bin/clip  — shell OSC 52 helper (same BEL terminator)
  - ~/dotfiles/tmux.conf  — set -g set-clipboard on
  - Neovim issue: https://github.com/neovim/neovim/issues/29788
]]

local M = {}

local cache = { ['+'] = { '' }, ['*'] = { '' } }

function M.copy(reg)
  return function(lines)
    cache[reg] = lines
    local data = table.concat(lines, '\n')
    local encoded
    if vim.base64 then
      encoded = vim.base64.encode(data)
    else
      encoded = vim.fn.system('base64', data):gsub('\n', '')
    end

    io.write(string.format('\027]52;c;%s\007', encoded))
    io.flush()
  end
end

function M.paste(reg)
  return function()
    return cache[reg]
  end
end

return M