if !has('nvim-0.11') && !has('patch-8.2.2434')
    echohl ErrorMsg
    echo '[init.vim] Unsupported Vim/Nvim version. Disabling!'
    echohl None
    finish
end

" Enable Nvim's experimental Lua loader {{{1
" It byte-compiles and caches Lua files. Best to keep this near the top.
if has('nvim')
    lua vim.loader.enable()
end

" Set $MYVIMRC and $MYVIMDIR for easy access, resolving symlinks {{{1
let $MYVIMRC = resolve($MYVIMRC)
let $MYVIMDIR = resolve(exists('*stdpath') ? stdpath('config')
              \ : expand(has('win32') ? '~/vimfiles' : '~/.vim'))

" General settings {{{1
set cinoptions+=:0,g0,N-s,j1
set completeopt+=menuone
set diffopt+=algorithm:histogram
set foldlevelstart=99 foldmethod=indent
set formatoptions=croqnlj
set ignorecase smartcase
set list listchars=tab:▸\ ,trail:·,nbsp:␣,extends:⟩,precedes:⟨
set mouse=a
set path& | let &path ..= '**'  " Use :let..=, as 'path' already ends in a comma
set pumheight=12
set scrolloff=1 sidescroll=5
set sessionoptions-=blank sessionoptions-=buffers
set shortmess+=I
set showbreak=↳
set spelllang=en_gb spelloptions=camel
set splitbelow splitright
set softtabstop=4 shiftwidth=4 expandtab
set textwidth=80
set notimeout
set title
set wildmode=list:longest,full

if has('nvim')
    set completeopt-=popup  " Doesn't size very well, can't customize yet.
    set exrc  " Nvim's exrc uses a :trust system, so it's safe enough to enable.
    set foldtext=  " Nvim supports "transparent" foldtext that shows highlights.
    set jumpoptions+=view
    set winborder=single

    " Nvim's terminal doesn't automatically tail to the output.
    " Make sure the cursor is on the last line so it does.
    augroup conf_terminal_tailing
        autocmd!
        autocmd TermOpen * call cursor('$', 1)
        " NOTE: Do not use TermLeave! It requires a defer to move the cursor,
        " and even worse, it fires AFTER TermClose if the job exited... wtf?
        autocmd ModeChanged t:nt call cursor('$', 1)
    augroup END

    augroup conf_highlight_yanked
        autocmd!
        autocmd TextYankPost * lua vim.hl.on_yank()
    augroup END
else
    " Nvim already sets these values by default.
    set autoindent smarttab
    set autoread
    set backspace=indent,eol,start
    set belloff=all
    set completeopt+=popup
    set display+=lastline
    set encoding=utf-8
    set guioptions=M  " Has to be before ":filetype/syntax on"; not in gvimrc
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

    " Don't crowd working dirs with swap, persistent undo & other files; use the
    " user runtime directory instead. Nvim does this by default.
    silent! call mkdir($MYVIMDIR .. '/swap', 'p')
    silent! call mkdir($MYVIMDIR .. '/undo', 'p')
    silent! call mkdir($MYVIMDIR .. '/backup', 'p')

    set directory& directory^=$MYVIMDIR/swap//
    set undodir& undodir^=$MYVIMDIR/undo
    set backupdir=.,$MYVIMDIR/backup
    set viminfofile=$MYVIMDIR/viminfo

    " Prefer ripgrep; ignore binary files by default, but do not exclude
    " gitignored or hidden files if possible. Nvim does this by default.
    if executable('rg')
        set grepprg=rg\ --vimgrep\ -uu grepformat=%f:%l:%c:%m
    elseif has('win32')
        set grepprg=findstr\ /n\ $*\ nul
    else
        set grepprg=grep\ -HIn\ $*\ /dev/null
    endif

    " Nvim enables filetype detection and syntax highlighting by default.
    filetype plugin indent on
    syntax enable

    " Bundled since v9.0.1228 and v9.1.0375 respectively.
    let g:hlyank_duration = 150  " Matches the Nvim default.
    packadd! hlyank
    packadd! comment
endif

" Restoring a session with fold information could spam E490 in older versions.
if !has('patch-9.1.1317') && !has('nvim-0.12')
    set sessionoptions-=folds
endif

" Granular diff highlights for changed characters on a line. Support is new.
if has('patch-9.1.1243') || has('nvim-0.12')
    set diffopt+=inline:char
endif

" Support for fuzzy-matching completion candidates is rather new.
if has('patch-9.1.0463') || has('nvim')
    set completeopt+=fuzzy
