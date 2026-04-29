set cmdheight=1
set splitright
set showtabline=1
set tabline=

" Ruler and line numbers
set ruler
set number
set relativenumber

" Layout
set cursorline
set nowrap
set scrolloff=10
set sidescrolloff=8

" Indentation
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set smarttab
set smartindent
set autoindent

" Search
set ignorecase
set smartcase
set hlsearch
set incsearch

" File handling
set nobackup
set nowritebackup
set noswapfile
set undofile
set updatetime=300
set timeoutlen=500
set ttimeoutlen=0
set autoread
set noautowrite
set undodir=~/.vim/undodir
set ffs=unix,dos,mac

" Behavior settings
set hidden
set noerrorbells
set backspace=indent,eol,start
set noautochdir
set iskeyword+=-
set selection=exclusive
set mouse=a
set modifiable
set encoding=utf8
set clipboard=unnamedplus

" Command line completion
set wildmenu
set wildmode=longest:full,full

" Performance
set redrawtime=10000
set maxmempattern=20000
