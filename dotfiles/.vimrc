
set history=500

filetype plugin on
filetype indent on

set autoread

let mapleader = ","
let g:mapleader = ","
nmap <leader>w :w!<cr>

command W w !sudo tee % > /dev/null

set wildmenu

set wildignore=*.o,*~,*.pyc,*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store

set ruler
set cmdheight=2

set hid

set backspace=eol,start,indent
set whichwrap+=<,>,h,l

set ignorecase
set smartcase
set hlsearch
set incsearch
set lazyredraw
set magic
set showmatch
set mat=2

set noerrorbells
set novisualbell
set t_vb=
set tm=500

if has("gui_macvim")
  autocmd GUIEnter * set vb t_vb=
endif

"set foldcolumn=1

syntax enable

if $COLORTERM == 'gnome-terminal'
  set t_Co=256
endif

try
  colorscheme desert
catch
endtry

set background=dark

if has("gui_running")
  set guioptions-=T
  set guioptions-=e
  set t_Co=256
  set guitablabel=%M\ %t
endif

set encoding=utf8

set ffs=unix,dos,mac

set nobackup
set nowb
set noswapfile

set expandtab
set smarttab
set shiftwidth=2
set tabstop=2

set lbr
set tw=500

set ai
set si
set wrap

map <M-b> :ALEGoToDefinition

set laststatus=2
set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l\ \ Column:\ %c

map <leader>ss :setlocal spell!<cr>

map <leader>sn ]s
map <leader>sp [s
map <leader>sa zg
map <leader>s? z=

map <leader>pp :setlocal paste!<cr>

function! HasPaste()
  if &paste
    return 'PASTE MODE  '
    endif
    return ''
endfunction

" make vim remember position in file after reopen
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" endif
endif

let g:flow#autoclose = 1
let g:flow#enable = 0
let g:javascript_plugin_flow = 1

let g:ale_lint_on_text_changed = 'always'
let g:ale_lint_on_insert_leave = 1
let g:ale_lint_on_enter = 1
let g:ale_lint_on_save = 1

let g:ale_linters = {'rust': ['rls']}

let g:ale_completion_enabled = 0

execute pathogen#infect()

set viminfo='100,<1000,s20,h

packloadall

silent! helptags ALL

set re=0

source ~/.vim/plugins/ale.vim

