if !has('patch-8.2.2434') && !has('nvim-0.10')
    echohl WarningMsg
    echo 'init.vim may not work with this version of (Neo)Vim!'
    echohl None
end

" Enable the experimental Lua loader, which byte-compiles and caches Lua files.
lua vim.loader.enable()

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
set completeopt=menu,menuone
set display+=lastline
set encoding=utf-8
set foldlevelstart=99 foldmethod=marker
set formatoptions=croqnlj
set guioptions=M  " Has to be before :filetype/syntax on, so not in the gvimrc
set hidden
set incsearch ignorecase smartcase hlsearch | nohlsearch
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
set textwidth=80 wrap
set notimeout
set title
set wildmenu wildmode=list:longest,full

" Prefer ripgrep over grep
if executable('rg')
    set grepprg=rg\ --vimgrep
endif

" A Vim bug causes glob expansion to fail with 'wildignorecase' if a parent
" directory lacks read perms (neovim#6787). This messes up netrw on Termux.
if !has('termux')
    set wildignorecase
end

" 16-bit true colour is available if Win32 virtual console support is active.
" If we're using Nvim, turn it on anyway as tgc tends to "Just Work" (TM)
if has('nvim') || has('vcon')
    set termguicolors
endif

if !has('nvim')
    " Vim supports using popup windows for completion previews.
    set completeopt+=popup

    " Lazy redrawing can leave stale stuff on the screen (e.g: my Nvim terminal
    " <C-W> mapping not clearing "-- TERMINAL --" with 'showmode'). As Nvim aims
    " to make it a no-op after optimizing redraws, don't enable it for Nvim.
    set lazyredraw

    " Don't crowd working dirs with swap, persistent undo & other files; use the
    " user runtime directory instead. Nvim already does this by default.
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
        " and even worse, it fires AFTER TermClose if the job exited... wtf?
        autocmd ModeChanged t:nt normal! G
    augroup END
endif

" Distributed Plugin Settings {{{1
packadd cfilter

let g:qf_disable_statusline = 1
let g:c_no_curly_error = 1  " Don't show [{}] as an error; it's valid C++11
let g:markdown_folding = 1
let g:rustfmt_autosave = 1

" With 'hidden' set, netrw buffers may have no name. This is because netrw does
" not modify the empty buffer created by Vim when opening a directory, but
" instead opens a new listing buffer and tries to set its name to that of the
" empty buffer, which fails when 'hidden' is set:
" https://github.com/neovim/neovim/issues/17841#issuecomment-1504079552.
function s:FixNetrwBufName() abort
    let dir_bufnr = bufnr('^' .. b:netrw_curdir .. '$')
    if dir_bufnr == bufnr() | return | endif  " Already has the correct name.
    execute 'bwipeout' dir_bufnr '| file' b:netrw_curdir
endfunction

augroup conf_netrw_bufname_fix
    autocmd!
    autocmd FileType netrw call s:FixNetrwBufName()
augroup END

" Status Line Settings {{{1
function! ConfStlQfTitle() abort
    let title = get(w:, 'quickfix_title', '')
    return title !=# ':setqflist()' && title!=# ':setloclist()' ? title : ''
endfunction

let g:conf_statusline_components = #{
            \ main: '%(%w %)%(%q %)%(%{expand(''%:~:.'')} %)' ..
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
    let bufname = pathshorten(expand('#' .. buffers[winnum - 1] .. ':p:~'))
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
command! -bar RuntimeDir call s:TabEditDir($VIMRUNTIME)

" Mappings {{{1
" General Mappings {{{2
nnoremap <silent> <F2> <Cmd>setlocal spell!<CR>
inoremap <silent> <F2> <Cmd>setlocal spell!<CR>
nnoremap <silent> <C-L> <Cmd>nohlsearch<Bar>diffupdate<CR><C-L>
nnoremap <silent> gV `[v`]

" I override K for LSP Hover, but sometimes 'keywordprg' is useful.
nnoremap <silent> gK K

if has('nvim')
    tnoremap <silent> <C-W> <C-\><C-N><C-W>

    " Nvim 0.6 makes Y more sensible (y$), but I'm used to the default behaviour
    silent! unmap Y

    " Disable suspend mapping for Nvim on Windows as there's no way to resume!
    if has('win32')
        nnoremap <silent> <C-Z> <NOP>
    endif
endif

" Argument list {{{2
nnoremap <silent> ]a <Cmd>next<Bar>args<CR>
nnoremap <silent> [a <Cmd>previous<Bar>args<CR>

" Buffers {{{2
nnoremap <silent> ]b <Cmd>bnext<CR>2<C-G>
nnoremap <silent> [b <Cmd>bprevious<CR>2<C-G>
nnoremap <Leader>fb :buffer<Space>

" Find, Grep, ... {{{2
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
