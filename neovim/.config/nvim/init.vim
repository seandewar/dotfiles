if !has('nvim-0.10') && !has('patch-8.2.2434') 
    echohl ErrorMsg
    echo '[init.vim] Unsupported Vim/Nvim version. Disabling!'
    echohl None
    finish
end

" Enable Nvim's experimental Lua loader, which byte-compiles and caches Lua
" files. Easiest to keep this near the top, in case some Lua files are ever
" implicitly loaded from our actions below.
if has('nvim')
    lua vim.loader.enable()
end

" Set $MYVIMRC and $MYVIMRUNTIME for easy access, resolving symlinks {{{1
let $MYVIMRC = resolve($MYVIMRC)
let $MYVIMRUNTIME = resolve(exists('*stdpath') ? stdpath('config')
                  \ : expand(has('win32') ? '~/vimfiles' : '~/.vim'))

" General Settings {{{1
set showbreak=>
set cinoptions+=:0,g0,N-s,j1
set completeopt=menu,menuone
set foldlevelstart=99 foldmethod=marker
set formatoptions=croqnlj
set guioptions=M  " Has to be before ":filetype/syntax on", so not in the gvimrc
set ignorecase smartcase
set list listchars=tab:_\ ,trail:.,nbsp:~,extends:>,precedes:<
set mouse=a
set path& | let &path ..= '**'  " Use :let..=, as 'path' already ends in a comma
set pumheight=12
set scrolloff=1 sidescroll=5
set shortmess+=I
set spelllang=en_gb spelloptions=camel
set splitbelow splitright
set softtabstop=4 shiftwidth=4 expandtab
set textwidth=80
set notimeout
set title
set wildmode=list:longest,full

if has('nvim')
    " Nvim's exrc feature uses a :trust system, so it's safe enough to enable.
    set exrc

    " Nvim's terminal doesn't automatically tail to the output.
    " Make sure the cursor is on the last line so it does.
    augroup conf_terminal_tailing
        autocmd!
        autocmd TermOpen * call cursor('$', 1)
        " NOTE: Do not use TermLeave! It requires a defer to move the cursor,
        " and even worse, it fires AFTER TermClose if the job exited... wtf?
        autocmd ModeChanged t:nt call cursor('$', 1)
    augroup END

    " Nvim conveniently supports highlighting the yanked selection.
    augroup conf_highlight_yanked
        autocmd!
        autocmd TextYankPost * lua vim.highlight.on_yank()
    augroup END
else
    " Nvim already sets these values by default.
    set autoindent smarttab
    set autoread
    set backspace=indent,eol,start
    set belloff=all
    set display+=lastline
    set encoding=utf-8
    set hidden
    set incsearch hlsearch | nohlsearch
    set nojoinspaces
    set mousemodel=popup_setpos
    set nrformats-=octal
    set sessionoptions-=options viewoptions-=options
    set shortmess+=F shortmess-=S
    set switchbuf+=uselast
    set ttimeout ttimeoutlen=50
    set wildmenu

    " Vim supports using popup windows for completion previews.
    set completeopt+=popup

    " Lazy redrawing can leave stale stuff on the screen (e.g: my Nvim terminal
    " <C-W> mapping not clearing "-- TERMINAL --" with 'showmode'). As Nvim aims
    " to make it a no-op after optimizing redraws, don't enable it for Nvim.
    set lazyredraw

    " Don't crowd working dirs with swap, persistent undo & other files; use the
    " user runtime directory instead. Nvim does this by default.
    silent! call mkdir($MYVIMRUNTIME .. '/swap', 'p')
    silent! call mkdir($MYVIMRUNTIME .. '/undo', 'p')
    silent! call mkdir($MYVIMRUNTIME .. '/backup', 'p')

    set directory& directory^=$MYVIMRUNTIME/swap//
    set undodir& undodir^=$MYVIMRUNTIME/undo
    set backupdir=.,$MYVIMRUNTIME/backup
    set viminfofile=$MYVIMRUNTIME/viminfo

    " Nvim enables filetype detection and syntax highlighting by default.
    filetype plugin indent on
    syntax enable
endif

" 16-bit true colour is available if Win32 virtual console support is active.
" If we're using Nvim, turn it on anyway as 'tgc' tends to "Just Work" (TM).
if has('nvim') || has('vcon')
    set termguicolors
endif

" Prefer ripgrep over grep
if executable('rg')
    set grepprg=rg\ --vimgrep
endif

" A Vim bug causes glob expansion to fail with 'wildignorecase' if a parent
" directory lacks read perms (neovim#6787). This messes up netrw on Termux.
if !has('termux')
    set wildignorecase
end

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

