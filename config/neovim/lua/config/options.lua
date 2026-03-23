-- Set map leader on init
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.cmdheight = 1
vim.opt.splitright = true
vim.opt.showtabline = 1
vim.opt.tabline = ''

-- Ruler and line numbers
vim.opt.ruler = true
vim.opt.number = true
vim.opt.relativenumber = true

-- Layout
vim.opt.cursorline = true
vim.opt.wrap = false
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 8

-- Indentation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- File handling
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.updatetime = 300
vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 0
vim.opt.autoread = true
vim.opt.autowrite = false
local undodir = vim.fn.expand('~/.vim/undodir')
vim.opt.undodir = undodir
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, 'p')
end

-- Behavior settings
vim.opt.hidden = true
vim.opt.errorbells = false
vim.opt.backspace = 'indent,eol,start'
vim.opt.autochdir = false
vim.opt.iskeyword:append('-')
vim.opt.selection = 'exclusive'
vim.opt.mouse = 'a'
vim.opt.modifiable = true
vim.opt.encoding = 'UTF-8'
vim.opt.clipboard = 'unnamedplus'

-- Command line completion
vim.opt.wildmenu = true
vim.opt.wildmode = 'longest:full,full'
vim.opt.wildignore:append({ '*.o', '*.obj', '*.pyc', '*.class', '*.jar' })

-- Performance
vim.opt.redrawtime = 10000
vim.opt.maxmempattern = 20000

-- Inline errors
vim.diagnostic.config({ virtual_text = true })

-- Shells, don'tcha know?
local shell = os.getenv('SHELL')
if not shell or shell == '' then
  local is_windows = function()
    return package.config:sub(1, 1) == '\\'
  end
  shell = is_windows() and 'powershell.exe' or 'bash'
end
vim.opt.shell = shell
