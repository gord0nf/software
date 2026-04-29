set nocompatible

" style
syntax enable
colorscheme habamax
set background=dark
set termguicolors
set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20
set signcolumn=yes
set colorcolumn=100

" plugin stuff, if ever added
filetype plugin on
filetype indent on

execute 'source ' . expand('<sfile>:p:h') . '/options.vim'
execute 'source ' . expand('<sfile>:p:h') . '/mappings.vim'