let g:qf_disable_statusline = 1
let g:c_no_curly_error = 1  " Don't show "[{}]" as an error; it's valid C++11
let g:markdown_folding = 1
let g:rustfmt_autosave = 1

if has('nvim')
    let g:netrw_nogx = 1  " Nvim 0.10 has its own gx which uses vim.ui.open().
endif

" With 'hidden' set, netrw buffers may have no name. This is because netrw does
" not modify the empty buffer created by Vim when opening a directory, but
" instead opens a new listing buffer and tries to set its name to that of the
" empty buffer, which fails when 'hidden' is set:
" https://github.com/neovim/neovim/issues/17841#issuecomment-1504079552.
function s:FixNetrwBufName() abort
    let dir_bufnr = bufnr('^' .. b:netrw_curdir .. '$')
    " Not found for some reason or already has the correct name.
    if dir_bufnr == -1 || dir_bufnr == bufnr() | return | endif
    execute 'bwipeout' dir_bufnr '| file' b:netrw_curdir
endfunction

augroup conf_netrw_bufname_fix
    autocmd!
    autocmd FileType netrw call s:FixNetrwBufName()
augroup END

" Status Line Settings {{{1
function! ConfStlBufName(tp_bufnum = '') abort
    if a:tp_bufnum == ''
        let name = expand('%:p:~:.')
    else
        let name = pathshorten(expand('#' .. a:tp_bufnum .. ':p:~'))
    endif
    if !empty(name) | return name | endif

    let buftype = getbufvar(a:tp_bufnum, '&buftype')
    if buftype ==# 'prompt' | return '[Prompt]' | endif
    return buftype =~# '^\%(nofile\|acwrite\|terminal\)$' ? '[Scratch]'
                \                                         : '[No Name]'
endfunction

function! ConfStlQfTitle() abort
    let title = get(w:, 'quickfix_title', '')
    return title !=# ':setqflist()' && title !=# ':setloclist()' ? title : ''
endfunction

let g:conf_statusline_components = #{
            \ main: '%(%w %)%(%q %)%(%{ConfStlBufName()} %)' ..
            \       '%(%{ConfStlQfTitle()} %)' ..
            \       '%([%M%R%{&binary ? '',BIN'' : ''''}' ..
            \       '%{!empty(&filetype) ? '','' .. &filetype : ''''}' ..
            \       '%{&spell ? '','' .. &spelllang : ''''}] %)',
            \ ruler: '%=%(%l,%c%V | %P%)',
            \ }
let g:conf_statusline_order =
            \ ['main', 'git', 'diagnostic', 'lsp', 'ruler']

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
    return a:tabnum .. ' ' .. ConfStlBufName(buffers[winnum - 1])
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
command! -bar RuntimeDir call s:TabEditDir($VIMRUNTIME)

" Mappings {{{1
" General Mappings {{{2
nnoremap <Leader>s <Cmd>setlocal spell!<CR>
nnoremap <C-L> <Cmd>nohlsearch<Bar>diffupdate<CR><C-L>
nnoremap gV `[v`]

" Just in case K is overridden for LSP Hover; 'keywordprg' is sometimes useful.
nnoremap gK K

if has('nvim')
    tnoremap <C-W> <C-\><C-N><C-W>

    " Nvim 0.6 makes Y sensible (y$), but I'm used to the default behaviour.
    silent! unmap Y

    " Disable suspend mapping for Nvim on Windows as there's no way to resume!
    if has('win32')
        nnoremap <C-Z> <NOP>
    endif
endif

" Argument list {{{2
nnoremap ]a <Cmd>next<Bar>args<CR>
nnoremap [a <Cmd>previous<Bar>args<CR>

" Buffers {{{2
nnoremap ]b <Cmd>bnext<CR>2<C-G>
nnoremap [b <Cmd>bprevious<CR>2<C-G>
nnoremap <Leader>fb :buffer<Space>

" Find, Grep, ... {{{2
nnoremap <Leader>ff :find<Space>
nnoremap <Leader>fg :grep<Space>
nnoremap <Leader>ft :tjump<Space>
nnoremap <Leader>fo <Cmd>browse oldfiles<CR>

" QuickFix and Location lists {{{2
nnoremap ]c <Cmd>cnext<CR>zv
nnoremap [c <Cmd>cprevious<CR>zv
nnoremap ]C <Cmd>cnewer<CR>
nnoremap [C <Cmd>colder<CR>

nnoremap ]l <Cmd>lnext<CR>zv
nnoremap [l <Cmd>lprevious<CR>zv
nnoremap ]L <Cmd>lnewer<CR>
nnoremap [L <Cmd>lolder<CR>
