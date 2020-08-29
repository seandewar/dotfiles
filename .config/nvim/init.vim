""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  Sean Dewar's Vanilla (Neo)Vim Configuration <https://github.com/seandewar>  "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" General Settings {{{1
function! s:GetUserDir() abort
    if exists('*stdpath') " nvim 0.3+ feature
        return stdpath('config')
    endif

    let basedir = $XDG_CONFIG_HOME
    if empty(basedir)
        let basedir = has('win32') ? $LOCALAPPDATA : '~/.config'
    endif

    if has('nvim')
        return expand(basedir . '/nvim')
    endif

    return expand(has('win32') ? '~/vimfiles' : '~/.vim')
endfunction

let $VIMUSERDIR = s:GetUserDir()

" don't crowd working dirs with swap, persistent undo & other files; use the
" user dir instead. NOTE: this doesn't include backup files
if !has('nvim') " nvim does this all by default
    silent! call mkdir($VIMUSERDIR . '/swap', 'p')
    silent! call mkdir($VIMUSERDIR . '/undo', 'p')
    set directory& undodir&
    let &directory = $VIMUSERDIR . '/swap//,' . &directory
    let &undodir = $VIMUSERDIR . '/undo,' . &undodir
    let &viminfofile = $VIMUSERDIR . '/viminfo'
endif

filetype plugin indent on
if &t_Co > 1 | syntax enable | endif

set autoread
set backspace=indent,eol,start
set belloff=all
set breakindent
set cinoptions+=:0,g0,N-s
set completeopt=menuone,preview
set encoding=utf-8
set foldmethod=marker
set hidden
set hlsearch incsearch ignorecase smartcase
set nojoinspaces
set lazyredraw
set list listchars=tab:__,trail:.,nbsp:~,extends:>,precedes:<
set mouse=a nomousehide mousemodel=popup
set nrformats-=octal
set ruler
set scrolloff=1 sidescroll=5
set sessionoptions-=options
set shortmess+=I shortmess-=S
set spelllang=en_gb
set splitbelow splitright
set tabstop=8 softtabstop=4 shiftwidth=4 autoindent expandtab smarttab
set textwidth=80
set title
set wildmenu wildmode=list:longest,full wildignorecase

" vanilla colorscheme assuming dark terminal background
set background=dark
colorscheme torte

if exists('+inccommand')
    set inccommand=nosplit
endif

" completion menu can use popups rather than preview window if available
if has('patch-8.1.1880')
    set completeopt+=popup " overrides preview flag
    if has('patch-8.1.1882') | set completepopup=border:off | endif
endif

" prefer ripgrep over grep, if available
if executable('rg')
    set grepprg=rg\ --vimgrep
endif

" 16-bit true colour is available if Win32 virtual console support is active
if has('vcon')
    set termguicolors
endif

" show line numbers in netrw buffers
let g:netrw_bufsettings = 'number nomodifiable nomodified nobuflisted readonly'

" NOTE: easier than creating an ftplugin-specific script in .vim/after, but can
" fail if the ftplugin also creates its own autocmd...
augroup ft_setting_overrides
    autocmd!
    autocmd FileType * setlocal formatoptions=croqljn
    autocmd FileType c,cpp setlocal commentstring=//\ %s
augroup END

augroup auto_window_cursor_line
    autocmd!
    autocmd VimEnter,WinEnter * setlocal cursorline
    autocmd WinLeave * setlocal nocursorline
augroup END

function! s:ColorColumnUpdate() abort
    let &l:colorcolumn = &modifiable ? '+1' : '' " hide when nomodifiable
endfunction

augroup auto_window_color_column
    autocmd!
    autocmd OptionSet modifiable call s:ColorColumnUpdate()
    autocmd WinEnter,BufWinEnter * call s:ColorColumnUpdate()
    autocmd WinLeave * setlocal colorcolumn=
augroup END

" Status Line Settings {{{1
function! StatusLine() abort
    let line  = '%(%w %)'                                   " preview win flag
    let line .= '%f '                                       " relative file name
    let line .= '%([%M%R] %)'                               " modified, RO flag
    let line .= '%(%y %)'                                   " file type
    let line .= '%([%{&spell ? &spelllang : ''''}] %)'      " spell check
    let line .= get(g:, 'plugin_statusline', '')            " plugin stuff
    let line .= '%='                                        " align right
    let line .= '%-14(%l,%c%V%) '                           " cursor line & col
    let line .= '%P'                                        " scroll percentage
    return line
endfunction

set laststatus=2 statusline=%!StatusLine()

" Tab Line Settings {{{1
function! TabLabel(tabnum) abort
    let buffers = tabpagebuflist(a:tabnum)
    let winnum = tabpagewinnr(a:tabnum)
    let bufname = expand('#' . buffers[winnum - 1] . ':t')
    return a:tabnum . (empty(bufname) ? '' : ' ') . bufname
endfunction

function! TabLine() abort
    let line = ''

    for t in range(1, tabpagenr('$'))
        " active tab highlight
        let line .= tabpagenr() == t ? '%#TabLineSel# ' : '%#TabLine# '

        let line .= '%' . t . 'T'                  " tab number for mouse clicks
        let line .= '%{TabLabel(' . t . ')} '      " tab label
    endfor

    let line .= '%#TabLineFill#'                   " fill remaining tab line
    return line
endfunction

set showtabline=1 tabline=%!TabLine()

" Mappings {{{1
" NOTE: disable flow control for your terminal to use the ^S mapping to save.
" if you accidentally activate flow control, press ^Q to unfreeze the terminal
nnoremap <silent> <f2> :setlocal spell!<cr>
inoremap <silent> <f2> <c-\><c-o>:setlocal spell!<cr>
set pastetoggle=<f3> " also works while in paste mode
nnoremap <c-s> :write<cr>
inoremap <c-s> <c-\><c-o>:write<cr>
nnoremap <leader>/ :nohlsearch<cr>

" buffer {{{2
nnoremap <leader>b :buffers<cr>:
nnoremap <leader>B :buffers!<cr>:
nnoremap ]b :bnext<cr>
nnoremap [b :bprevious<cr>

" quickfix {{{2
nnoremap <leader>c :cwindow<cr>
nnoremap ]c :cnext<cr>
nnoremap [c :cprevious<cr>
nnoremap ]C :cnewer<cr>
nnoremap [C :colder<cr>

" loclist {{{2
nnoremap <leader>l :lwindow<cr>
nnoremap ]l :lnext<cr>
nnoremap [l :lprevious<cr>

" Extra Sources {{{1
" source other optional configuration files in the runtimepath
runtime init_plugins.vim " plugin-specific configurations
runtime init_local.vim   " system-specific configurations; not versioned
