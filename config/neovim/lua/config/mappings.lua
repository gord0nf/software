-- Yank entire line
vim.keymap.set('n', 'Y', 'y$', { desc = 'Yank to EOL' })

-- Center screen when jumping
vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Next search result (centered)' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Previous search result (centered)' })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Half page dnown (centered)' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Half page up (centered)' })

-- Splitting & Resizing
vim.keymap.set('n', '<leader>sv', ':vsplit<CR>', { desc = 'Split window vertically' })
vim.keymap.set('n', '<leader>sh', ':split<CR>', { desc = 'Split window horizontally' })
vim.keymap.set('n', '<C-Up>', ':resize +2<CR>', { desc = 'Increase window height' })
vim.keymap.set('n', '<C-Down>', ':resize -2<CR>', { desc = 'Decrease window height' })
vim.keymap.set('n', '<C-Left>', ':vertical resize -2<CR>', { desc = 'Decrease window width' })
vim.keymap.set('n', '<C-Right>', ':vertical resize +2<CR>', { desc = 'Increase window width' })

-- Better window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to bottom window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to top window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

-- Move lines up/down (yay vscode)
vim.keymap.set('n', '<A-j>', ':m .+1<CR>==', { desc = 'Move line down' })
vim.keymap.set('n', '<A-k>', ':m .-2<CR>==', { desc = 'Move line up' })
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- Better indenting in visual mode
vim.keymap.set('v', '<', '<gv', { desc = 'Indent left and reselect' })
vim.keymap.set('v', '>', '>gv', { desc = 'Indent right and reselect' })

-- Delete words with ctrl backspace
vim.cmd('imap <C-BS> <C-W>')
vim.cmd('noremap! <C-BS> <C-w>')
vim.cmd('noremap! <C-h> <C-w>')

-- Get and copy file path
vim.keymap.set('n', '<leader>pa', function()
  local path = vim.fn.expand('%:p')
  vim.fn.setreg('+', path)
  print('current:', path)
end)

-- Ctrl backspace to delete word in insert mode
-- vim.keymap.set("i", "<C->", "<Esc>dbi", { desc = "Delete word in Insert mode"})

-- ===================
-- Tabs
-- ===================

vim.keymap.set('n', '<leader>bd', ':bdelete<CR>', { desc = 'Smart close buffer/tab' })
vim.keymap.set('n', '<leader>bD', ':bdelete!<CR>', { desc = 'Delete buffer (force)' })

-- Buffer navigation
vim.keymap.set('n', '<leader>bn', ':bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<leader>bp', ':bprevious<CR>', { desc = 'Previous buffer' })

-- Tab navigation
vim.keymap.set('n', '<leader>tn', ':tabnew<CR>', { desc = 'New tab' })
vim.keymap.set('n', '<leader>tx', ':tabclose<CR>', { desc = 'Close tab' })
vim.keymap.set('n', '<leader>tm', ':tabmove<CR>', { desc = 'Move tab' })
vim.keymap.set('n', '<leader>t>', ':tabmove +1<CR>', { desc = 'Move tab right' })
vim.keymap.set('n', '<leader>t<', ':tabmove -1<CR>', { desc = 'Move tab left' })

-- Function to open file in new tab
local function open_file_in_tab()
  vim.ui.input({ prompt = 'File to open in new tab: ', completion = 'file' }, function(input)
    if input and input ~= '' then
      vim.cmd('tabnew ' .. input)
    end
  end)
end

-- Function to duplicate current tab
local function duplicate_tab()
  local current_file = vim.fn.expand('%:p')
  if current_file ~= '' then
    vim.cmd('tabnew ' .. current_file)
  else
    vim.cmd('tabnew')
  end
end

-- Function to close tabs to the right
local function close_tabs_right()
  local current_tab = vim.fn.tabpagenr()
  local last_tab = vim.fn.tabpagenr('$')

  for i = last_tab, current_tab + 1, -1 do
    vim.cmd(i .. 'tabclose')
  end
end

-- Function to close tabs to the left
local function close_tabs_left()
  local current_tab = vim.fn.tabpagenr()

  for _ = current_tab - 1, 1, -1 do
    vim.cmd('1tabclose')
  end
end

-- Enhanced keybindings
vim.keymap.set('n', '<leader>tO', open_file_in_tab, { desc = 'Open file in new tab' })
vim.keymap.set('n', '<leader>td', duplicate_tab, { desc = 'Duplicate current tab' })
vim.keymap.set('n', '<leader>tr', close_tabs_right, { desc = 'Close tabs to the right' })
vim.keymap.set('n', '<leader>tL', close_tabs_left, { desc = 'Close tabs to the left' })

-- ===================
-- Terminal
-- ===================

-- Better window navigation from terminal
vim.keymap.set('t', '<C-h>', '<c-\\><C-n><C-w>h', { desc = 'Move to left window from terminal' })
vim.keymap.set('t', '<C-j>', '<c-\\><C-n><C-w>j', { desc = 'Move to bottom window from terminal' })
vim.keymap.set('t', '<C-k>', '<c-\\><C-n><C-w>k', { desc = 'Move to top window from terminal' })
vim.keymap.set('t', '<C-l>', '<c-\\><C-n><C-w>l', { desc = 'Move to right window from terminal' })

-- Insert mode in terminal buffer
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Normal mode from terminal mode' })
vim.keymap.set('t', '<Esc><Esc>', '<Esc>', { noremap = true, silent = true, desc = 'Normal mode from terminal mode' })

-- Floating terminal
local FTermnial = require('custom.fterminal')
vim.keymap.set('n', '<leader>;', FTermnial.toggle, { noremap = true, silent = true, desc = 'Toggle floating terminal' })
