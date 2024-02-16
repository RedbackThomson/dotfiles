call plug#begin()
" The default plugin directory will be as follows:
"   - Vim (Linux/macOS): '~/.vim/plugged'
"   - Vim (Windows): '~/vimfiles/plugged'
"   - Neovim (Linux/macOS/Windows): stdpath('data') . '/plugged'
" You can specify a custom plugin directory by passing it as the argument
"   - e.g. `call plug#begin('~/.vim/plugged')`
"   - Avoid using standard Vim directory names like 'plugin'

Plug 'junegunn/vim-easy-align'

Plug 'catppuccin/vim'
Plug 'itchyny/lightline.vim'
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-endwise'
Plug 'preservim/nerdtree'
Plug 'terryma/vim-smooth-scroll'
Plug 'wfxr/minimap.vim'

call plug#end()

syntax on

colorscheme catppuccin_frappe
hi Normal guibg=NONE ctermbg=NONE " Remove background color

set clipboard=unnamed
set nu
set tabstop=4
set softtabstop=4
set shiftwidth=4
set hlsearch
set expandtab
set autoindent
set mouse=a
set termguicolors

" Configure lightline
set laststatus=2
set noshowmode
let g:lightline = {
  \ 'colorscheme': 'catppuccin_frappe',
  \ }

" Configure NERDTree
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>

imap <C-BS> <C-W>