endif

" 'smoothscroll' is pretty new in Vim (v9.0.0640), so check if it exists rather
" than bump the minimum patch requirement.
if exists('+smoothscroll')
    set smoothscroll
endif

" 16-bit true colour is available in Vim if Win32 virtual console support is
" active. Nvim is able to detect support automatically.
if has('vcon')
    set termguicolors
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

" Distributed plugin settings {{{1
packadd! cfilter

let g:qf_disable_statusline = 1
let g:c_no_curly_error = 1  " Don't show "[{}]" as an error; it's valid C++11
let g:markdown_folding = 1

if has('nvim')
    let g:clipboard = 'osc52'
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

" Status line settings {{{1
function! ConfStlBufName(tp_bufnum = '') abort
    if a:tp_bufnum == ''
        let name = expand('%:p:~:.')
    else
        let name = pathshorten(expand('#' .. a:tp_bufnum .. ':p:~'))
    endif
    if !empty(name) | return name | endif

    if getbufinfo(bufnr())[0]->get('command') | return '[Command Line]' | endif
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
            \ (has('nvim') ? '%{get(b:, ''ts_highlight'') ? '',TS'' : ''''}' :
            \                '') ..
            \       '%{&spell ? '','' .. &spelllang : ''''}] %)',
            \ ruler: '%=%(%l,%c%V %P%)',
            \ }
let g:conf_statusline_order =
            \ ['main', 'git', 'lsp', 'diagnostic', 'ruler']

function! ConfStatusLine() abort
    let parts = copy(g:conf_statusline_order)
                \ ->map({_, k -> get(g:conf_statusline_components, k, '')})
                \ ->map({_, v -> type(v) == v:t_func
                \                ? v(win_getid(), g:statusline_winid) : v})
    return join(parts, '')
endfunction

set statusline=%!ConfStatusLine() laststatus=2 ruler
let &rulerformat = g:conf_statusline_components.ruler

" Tab line settings {{{1
function! ConfTabLabel(tabnum) abort
    let buffers = tabpagebuflist(a:tabnum)
    let modified = copy(buffers)
                \  ->map({_, b -> getbufvar(b, '&modified')})
                \  ->index(1) != -1
    let prefix = printf(' %d%s%s ', a:tabnum,
                \ tabpagenr('#') == a:tabnum ? '#' : '', modified ? '+' : '')

    let maxcols = (&columns / tabpagenr('$')) - len(prefix)
    if tabpagenr() == a:tabnum
        let maxcols += &columns % tabpagenr('$')
    endif
    if maxcols <= 0 | return '' | endif

    let label = ConfStlBufName(buffers[tabpagewinnr(a:tabnum) - 1]) .. ' '
    return ' ' .. prefix .. label[-maxcols:]
endfunction

function! ConfTabLine() abort
    let line = ''
    let i = 1
    while i <= tabpagenr('$')
        let line ..= tabpagenr() == i ? '%#TabLineSel#' : '%#TabLine#'
        let line ..= '%' .. i .. 'T'
        let line ..= '%{ConfTabLabel(' .. i .. ')}'
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

command! -bar ConfigDir call s:TabEditDir($MYVIMDIR)
command! -bar DataDir call s:TabEditDir(
            \ exists('*stdpath') ? stdpath('data') : $MYVIMDIR)
command! -bar RuntimeDir call s:TabEditDir($VIMRUNTIME)

" Mappings {{{1
" General Mappings {{{2
nnoremap <Leader>s <Cmd>setlocal spell!<CR>
nnoremap gV `[v`]

if !has('nvim')  " Nvim defines this exactly by default.
    nnoremap <C-L> <Cmd>nohlsearch<Bar>diffupdate<Bar>normal!<C-L><CR>
endif

" Swap the behaviour of k, j, <Up>, <Down> to use display lines when wrapped.
nnoremap k gk
nnoremap j gj
nnoremap gk k
nnoremap gj j

nnoremap <Up> g<Up>
nnoremap <Down> g<Down>
nnoremap g<Up> <Up>
nnoremap g<Down> <Down>

inoremap <expr> <Up> pumvisible() ? '<Up>' : '<C-O>g<Up>'
inoremap <expr> <Down> pumvisible() ? '<Down>' : '<C-O>g<Down>'
" Useful for mobile.
inoremap <expr> <ScrollWheelUp> pumvisible() ? '<C-P>' : '<ScrollWheelUp>'
inoremap <expr> <ScrollWheelDown> pumvisible() ? '<C-N>' : '<ScrollWheelDown>'

