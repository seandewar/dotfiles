""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sean Dewar's Vanilla (Neo)Vim Configuration <https://github.com/seandewar>   "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if !has('patch-8.2.2434') && !has('nvim-0.7')
    echohl WarningMsg
    echo 'init.vim may not work with this version of (Neo)Vim!'
    echohl None
end

" Set $MYVIMRC and $MYVIMRUNTIME for easy access, resolving symlinks {{{1
let $MYVIMRC = resolve($MYVIMRC)
let $MYVIMRUNTIME = resolve(exists('*stdpath') ? stdpath('config')
            \ : expand(has('win32') ? '~/vimfiles' : '~/.vim'))

" General Settings {{{1
set autoread
set backspace=indent,eol,start
set belloff=all
set breakindent
set cinoptions+=:0,g0,N-s
set display+=lastline,uhex
set encoding=utf-8
set foldmethod=marker
set formatoptions=croqnlj
set guioptions=M  " has to be before :syntax/filetype on, so not in gvimrc
set hidden
set incsearch ignorecase smartcase hlsearch
set nojoinspaces
set list listchars=tab:>\ ,trail:.,nbsp:~,extends:>,precedes:<
set mouse=a mousemodel=popup nomousehide
set nrformats-=octal
set path& | let &path .= '**'  " use :let.=, as 'path' already ends in a comma
set pumheight=12
set ruler
set scrolloff=1 sidescroll=5
set sessionoptions-=options viewoptions-=options
set shortmess+=IF shortmess-=S
set spelllang=en_gb spelloptions=camel
set splitbelow splitright
set switchbuf+=uselast
set tabstop=8 softtabstop=4 shiftwidth=4 autoindent expandtab smarttab
set textwidth=80
set title
set wildmenu wildmode=list:longest,full wildignorecase
set nowrap

" Lazy redrawing can cause glitchiness (e.g: my <C-W> mapping for Nvim's
" terminal not clearing "-- TERMINAL --" with showmode). As Nvim aims to make
" lazyredraw a no-op in the future after optimizing redraws, disable it for Nvim
if !has('nvim')
    set lazyredraw
endif

" Use Nvim 0.7+'s filetype.lua over filetype.vim
if has('nvim')
    let g:do_filetype_lua = 1
    let g:did_load_filetypes = 0  " disable filetype.vim
endif
filetype plugin indent on

syntax enable
nohlsearch  " setting hlsearch above re-enables old highlights; disable them

if exists('+inccommand')
    set inccommand=nosplit
endif

set completeopt=menu,menuone
if !has('nvim')
    set completeopt+=popup
endif

" prefer ripgrep over grep
if executable('rg')
    set grepprg=rg\ --vimgrep
endif

" 16-bit true colour is available if Win32 virtual console support is active.
" If we're using Nvim, turn it on anyway as tgc tends to "Just Work" (TM)
if has('nvim') || has('vcon')
    set termguicolors
endif

" Don't crowd working dirs with swap, persistent undo & other files; use the
" user runtime directory instead. Nvim already does this by default.
if !has('nvim')
    silent! call mkdir($MYVIMRUNTIME .. '/swap', 'p')
    silent! call mkdir($MYVIMRUNTIME .. '/undo', 'p')
    silent! call mkdir($MYVIMRUNTIME .. '/backup', 'p')

    set directory& directory^=$MYVIMRUNTIME/swap//
    set undodir& undodir^=$MYVIMRUNTIME/undo
    set backupdir=.,$MYVIMRUNTIME/backup
    set viminfofile=$MYVIMRUNTIME/viminfo
endif

function! s:UpdateColorColumn() abort
    let &colorcolumn = &modifiable ? '+1' : ''
endfunction

augroup conf_active_cursorcolumn
    autocmd!
    autocmd OptionSet modifiable call s:UpdateColorColumn()
    autocmd VimEnter,WinEnter,BufWinEnter * call s:UpdateColorColumn()
    autocmd WinLeave * set colorcolumn=
augroup END

augroup conf_auto_hlsearch
    autocmd!
    autocmd CmdlineEnter /,\? let s:save_hlsearch = &hlsearch | set hlsearch
    autocmd CmdlineLeave /,\? let &hlsearch = s:save_hlsearch
augroup END

augroup conf_auto_quickfix
    autocmd!
    autocmd VimEnter * ++nested cwindow
augroup END

" Distributed Plugin Settings {{{1
packadd cfilter

if has('nvim')
    let g:netrw_home = stdpath('data')  " store .netrwhist in the data directory
endif

let g:qf_disable_statusline = 1
let g:c_no_curly_error = 1  " don't show [{}] as an error; it's valid C++11
let g:markdown_folding = 1
let g:rustfmt_autosave = 1

