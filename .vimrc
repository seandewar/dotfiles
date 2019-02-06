""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  Sean Dewar's Vim/Neovim Configuration
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  Plugin Configurations (using Plug)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" run :PlugInstall to install new plugins

if has('nvim')
  if has('win32')
    call plug#begin('~/AppData/Local/nvim/plugged')
  else
    call plug#begin('~/.config/nvim/plugged')
  endif
else
  if has('win32')
    call plug#begin('~/vimfiles/plugged')
  else
    call plug#begin('~/.vim/plugged')
  endif
endif

" utilities
Plug 'mhinz/vim-startify' " start screen
Plug 'mtth/scratch.vim' " personal scratch buffer
Plug 'tpope/vim-vinegar' " enhancements for the netrw directory viewer
Plug 'tpope/vim-surround' " surround mappings
Plug 'tpope/vim-commentary' " commenting mappings
Plug 'easymotion/vim-easymotion' " easier motions using <leader><leader>
Plug 'ntpeters/vim-better-whitespace' " stray whitespace stripping and highlight
Plug 'sheerun/vim-polyglot' " language support package
Plug 'derekwyatt/vim-fswitch' " switch between companion files (.h, .c/.cc etc.)
Plug 'lifepillar/vim-mucomplete' " <tab> completion using vim's <c-x> modes
Plug 'ludovicchabant/vim-gutentags' " tag file generation and management
Plug 'tpope/vim-dispatch' " async jobs using :Dispatch
Plug 'tpope/vim-fugitive' " git integration
Plug 'w0rp/ale' " vim8/nvim async linting engine

" appearance
Plug 'morhetz/gruvbox' " colorscheme
Plug 'itchyny/lightline.vim' " lightweight airline-like status bar
Plug 'maximbaz/lightline-ale' " shows ale error/warning count on the lightline

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

" always show at least 1 line above or below the cursor
set scrolloff=1

" enable mouse for all modes, don't hide cursor when typing, right-click
" displays context menu
set mouse=a nomousehide mousemodel=popup

" search options
set hlsearch incsearch ignorecase smartcase

" completion matches for commands (after pressing <tab> or ^D for a list &
" <tab><tab> for the wildmenu)
set wildmenu wildmode=list:longest,full wildignorecase

" always display the status and tab lines
set laststatus=2 showtabline=2

" disable bell noises
set belloff=all

" display open file name in terminal title bar
set title

" set tab sizes
set tabstop=2 softtabstop=2 shiftwidth=2 autoindent expandtab

" automatically wrap text inserted at 80 characters
set textwidth=79

" backspace settings
set backspace=indent,eol,start

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

" only show the tabline if at least two tabs are open
set showtabline=1

" show the ruler and make sure we show hybrid relative line numbers on the side
" of all buffers (including non-file buffers)
set ruler
augroup AutoBufferNumber
  autocmd!
  autocmd BufWinEnter * set number relativenumber
augroup END

" highlight the line that the cursor is on
set cursorline

" configure 80 and 120 column indicator only in insert mode
augroup ColorColumnInsertMode
  autocmd!
  autocmd InsertEnter * setlocal colorcolumn=81,121
  autocmd InsertLeave * setlocal colorcolumn=
augroup END

" configure color scheme
set background=dark
let g:gruvbox_contrast_dark = 'hard'
colorscheme gruvbox

" ale gutter error/warning symbols and message config
let g:ale_sign_error = 'E>'
let g:ale_sign_warning = 'W>'
let g:ale_echo_msg_error_str = 'error'
let g:ale_echo_msg_warning_str = 'warning'
let g:ale_echo_msg_info_str = 'info'
let g:ale_echo_msg_format = '[%severity%] %s [%linter%]'

" lightline-ale symbols
let g:lightline#ale#indicator_errors = 'E:'
let g:lightline#ale#indicator_warnings = 'W:'
let g:lightline#ale#indicator_checking = 'Linting...'
let g:lightline#ale#indicator_ok = 'Lint OK'