" Swap the behaviour of visual p and P as to not mess with the " register.
xnoremap p P
xnoremap P p

" Just in case K is overridden; 'keywordprg' is sometimes useful.
nnoremap gK K

if has('nvim')
    " Cancels the pending wincmd if <Esc> is given, and does not leave Terminal
    " mode if so. This of course doesn't handle wincmds with a length of more
    " than one key that are cancelled later, but this is good enough.
    function! s:TermWincmd() abort
        let keys = "\<C-\>\<C-N>\<C-W>"
        while 1
            let c = getcharstr()
            if c == "\<Esc>" | return '' | endif
            let keys ..= c
            if c < '0' || c > '9' | break | endif
        endwhile
        return keys
    endfunction

    tnoremap <expr> <C-W> <SID>TermWincmd()

    " Nvim 0.6 makes Y sensible (y$), but I'm used to the default behaviour.
    silent! unmap Y

    " Disable suspend mapping for Nvim on Windows as there's no way to resume!
    if has('win32')
        nnoremap <C-Z> <NOP>
    endif

    " vim-scriptease-inspired mapping for :Inspect
    nnoremap zS <Cmd>Inspect<CR>
endif

" Argument list {{{2
nnoremap <expr> [a '<Cmd>' .. v:count1 .. 'previous<Bar>args<CR>'
nnoremap <expr> ]a '<Cmd>' .. v:count1 .. 'next<Bar>args<CR>'
nnoremap <expr> [A '<Cmd>' .. (v:count != 0 ? v:count .. 'argument' : 'first')
            \ .. '<Bar>args<CR>'
nnoremap <expr> ]A '<Cmd>' .. (v:count != 0 ? v:count .. 'argument' : 'last')
            \ .. '<Bar>args<CR>'

" Buffers {{{2
nnoremap <expr> [b '<Cmd>' .. v:count1 .. 'bprevious<CR>2<C-G>'
nnoremap <expr> ]b '<Cmd>' .. v:count1 .. 'bnext<CR>2<C-G>'
nnoremap <expr> [B '<Cmd>' .. (v:count != 0 ? v:count .. 'buffer' : 'bfirst')
            \ .. '<CR>2<C-G>'
nnoremap <expr> ]B '<Cmd>' .. (v:count != 0 ? v:count .. 'buffer' : 'blast')
            \ .. '<CR>2<C-G>'
nnoremap <Leader>fb :buffer<Space>

" Find, Grep, ... {{{2
nnoremap <Leader>ff :find<Space>
nnoremap <Leader>fg :grep<Space>
nnoremap <Leader>fG :grep <C-R>=shellescape('\b'..expand('<cword>')..'\b',1)<CR><CR>
nnoremap <Leader>ft :tjump<Space>
nnoremap <Leader>fo <Cmd>browse oldfiles<CR>

" QuickFix and Location lists {{{2
if !has('nvim')  " Nvim defines this exactly by default.
    nnoremap <expr> [q '<Cmd>' .. v:count1 .. 'cprevious<CR>'
    nnoremap <expr> ]q '<Cmd>' .. v:count1 .. 'cnext<CR>'
    nnoremap <expr> [Q '<Cmd>' .. (v:count != 0 ? v:count : '') .. 'cfirst<CR>'
    nnoremap <expr> ]Q '<Cmd>' .. (v:count != 0 ? v:count : '') .. 'clast<CR>'
    nnoremap <expr> [<C-Q> '<Cmd>' .. v:count1 .. 'cpfile<CR>'
    nnoremap <expr> ]<C-Q> '<Cmd>' .. v:count1 .. 'cnfile<CR>'

    nnoremap <expr> [l '<Cmd>' .. v:count1 .. 'lprevious<CR>'
    nnoremap <expr> ]l '<Cmd>' .. v:count1 .. 'lnext<CR>'
    nnoremap <expr> [L '<Cmd>' .. (v:count != 0 ? v:count : '') .. 'lfirst<CR>'
    nnoremap <expr> ]L '<Cmd>' .. (v:count != 0 ? v:count : '') .. 'llast<CR>'
    nnoremap <expr> [<C-L> '<Cmd>' .. v:count1 .. 'lpfile<CR>'
    nnoremap <expr> ]<C-L> '<Cmd>' .. v:count1 .. 'lnfile<CR>'
endif

" }}}1

" vim: fdm=marker fdl=0
