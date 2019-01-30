""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  Sean Dewar's Vim/Neovim Configuration
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" require vim (sorry, vi!)
set nocompatible

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  Plugin Configurations (using Plug)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" run :PlugInstall to install new plugins

call plug#begin('~/.vim/plugged')

" utilities
Plug 'scrooloose/nerdtree', " workspace tree view
Plug 'jistr/vim-nerdtree-tabs', " keep NERDTree layout the same between tabs
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } " fuzzy finder
Plug 'junegunn/fzf.vim' " fzf for vim
Plug 'tpope/vim-surround' " surround mappings
Plug 'tpope/vim-commentary' " commenting mappings
Plug 'easymotion/vim-easymotion' " easier motions using <leader><leader>
Plug 'ntpeters/vim-better-whitespace' " stray whitespace stripping and highlight
Plug 'sheerun/vim-polyglot' " language support package
Plug 'derekwyatt/vim-fswitch' " switch between companion files (.h, .c/.cc etc.)
Plug 'ajh17/VimCompletesMe' " simple completion using vim
Plug 'ludovicchabant/vim-gutentags' " tag file generation and management
Plug 'tpope/vim-fugitive' " git integration
Plug 'mhinz/vim-startify' " start screen
Plug 'mtth/scratch.vim' " personal scratch buffer

" appearance
Plug 'NLKNguyen/papercolor-theme'
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

" completion matches for commands (after pressing <tab> or ^D for a list &
" <tab><tab> for the wildmenu)
set wildmenu wildmode=list:longest,full

" open splits on the bottom/right instead of top/left
set splitbelow splitright

" always show at least 5 lines above or below the cursor
set scrolloff=5

" enable mouse for all modes, don't hide cursor when typing, right-click
" displays context menu
set mouse=a nomousehide mousemodel=popup

" search options
set hlsearch incsearch ignorecase smartcase

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

" enable true color support
if has('nvim') || has('termguicolors')
  set termguicolors
endif

" enable 256 color support in terminal
if !has('gui_running')
  set t_Co=256
endif

" configure color theme (PaperColor theme)
set background=dark
colorscheme PaperColor

" configure lightline (PaperColor theme)
let g:lightline = { 'colorscheme': 'PaperColor' }

" function to refresh lightline
function! g:LightlineRefresh()
  if !exists('g:loaded_lightline')
    return
  endif
  call lightline#init()
  call lightline#colorscheme()
  call lightline#update()
endfunction

" customize fzf.vim colors to match color theme
let g:fzf_colors = {
      \ 'fg':      ['fg', 'Normal'],
      \ 'bg':      ['bg', 'Normal'],
      \ 'hl':      ['fg', 'Comment'],
      \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
      \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
      \ 'hl+':     ['fg', 'Statement'],
      \ 'info':    ['fg', 'PreProc'],
      \ 'border':  ['fg', 'Ignore'],
      \ 'prompt':  ['fg', 'Conditional'],
      \ 'pointer': ['fg', 'Exception'],
      \ 'marker':  ['fg', 'Keyword'],
      \ 'spinner': ['fg', 'Label'],
      \ 'header':  ['fg', 'Comment']
      \ }

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  Vim Keymappings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" set NERDTreeTabs toggle
map <silent> <c-n> :NERDTreeTabsToggle<cr>

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

" configure fzf.vim fuzzy-finder keybinds
" git tracked files, all files
nmap <silent> <leader>ff :GFiles<cr>
nmap <silent> <leader>fF :Files<cr>
" open buffers, buffer history
nmap <silent> <leader>fb :Buffers<cr>
nmap <silent> <leader>fB :History<cr>
" tags in current buffer, all project tags
nmap <silent> <leader>ft :BTags<cr>
nmap <silent> <leader>fT :Tags<cr>
" lines in current buffer, lines in all buffers, marked lines
nmap <silent> <leader>fl :BLines<cr>
nmap <silent> <leader>fL :Lines<cr>
nmap <silent> <leader>f' :Marks<cr>
" commands, command history, search history, help docs
nmap <silent> <leader>fc :Commands<cr>
nmap <silent> <leader>f: :History:<cr>
nmap <silent> <leader>f/ :History/<cr>
nmap <silent> <leader>fh :Helptags<cr>

" allow toggling between rnu and nu mode
function! g:ToggleNumber()
  if &relativenumber
    set norelativenumber
  else
    set relativenumber
  endif
endfunction
nnoremap <silent> <leader>l :call g:ToggleNumber()<cr>

" toggle light and dark themes (PaperColor theme)
function! g:ToggleDarkTheme()
  if &background ==# 'light'
    set background=dark
    let g:lightline.colorscheme = 'PaperColor_dark'
  else
    set background=light
    let g:lightline.colorscheme = 'PaperColor_light'
  endif
  call LightlineRefresh()
endfunction
nnoremap <leader>d :call g:ToggleDarkTheme()<cr>

" clear last search highlights
nnoremap <leader>/ :set nohlsearch<cr>
