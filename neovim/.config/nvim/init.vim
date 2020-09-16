""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sean Dewar's Vanilla (Neo)Vim Configuration <https://github.com/seandewar>   "
"                                                                              "
" This config is standalone and requires no plugins or external scripts.       "
" Useful for a quick, minimal install with some of my preferences available.   "
" An optional after/init.vim is sourced after this script for more features.   "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Determine where the user's runtime directory is {{{1
function! s:GetUserDir() abort
    if exists('*stdpath') " nvim 0.3+
        return stdpath('config')
    endif

    if has('nvim') " nvim < 0.3
        let basedir = $XDG_CONFIG_HOME

        if empty(basedir)
            let basedir = has('win32') ? $LOCALAPPDATA : '~/.config'
        endif

        return expand(basedir . '/nvim')
    endif

    return expand(has('win32') ? '~/vimfiles' : '~/.vim') " vim
endfunction

let $VIMUSERDIR = s:GetUserDir()

" General Settings {{{1
" don't crowd working dirs with swap, persistent undo & other files; use the
" user directory instead. nvim already does this by default.
if !has('nvim')
    silent! call mkdir($VIMUSERDIR . '/swap', 'p')
    silent! call mkdir($VIMUSERDIR . '/undo', 'p')
    silent! call mkdir($VIMUSERDIR . '/backup', 'p')

    set directory& undodir&
    let &directory = $VIMUSERDIR . '/swap//,' . &directory
    let &undodir = $VIMUSERDIR . '/undo,' . &undodir

    let &backupdir = '.,' . $VIMUSERDIR . '/backup'
    let &viminfofile = $VIMUSERDIR . '/viminfo'
endif

set autoread
set backspace=indent,eol,start
set belloff=all
set breakindent
set cinoptions+=:0,g0,N-s
set completeopt=menuone,preview
set display+=lastline
set encoding=utf-8
set foldmethod=marker
set formatoptions=croqnlj nrformats-=octal
set hidden
set nojoinspaces
set lazyredraw
set list listchars=tab:>\ ,trail:.,nbsp:~,extends:>,precedes:<
set nomodeline
set mouse=a nomousehide mousemodel=popup
set ruler
set scrolloff=1 sidescroll=5
set sessionoptions-=options viewoptions-=options
set shortmess+=IF shortmess-=S
set noshowcmd
set spelllang=en_gb
set splitbelow splitright
set tabstop=8 softtabstop=4 shiftwidth=4 autoindent expandtab smarttab
set textwidth=80
set title
set wildmenu wildmode=list:longest,full wildignorecase

" I don't use the GUI menu, so don't bother loading its defaults from menu.vim.
" NOTE: has to be set here (not the gvimrc) before :filetype and :syntax on.
set guioptions=M

filetype plugin indent on
syntax enable

set hlsearch incsearch ignorecase smartcase
nohlsearch " cancel the highlight from setting hlsearch when reloading the vimrc

if exists('+inccommand')
    set inccommand=nosplit
endif

" completion menu can use popups rather than preview window, if available
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

function! s:UpdateColorColumn() abort
    let &l:colorcolumn = &modifiable ? '+1' : '' " hide when nomodifiable
endfunction

augroup current_window_cursorline_and_colorcolumn
    autocmd!
    autocmd OptionSet modifiable call s:UpdateColorColumn()
    autocmd WinEnter,BufWinEnter * call s:UpdateColorColumn() | set cursorline
    autocmd WinLeave * setlocal colorcolumn= nocursorline
augroup END

augroup auto_open_quickfix_or_loclist
    autocmd!
    autocmd VimEnter * nested cwindow

    " NOTE: we cannot simply call :c/lwindow here!
    "
    " some commands, such as :(l)helpgrep, are not completely finished by the
    " time QuickfixCmdPost is triggered (for example, :lhelpgrep hasn't created
    " or entered the help window yet; it hasn't even assigned the populated
    " location list it uses to any window at that point).
    "
    " by calling timer_start() for 0ms, :c/lwindow is deferred until after Vim
    " is ready to receive user input, which will be after the command finishes.
    autocmd QuickfixCmdPost [^l]* nested
                \ call timer_start(0, {-> execute('cwindow')})
    autocmd QuickfixCmdPost l* nested
                \ call timer_start(0, {-> execute('lwindow', 'silent!')})
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
nnoremap <silent> <f2> :setlocal spell!<cr>
inoremap <silent> <f2> <c-\><c-o>:setlocal spell!<cr>
set pastetoggle=<f3> " also works while in paste mode

nnoremap <silent> <c-l> :nohlsearch<cr><c-l>

" NOTE: disable flow control for your terminal to use the <C-S> maps!
" press <C-Q> to unfreeze the terminal if you have accidently activated it
nnoremap <silent> <c-s> :write<cr>
inoremap <silent> <c-s> <c-\><c-o>:write<cr>

" Argument list {{{2
nnoremap <silent> ]a :next<cr>
nnoremap <silent> [a :previous<cr>

" Buffers {{{2
nnoremap <leader>b :buffers<cr>:
nnoremap <leader>B :buffers!<cr>:
nnoremap <silent> ]b :bnext<cr>2<c-g>
nnoremap <silent> [b :bprevious<cr>2<c-g>

" QuickFix {{{2
nnoremap <silent> ]c :cnext<cr>
nnoremap <silent> [c :cprevious<cr>
nnoremap <silent> ]C :cnewer<cr>
nnoremap <silent> [C :colder<cr>

" Location list {{{2
nnoremap <silent> ]l :lnext<cr>
nnoremap <silent> [l :lprevious<cr>

" Source optional after/init.vim script before plugins are loaded {{{1
runtime after/init.vim

" Use my vanilla color scheme choice if one wasn't set {{{1
if !exists('g:colors_name')
    set background=dark
    silent! colorscheme torte
endif