" configure lightline
let g:lightline = {
      \ 'colorscheme': 'gruvbox',
      \ 'component_expand': {
      \   'linter_checking': 'lightline#ale#checking',
      \   'linter_errors': 'lightline#ale#errors',
      \   'linter_warnings': 'lightline#ale#warnings',
      \   'linter_ok': 'lightline#ale#ok'
      \ },
      \ 'component_type': {
      \   'linter_checking': 'left',
      \   'linter_errors': 'error',
      \   'linter_warnings': 'warning',
      \   'linter_ok': 'left'
      \ },
      \ 'component_function': { 'gitbranch': 'fugitive#head' },
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ],
      \   'right': [ [ 'linter_checking', 'linter_warnings',
      \                'linter_errors', 'linter_ok' ],
      \              [ 'lineinfo' ],
      \              [ 'percent' ],
      \              [ 'fileformat', 'fileencoding', 'filetype' ] ]
      \ },
		  \ 'inactive': {
      \   'left': [ [ 'readonly', 'filename', 'modified' ] ],
      \   'right': [ [ 'lineinfo' ],
      \              [ 'percent' ],
      \              [ 'fileformat', 'fileencoding', 'filetype' ] ]
      \ },
      \ 'tabline': { 'left': [ [ 'tabs' ] ], 'right': [ [ '' ] ] }
      \ }

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
nnoremap <c-s> :w<cr>
nnoremap <leader>w :StripWhitespace<cr>
nnoremap <leader>/ :set nohlsearch<cr>
nnoremap <leader><esc> :Startify<cr>

" allow toggling between rnu and nu mode
function! g:ToggleNumber()
  if &relativenumber
    set norelativenumber
  else
    set relativenumber
  endif
endfunction
nnoremap <silent> <leader>l :call g:ToggleNumber()<cr>

" netrw (dir explorer) keybinds
nnoremap <leader>dd :Explore<cr>
nnoremap <leader>ds :Sexplore<cr>
nnoremap <leader>dv :Vexplore<cr>

" buffer keybinds
nnoremap <leader>bb :buffers<cr>:buffer<space>
nnoremap <leader>bs :buffers<cr>:sbuffer<space>
nnoremap <leader>bv :buffers<cr>:vertical sbuffer<space>
nnoremap <leader>bd :buffers<cr>:bdelete<space>
nnoremap <leader>bn :bnext<cr>
nnoremap <leader>bN :bprevious<cr>

" loclist window keybinds
nnoremap <leader>ll :lopen<cr>
nnoremap <leader>ln :lnext<cr>
nnoremap <leader>lN :lprevious<cr>

" quickfix window keybinds
nnoremap <leader>qq :copen<cr>
nnoremap <leader>qn :cnext<cr>
nnoremap <leader>qN :cprevious<cr>

" configure startify session keybinds
nnoremap <leader>ss :SSave<cr>
nnoremap <leader>sl :SLoad<cr>
nnoremap <leader>sd :SDelete<cr>
nnoremap <leader>sc :SClose<cr>

" configure vim-fswitch keybinds
nnoremap <leader>oo :FSHere<cr>
nnoremap <leader>oh :FSLeft<cr>
nnoremap <leader>ol :FSRight<cr>
nnoremap <leader>ok :FSAbove<cr>
nnoremap <leader>oj :FSBelow<cr>
nnoremap <leader>oH :FSSplitLeft<cr>
nnoremap <leader>oL :FSSplitRight<cr>
nnoremap <leader>oK :FSSplitAbove<cr>
nnoremap <leader>oJ :FSSplitBelow<cr>

" configure vim-fugitive keybinds
nnoremap <leader>gg :Gstatus<cr>
nnoremap <leader>gs :Gstatus<cr>
nnoremap <silent> <leader>gl :Glog<cr>:copen<cr>
nnoremap <silent> <leader>gL :0Glog<cr>:copen<cr>
nnoremap <leader>ge :Gedit<cr>
nnoremap <leader>gd :Gdiff<cr>
nnoremap <leader>gb :Gblame<cr>
nnoremap <leader>gc :Gcommit<cr>
nnoremap <leader>gC :Gcommit -a<cr>
nnoremap <leader>gw :Gwrite<cr>
nnoremap <leader>gr :Gread<cr>
nnoremap <leader>gps :Gpush<cr>
nnoremap <leader>gpl :Gpull<cr>

" configure ale hotkeys
nnoremap <leader>aa :ALEToggle<cr>
nnoremap <leader>al :ALELint<cr>
nnoremap <leader>at :ALEToggle<cr>
nnoremap <leader>af :ALEFix<cr>
nnoremap <leader>ad :ALEGoToDefinition<cr>
nnoremap <leader>ar :ALEFindReferences<cr>
nnoremap <leader>ah :ALEHover<cr>
nnoremap <leader>as :ALESymbolSearch<space>
