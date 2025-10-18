" Version check {{{1
if !has('nvim-0.12')
    echohl WarningMsg
    echomsg '[init.vim] Unsupported Nvim version, expect issues!'
    echohl None
end

" Enable Nvim's experimental Lua loader and UI {{{1
" The loader byte-compiles and caches Lua files; best to keep it near the top.
lua vim.loader.enable() require("vim._extui").enable({})

" General settings {{{1
set cinoptions+=:0,g0,N-s,j1,l1
set completeopt+=menuone,fuzzy completefuzzycollect+=keyword,files,whole_line
set diffopt+=algorithm:histogram,inline:char
set exrc  " Nvim's exrc uses a :trust system, so it's safe enough to enable.
set fillchars+=trunc:…,truncrl:…
set foldlevelstart=99 foldmethod=indent foldtext=
set formatoptions=croqnlj
set ignorecase smartcase
set jumpoptions+=view
set list listchars=tab:▸\ ,trail:·,nbsp:␣,extends:⟩,precedes:⟨
set mouse=a
set notimeout
set pumheight=12
set ruler rulerformat=%!v:lua.require'conf.statusline'.rulerformat()
set scrolloff=1 sidescroll=5
set sessionoptions-=blank sessionoptions-=buffers
set shortmess+=I
set showbreak=↳
set smoothscroll
set softtabstop=4 shiftwidth=4 expandtab
set spelllang=en_gb spelloptions=camel
set splitbelow splitright
set statusline=%!v:lua.require'conf.statusline'.statusline() laststatus=2
set tabline=%!v:lua.require'conf.statusline'.tabline() showtabline=1
set textwidth=80
set title
set wildmode=list:longest,full
set winborder=single

function! s:SetPumMaxWidth() abort
    let &pummaxwidth = max([float2nr(&columns * 0.4), &pumwidth])
endfunction

augroup conf_auto_pummaxwidth
    autocmd!
    autocmd VimResized * call s:SetPumMaxWidth()
augroup END
call s:SetPumMaxWidth()

" A Vim bug causes glob expansion to fail with 'wildignorecase' if a parent
" directory lacks read perms (neovim#6787). This messes up netrw on Termux.
if !has('termux')
    set wildignorecase
end

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

function! s:UpdateColorColumn() abort
    let &l:colorcolumn = &modifiable ? '+1' : ''
endfunction

augroup conf_active_colorcolumn
    autocmd!
    autocmd OptionSet modifiable if win_getid() == get(s:, 'cc_win')
                              \| call s:UpdateColorColumn()
                              \| endif
    autocmd WinEnter,BufEnter * call s:UpdateColorColumn()
                             \| let s:cc_win = win_getid()
    autocmd WinLeave,BufLeave * setlocal colorcolumn=
                             \| unlet! s:cc_win
augroup END

augroup conf_auto_quickfix
    autocmd!
    autocmd VimEnter * ++nested cwindow
augroup END

" Distributed plugin settings {{{1
packadd! cfilter

let g:clipboard = 'osc52'
let g:c_no_curly_error = 1  " {}s inside []s are not always invalid.
let g:markdown_folding = 1
let g:qf_disable_statusline = 1

" With 'hidden' set, netrw buffers may have no name. This is because netrw does
" not modify the empty buffer created by Vim when opening a directory, but
" instead opens a new listing buffer and tries to set its name to that of the
" empty buffer, which fails when 'hidden' is set:
" https://github.com/neovim/neovim/issues/17841#issuecomment-1504079552.
function s:FixNetrwBufName() abort
    let dir_bufnr = bufnr($'^{b:netrw_curdir}$')
    " Not found for some reason or already has the correct name.
    if dir_bufnr == -1 || dir_bufnr == bufnr() | return | endif
    execute 'bwipeout' dir_bufnr '| file' b:netrw_curdir
endfunction

augroup conf_netrw_bufname_fix
    autocmd!
    autocmd FileType netrw call s:FixNetrwBufName()
augroup END

" Commands {{{1
function! s:TabEditDir(dir) abort
    execute 'Texplore' a:dir '| tcd' a:dir
endfunction

command! -bar ConfigDir call s:TabEditDir(stdpath('config'))
command! -bar DataDir call s:TabEditDir(stdpath('data'))
command! -bar StateDir call s:TabEditDir(stdpath('state'))
command! -bar RuntimeDir call s:TabEditDir($VIMRUNTIME)

" Mappings {{{1
" General Mappings {{{2
function! s:FormatBuffer() abort
    let view = winsaveview()
    keepjumps normal! gggqG
    call winrestview(view)
endfunction

nnoremap <Leader>F <Cmd>call <SID>FormatBuffer()<CR>
nnoremap <Leader>s <Cmd>setlocal spell!<CR>
nnoremap gV `[v`]

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

" Cancels the pending wincmd if <Esc> is given, and does not leave Terminal
" mode if so. Of course doesn't handle wincmds with a length of more than one
" key that are cancelled later, but this is good enough. Not an <expr> mapping
" to avoid expr_map_lock restrictions for events during getcharstr.
function! s:TermWincmd() abort
    let keys = "\<C-\>\<C-N>\<C-W>"
    while 1
        let c = getcharstr()
        if c == "\<Esc>" | return '' | endif
        let keys ..= c
        if c < '0' || c > '9' | break | endif
    endwhile
    call feedkeys(keys, 'tn')
endfunction

tnoremap <C-W> <Cmd>call <SID>TermWincmd()<CR>

" Nvim 0.6 makes Y sensible (y$), but I'm used to the default behaviour.
silent! unmap Y

" Disable suspend mapping for Nvim on Windows as there's no way to resume!
if has('win32')
    nnoremap <C-Z> <NOP>
endif

" vim-scriptease-inspired mapping for :Inspect
nnoremap zS <Cmd>Inspect<CR>

" Load 3rd-party packages {{{1
" Sourced here to ensure it's loaded before the scripts in the plugin directory.
" (.vim plugin files have priority over .lua; this side-steps that)
let s:pack_script = expand('<script>:h') .. '/pack.lua'

" May not exist if init.vim is used standalone. (Useful when I want to quickly
" use the settings here without pulling in the rest of my config)
if filereadable(s:pack_script)
    execute 'source' s:pack_script
endif
unlet s:pack_script
" }}}1

" vim: fdm=marker fdl=0
