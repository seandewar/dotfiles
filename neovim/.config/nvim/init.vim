if !has('patch-8.2.2434') && !has('nvim-0.8')
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
set showbreak=>
set cinoptions+=:0,g0,N-s,j1
set display+=lastline
set encoding=utf-8
set foldlevelstart=99 foldmethod=marker
set formatoptions=croqnlj
set guioptions=M  " Can't be in gvimrc; has to be before :syntax on/:filetype on
set hidden
set incsearch ignorecase smartcase hlsearch
set nojoinspaces
set list listchars=tab:_\ ,trail:.,nbsp:~,extends:>,precedes:<
set mouse=a mousemodel=popup nomousehide
set nrformats-=octal
set path& | let &path ..= '**'  " Use :let..=, as 'path' already ends in a comma
set pumheight=12
set scrolloff=1 sidescroll=5
set sessionoptions-=options viewoptions-=options
set shortmess+=IF shortmess-=S
set spelllang=en_gb spelloptions=camel
set splitbelow splitright
set switchbuf+=uselast
set tabstop=8 softtabstop=4 shiftwidth=4 autoindent expandtab smarttab
set textwidth=80
set title
set wildmenu wildmode=list:longest,full

" A Vim bug causes glob expansion to fail with 'wildignorecase' if a parent
" directory lacks read perms (neovim#6787). This messes up netrw on Termux.
if !has('termux')
    set wildignorecase
end

" Lazy redrawing can cause glitchiness (e.g: my <C-W> mapping for Nvim's
" terminal not clearing "-- TERMINAL --" with 'showmode'). As Nvim aims to make
" lazyredraw a no-op in the future after optimizing redraws, disable it for Nvim
if !has('nvim')
    set lazyredraw
endif

filetype plugin indent on
syntax enable
nohlsearch  " Setting 'hlsearch' above shows old highlights; disable them again

set completeopt=menu,menuone
if !has('nvim')
    set completeopt+=popup
endif

" Prefer ripgrep over grep
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

" Change &wrap depending on available screen size.
function! s:ReactiveResize() abort
    let &wrap = &columns < 100
endfunction

call s:ReactiveResize()
augroup conf_reactive_resize
    autocmd!
    autocmd VimResized * call s:ReactiveResize()
augroup END

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

" Neovim's terminal doesn't automatically tail to the output.
" Make sure the cursor is on the last line so it does.
if has('nvim')
    augroup conf_terminal_tailing
        autocmd!
        autocmd TermOpen * normal! G
        " NOTE: Do not use TermLeave! It requires a defer to move the cursor,
        " and even worse: it fires AFTER TermClose if the job exited; wtf?
        autocmd ModeChanged t:nt normal! G
    augroup END
endif

" Distributed Plugin Settings {{{1
packadd cfilter

let g:qf_disable_statusline = 1
let g:c_no_curly_error = 1  " Don't show [{}] as an error; it's valid C++11
let g:markdown_folding = 1
let g:rustfmt_autosave = 1

" Status Line Settings {{{1
function! ConfStlQfTitle() abort
    let title = get(w:, 'quickfix_title', '')
    return title !=# ':setqflist()' && title!=# ':setloclist()' ? title : ''
endfunction

let g:conf_statusline_components = #{
            \ main: '%(%w %)%(%f %)%(%{ConfStlQfTitle()} %)%([%M%R] %)%(%y %)',
            \ spell: '%([%{&spell ? &spelllang : ''''}] %)',
            \ ruler: '%=%(%l,%c%V | %P%)',
            \ }
let g:conf_statusline_order =
            \ ['main', 'spell', 'git', 'diagnostic', 'lsp', 'ruler']

function! ConfStatusLine() abort
    let parts = copy(g:conf_statusline_order)
                \ ->map({_, k -> get(g:conf_statusline_components, k, '')})
                \ ->map({_, v -> type(v) == v:t_func
                \                ? v(win_getid(), g:statusline_winid) : v})
    return join(parts, '')
endfunction

set statusline=%!ConfStatusLine() laststatus=2 ruler
let &rulerformat = g:conf_statusline_components.ruler

" Tab Line Settings {{{1
function! ConfTabLabel(tabnum) abort
    let buffers = tabpagebuflist(a:tabnum)
    let modified = 0
    for buf in buffers
        if getbufvar(buf, '&modified')
            let modified = 1
            break
        endif
    endfor
    let winnum = tabpagewinnr(a:tabnum)
    let bufname = expand('#' .. buffers[winnum - 1] .. ':t')

    " Default to the working directory's tail component if empty
    if empty(bufname)
        let bufname = fnamemodify(getcwd(winnum, a:tabnum), ':t')
    endif

    return a:tabnum .. (empty(bufname) ? '' : ' ') .. bufname
                \   .. (modified ? ' +' : '')
endfunction

function! ConfTabLine() abort
    let line = ''
    let i = 1
    while i <= tabpagenr('$')
        let line ..= tabpagenr() == i ? '%#TabLineSel# ' : '%#TabLine# '
        let line ..= '%' .. i .. 'T'
        let line ..= '%{ConfTabLabel(' .. i .. ')} '
        let i += 1
    endwhile

    let line ..= '%#TabLineFill#'
    return line
endfunction

set showtabline=1 tabline=%!ConfTabLine()

" Commands {{{1
function! s:TabEditDir(dir) abort
    execute 'Texplore' a:dir '| tcd' a:dir
endfunction

command! -bar ConfigDir call s:TabEditDir($MYVIMRUNTIME)
command! -bar DataDir call s:TabEditDir(
            \ exists('*stdpath') ? stdpath('data') : $MYVIMRUNTIME)

" Mappings {{{1
" General Mappings {{{2
nnoremap <silent> <F2> <Cmd>setlocal spell!<CR>
inoremap <silent> <F2> <Cmd>setlocal spell!<CR>
nnoremap <silent> <C-L> <Cmd>nohlsearch<Bar>diffupdate<CR><C-L>
nnoremap <silent> gV `[v`]
" K is overridden by LSP for Hover, but sometimes 'keywordprg' is useful.
nnoremap <silent> gK K

" Disable suspend mapping for Nvim on Windows as there's no way to resume!
if has('nvim') && has('win32')
    nnoremap <silent> <C-Z> <NOP>
endif

" Nvim 0.6 makes Y more sensible (y$), but I'm used to the default behaviour
if has('nvim')
    silent! unmap Y
endif

" Argument list {{{2
nnoremap <silent> ]a <Cmd>next<CR>
nnoremap <silent> [a <Cmd>previous<CR>

" Buffers, Find, Grep, ... {{{2
nnoremap <Leader>fb :buffer<Space>
nnoremap <Leader>ff :find<Space>
nnoremap <Leader>fg :grep<Space>
nnoremap <Leader>ft :tjump<Space>
nnoremap <Leader>fo <Cmd>browse oldfiles<CR>

" QuickFix and Location lists {{{2
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