" Status Line Settings {{{1
let g:conf_statusline_components = #{
            \ buf: '%(%w %)%(%f %)%([%M%R] %)%(%y %)',
            \ spell: '%([%{&spell ? &spelllang : ''''}] %)',
            \ position: '%=%-14(%l,%c%V%) %P',
            \ }
let g:conf_statusline_order =
            \ ['buf', 'spell', 'git', 'diagnostic', 'lsp', 'position']

function! ConfStatusLine() abort
    let parts = copy(g:conf_statusline_order)
                \ ->map({_, k -> get(g:conf_statusline_components, k, '')})
                \ ->map({_, v ->
                \ type(v) == v:t_func ? v(win_getid(), g:statusline_winid) : v})
    return join(parts, '')
endfunction

set laststatus=2
set statusline=%!ConfStatusLine()

augroup conf_statusline_highlights
    autocmd! ColorScheme * call conf#colors#def_statusline_hls()
augroup END

" Tab Line Settings {{{1
function! ConfTabLabel(tabnum) abort
    let buffers = tabpagebuflist(a:tabnum)
    let winnum = tabpagewinnr(a:tabnum)
    let bufname = expand('#' .. buffers[winnum - 1] .. ':t')

    " default to the working directory's tail component if empty
    if empty(bufname)
        let bufname = fnamemodify(getcwd(winnum, a:tabnum), ':t')
    endif

    return a:tabnum .. (empty(bufname) ? '' : ' ') .. bufname
endfunction

function! ConfTabLine() abort
    let line = ''
    let i = 1
    while i <= tabpagenr('$')
        let line .= tabpagenr() == i ? '%#TabLineSel# ' : '%#TabLine# '
        let line .= '%' .. i .. 'T'
        let line .= '%{ConfTabLabel(' .. i .. ')} '
        let i += 1
    endwhile

    let line .= '%#TabLineFill#'
    return line
endfunction

set showtabline=1 tabline=%!ConfTabLine()

" Commands {{{1
command! -bar ConfigDir call conf#tabedit_dir($MYVIMRUNTIME)
            \ | call timer_start(0, {-> search('^init.vim\>', 'c')})
command! -bar DataDir call conf#tabedit_dir(
            \ exists('*stdpath') ? stdpath('data') : $MYVIMRUNTIME)

" Mappings {{{1
" General Mappings {{{2
nnoremap <silent> <F2> <Cmd>setlocal spell!<CR>
inoremap <silent> <F2> <Cmd>setlocal spell!<CR>
nnoremap <silent> <C-L> <Cmd>nohlsearch<Bar>diffupdate<CR><C-L>
nnoremap <silent> <Leader>/ <Cmd>set hlsearch!<CR>

" disable suspend mapping for nvim on windows as there is no way to resume!
if has('nvim') && has('win32')
    nnoremap <silent> <C-Z> <NOP>
endif

" nvim 0.6 makes Y more sensible (y$), but I'm used to the default behaviour
if has('nvim')
    silent! unmap Y
endif

" NOTE: disable flow control for your terminal to use the <C-S> maps!
" press <C-Q> to unfreeze the terminal if you have accidentally activated it
nnoremap <silent> <C-S> <Cmd>update<CR>
inoremap <silent> <C-S> <Cmd>update<CR>

" Argument list {{{2
nnoremap <Leader>a <Cmd>args<CR>
nnoremap <silent> ]a <Cmd>next<CR>
nnoremap <silent> [a <Cmd>previous<CR>

" Buffers, Find, Grep, ... {{{2
nnoremap <Leader>fb :buffer<Space>
nnoremap <Leader>ff :find<Space>
nnoremap <Leader>fg :grep<Space>
nnoremap <Leader>ft :tjump<Space>
nnoremap <Leader>fo <Cmd>browse oldfiles<CR>

nnoremap <silent> ]b <Cmd>bnext<CR>2<C-G>
nnoremap <silent> [b <Cmd>bprevious<CR>2<C-G>

" QuickFix and Location lists {{{2
nnoremap <silent> <Leader>c <Cmd>cwindow<CR>
nnoremap <silent> <Leader>l <Cmd>lwindow<CR>

nnoremap <silent> <Leader>fc :Cfilter<Space>
nnoremap <silent> <Leader>fl :Lfilter<Space>

nnoremap <silent> ]c <Cmd>cnext<CR>zv
nnoremap <silent> [c <Cmd>cprevious<CR>zv
nnoremap <silent> ]C <Cmd>cnewer<CR>
nnoremap <silent> [C <Cmd>colder<CR>

nnoremap <silent> ]l <Cmd>lnext<CR>zv
nnoremap <silent> [l <Cmd>lprevious<CR>zv
nnoremap <silent> ]L <Cmd>lnewer<CR>
nnoremap <silent> [L <Cmd>lolder<CR>

" Neovim Terminal {{{2
if has('nvim')
    tnoremap <silent> <C-W> <C-\><C-N><C-W>
endif

" Source optional configurations before loading plugins {{{1
if filereadable(expand("$MYVIMRUNTIME/init_local.vim"))
    source $MYVIMRUNTIME/init_local.vim  " Machine-specific config; unversioned
end
if filereadable(expand("$MYVIMRUNTIME/plugin_conf.vim"))
    source $MYVIMRUNTIME/plugin_conf.vim
end

" Use my vanilla color scheme choice if one wasn't set {{{1
if !exists('g:colors_name')
    set background=dark
    silent! colorscheme ron
endif
