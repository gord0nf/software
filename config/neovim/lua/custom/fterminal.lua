local PERCENT_WIDTH = 0.9
local PERCENT_HEIGHT = 0.8

-- ===================
-- Floating terminal
-- ===================

local FTerminal = {
  buf = nil,
  win = nil,
  is_hidden = true,

  -- Any keymaps that need to be contained within the floating terminal window/buffer.
  -- Default defined at file end.
  keymaps = {
    ['t'] = {},
    ['n'] = {},
  },
}

function FTerminal.is_open()
  return not FTerminal.is_hidden and vim.api.nvim_win_is_valid(FTerminal.win)
end

local function buf_has_terminal()
  local has_terminal = false
  local lines = vim.api.nvim_buf_get_lines(FTerminal.buf, 0, -1, false)
  for _, line in ipairs(lines) do
    if line ~= '' then
      has_terminal = true
      break
    end
  end
  return has_terminal
end

local function set_buffer_keymaps()
  for mode, keymaps in pairs(FTerminal.keymaps) do
    for key, map in pairs(keymaps) do
      vim.keymap.set(mode, key, map.func, {
        noremap = true,
        silent = true,
        buffer = true,
        desc = map.desc,
      })
    end
  end
end

function FTerminal.open()
  -- Create buffer if it doesn't exist or is invalid
  if not FTerminal.buf or not vim.api.nvim_buf_is_valid(FTerminal.buf) then
    FTerminal.buf = vim.api.nvim_create_buf(false, true)
    -- Set buffer options for better terminal experience
    vim.bo[FTerminal.buf].bufhidden = 'hide'
  end

  -- Calculate window dimensions
  local width = math.floor(vim.o.columns * PERCENT_WIDTH)
  local height = math.floor(vim.o.lines * PERCENT_HEIGHT)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Create the floating window
  FTerminal.win = vim.api.nvim_open_win(FTerminal.buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
  })

  -- Set transparency for the floating window
  vim.wo[FTerminal.win].winblend = 0
  vim.wo[FTerminal.win].winhighlight = 'Normal:FloatingTermNormal,FloatBorder:FloatingTermBorder'

  -- Define highlight groups for transparency
  vim.api.nvim_set_hl(0, 'FloatingTermNormal', { bg = 'none' })
  vim.api.nvim_set_hl(0, 'FloatingTermBorder', { bg = 'none' })

  -- Start terminal if not already running
  if not buf_has_terminal() then
    vim.cmd('terminal')
  end
  FTerminal.is_hidden = false
  vim.cmd('startinsert')

  -- Setup keymaps in buffer
  set_buffer_keymaps()
end

function FTerminal.hide()
  vim.api.nvim_win_close(FTerminal.win, false)
  FTerminal.is_hidden = true
end

function FTerminal.toggle()
  if FTerminal.is_open() then
    FTerminal.hide()
    return
  end

  FTerminal.open()

  vim.api.nvim_create_autocmd('BufLeave', {
    buffer = FTerminal.buf,
    callback = function()
      if FTerminal.is_open() then
        FTerminal.hide()
      end
    end,
    once = true,
  })
end

function FTerminal.delete()
  vim.api.nvim_buf_delete(FTerminal.buf, { force = true })
  FTerminal.hide()
end

-- ===================
-- Default keymaps
-- ===================

FTerminal.keymaps = {
  ['t'] = {
    ['<C-w>'] = {
      func = FTerminal.hide,
      desc = 'Close floating terminal from terminal',
    },
  },
  ['n'] = {
    ['<C-w>'] = {
      func = FTerminal.hide,
      desc = 'Close floating terminal from terminal normal mode',
    },
    ['bd'] = {
      func = FTerminal.delete,
      desc = 'Force delete terminal buffer',
    },
  },
}

return FTerminal
