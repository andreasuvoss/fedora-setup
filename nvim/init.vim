:set number
:set autoindent
:set smarttab
:set mouse=a

syntax on

call plug#begin()

Plug 'https://github.com/vim-airline/vim-airline'
"Plug 'preservim/nerdtree'
"Plug 'akinsho/toggleterm.nvim'
"Plug 'neoclide/coc.nvim'
"Plug 'ryanoasis/vim-devicons'
"Plug 'rafi/awesome-vim-colorschemes'
"Plug 'tpope/vim-commentary'
Plug 'luochen1990/rainbow'
"Plug 'preservim/tagbar'
Plug 'Mofiqul/dracula.nvim'
"Plug 'mg979/vim-visual-multi'

call plug#end()

let g:rainbow_active = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show = 1

colorscheme dracula