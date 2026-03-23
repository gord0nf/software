let g:mapleader=" "

" Yank entire line
nmap Y y$

" Center screen when jumping
nmap n nzzzv
nmap N Nzzzv
nmap <C-d> <C-d>zz
nmap <C-u> <C-u>zz

" Splitting & Resizing
nmap <leader>sv :vsplit<CR>
nmap <leader>sh :split<CR>
nmap <C-Up> :resize +2<CR>
nmap <C-Down> :resize -2<CR>
nmap <C-Left> :vertical resize -2<CR>
nmap <C-Right> :vertical resize +2<CR>

" Better window navigation
nmap <C-h> <C-w>h
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-l> <C-w>l

" Move lines up/down (yay vscode)
nmap <A-j> :m .+1<CR>==
nmap <A-k> :m .-2<CR>==
vmap <A-j> :m '>+1<CR>gv=gv
vmap <A-k> :m '<-2<CR>gv=gv

" Better indenting in visual mode
vmap < <gv
vmap > >gv

" Delete words with ctrl backspace
imap <C-BS> <C-W>
noremap! <C-BS> <C-w>
noremap! <C-h> <C-w>

" ===================
" Tabs
" ===================

nmap <leader>bd :bdelete<CR>
nmap <leader>bD :bdelete!<CR>

" Buffer navigation
nmap <leader>bn :bnext<CR>
nmap <leader>bp :bprevious<CR>

" Tab navigation
nmap <leader>tn :tabnew<CR>
nmap <leader>tx :tabclose<CR>
nmap <leader>tm :tabmove<CR>
nmap <leader>t> :tabmove +1<CR>
nmap <leader>t< :tabmove -1<CR>

" ===================
" Terminal
" ===================

" Better window navigation from terminal
tmap <C-h> <c-\\><C-n><C-w>h
tmap <C-j> <c-\\><C-n><C-w>j
tmap <C-k> <c-\\><C-n><C-w>k
tmap <C-l>, <c-\\><C-n><C-w>l

" Insert mode in terminal buffer
tmap <Esc> <C-\\><C-n>
tmap <Esc><Esc> <Esc>
