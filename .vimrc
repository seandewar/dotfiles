""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  Sean Dewar's Vim/Neovim Configuration
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" ensure vi backwards compatibility support is off
set nocompatible

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  Plugin Configurations (using Plug)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" run :PlugInstall to install new plugins

if has('nvim')
  call plug#begin('~/.nvim/plugged')
else
  call plug#begin('~/.vim/plugged')
endif

" utilities
Plug 'mhinz/vim-startify' " start screen
Plug 'mtth/scratch.vim' " personal scratch buffer
Plug 'justinmk/vim-dirvish' " directory viewer that isn't as buggy as netrw
Plug 'tpope/vim-surround' " surround mappings
Plug 'tpope/vim-commentary' " commenting mappings
Plug 'easymotion/vim-easymotion' " easier motions using <leader><leader>
Plug 'ntpeters/vim-better-whitespace' " stray whitespace stripping and highlight
Plug 'sheerun/vim-polyglot' " language support package
Plug 'derekwyatt/vim-fswitch' " switch between companion files (.h, .c/.cc etc.)
Plug 'ludovicchabant/vim-gutentags' " tag file generation and management
Plug 'tpope/vim-fugitive' " git integration

" appearance
Plug 'morhetz/gruvbox'
Plug 'itchyny/lightline.vim'

call plug#end()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  Vim Behaviour
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" set character encoding
set encoding=utf8 fileencoding=utf8 termencoding=utf8

" disable unsafe commands in local .vimrc files
set secure

" don't unload modified buffers that are not displayed within a window
set hidden

" open splits on the bottom/right instead of top/left
set splitbelow splitright

" always show at least 5 lines above or below the cursor
set scrolloff=5

" enable mouse for all modes, don't hide cursor when typing, right-click
" displays context menu
set mouse=a nomousehide mousemodel=popup

" search options
set hlsearch incsearch ignorecase smartcase

" completion matches for commands (after pressing <tab> or ^D for a list &
" <tab><tab> for the wildmenu)
set wildmenu wildmode=list:longest,full

" search into subdirs - can be paired with :find *foo for fuzzy-like searching
set path+=**

" always display the status and tab lines
set laststatus=2 showtabline=2

" display open file name in terminal title bar
set title

" set tab sizes
set tabstop=2 softtabstop=2 shiftwidth=2 autoindent expandtab

" disable word wrapping and automatically wrap text inserted at 80 characters
set nowrap textwidth=80

" backspace settings
set backspace=indent,eol,start

" gvim GUI settings - turn off toolbar, GUI tabline and right & left scrollbars
set guioptions-=T guioptions-=r guioptions-=L guioptions-=e

" ensure file type, file plugin and file indent detection is on
filetype plugin indent on

" configure completion menu
set completeopt+=longest,menuone

" startify bookmarks
let g:startify_bookmarks = [ {'V': $MYVIMRC} ]

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  Vim Appearance
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" syntax highlighting
syntax on

" show hybrid relative line numbers on the side and status line
set number relativenumber ruler

" highlight the line and column (disabled) that the cursor is on
set cursorline "cursorcolumn

" configure 80 (and 120 if supported) column indicator
if exists('+colorcolumn')
  set colorcolumn=81,121
else
  au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
endif

" configure color scheme
set background=dark
let g:gruvbox_contrast_dark = 'hard'
colorscheme gruvbox

" configure lightline color scheme and hide its close button
let g:lightline = { 'colorscheme': 'gruvbox' }
let g:lightline.tabline = { 'left': [ [ 'tabs' ] ], 'right': [ [ '' ] ] }

" function to refresh lightline
function! g:LightlineRefresh()
  if !exists('g:loaded_lightline')
    return
  endif
  call lightline#init()
  call lightline#colorscheme()
  call lightline#update()
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  Vim Keymappings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" general rebinds
" make sure c-s flow ctrl is disabled for the terminal - press c-q to unfreeze
nmap <silent> <c-s> :w<cr>
nmap <leader>W :StripWhitespace<cr>

" configure startify session keybinds
nmap <silent> <leader>ss :SSave<cr>
nmap <silent> <leader>sl :SLoad<cr>
nmap <silent> <leader>sd :SDelete<cr>
nmap <silent> <leader>sc :SClose<cr>

" configure vim-fswitch keybinds
nmap <silent> <leader>oo :FSHere<cr>
nmap <silent> <leader>ol :FSRight<cr>
nmap <silent> <leader>oL :FSSplitRight<cr>
nmap <silent> <leader>oh :FSLeft<cr>
nmap <silent> <leader>oH :FSSplitLeft<cr>
nmap <silent> <leader>ok :FSAbove<cr>
nmap <silent> <leader>oK :FSSplitAbove<cr>
nmap <silent> <leader>oj :FSBelow<cr>
nmap <silent> <leader>oJ :FSSplitBelow<cr>

" allow toggling between rnu and nu mode
function! g:ToggleNumber()
  if &relativenumber
    set norelativenumber
  else
    set relativenumber
  endif
endfunction
nnoremap <silent> <leader>l :call g:ToggleNumber()<cr>

" clear last search highlights
nnoremap <leader>/ :set nohlsearch<cr>
