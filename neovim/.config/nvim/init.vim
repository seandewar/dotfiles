""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sean Dewar's (Neo)Vim Configuration <https://github.com/seandewar>           "
" Aims for compatibility with Vim 8.0+ and Neovim 0.3+ (plugins may differ)    "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Set $MYVIMRC and $MYVIMRUNTIME for easy access, resolving symlinks {{{1
let $MYVIMRC = resolve($MYVIMRC)
let $MYVIMRUNTIME = resolve(has('nvim') ? stdpath('config')
                          \ : expand(has('win32') ? '~/vimfiles' : '~/.vim'))

" General Settings {{{1
set autoread
set backspace=indent,eol,start
set belloff=all
set breakindent
set cinoptions+=:0,g0,N-s
set completeopt+=menuone
set display+=lastline
set encoding=utf-8
set foldmethod=marker
set formatoptions=croqnlj
set guioptions=M " has to be before :syntax/:filetype on, so not in gvimrc
set hidden
set hlsearch incsearch ignorecase smartcase
set nojoinspaces
set lazyredraw
set list listchars=tab:>\ ,trail:.,nbsp:~,extends:>,precedes:<
set mouse=a mousemodel=popup nomousehide
set nrformats-=octal
set path& | let &path .= '**' " use :let.=, as 'path' already ends in a comma
set pumheight=12
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

nohlsearch " cancel search highlight from setting hlsearch when reloading
filetype plugin indent on
syntax enable

if exists('+inccommand')
    set inccommand=nosplit
endif

" Open QuickFix entries in the previous window always, if available
if has('patch-8.1.2315') || has('nvim-0.5')
    set switchbuf+=uselast
endif

" completion menu can use popups rather than preview window, if available
if has('patch-8.1.1880')
    set completeopt+=popup " overrides preview flag
endif

" prefer ripgrep over grep, if available
if executable('rg')
    set grepprg=rg\ --vimgrep
endif

" 16-bit true colour is available if Win32 virtual console support is active
if has('vcon')
    set termguicolors
endif

" Don't crowd working dirs with swap, persistent undo & other files; use the
" user runtime directory instead. Nvim already does this by default.
if !has('nvim')
    silent! call mkdir($MYVIMRUNTIME . '/swap', 'p')
    silent! call mkdir($MYVIMRUNTIME . '/undo', 'p')
    silent! call mkdir($MYVIMRUNTIME . '/backup', 'p')

    " NOTE: by using :set^= rather than :let, commas will be added after our
    " prepended entries by vim if required
    execute 'set directory& directory^=' . $MYVIMRUNTIME . '/swap//'
    execute 'set undodir& undodir^=' . $MYVIMRUNTIME . '/undo'

    let &backupdir = '.,' . $MYVIMRUNTIME . '/backup'
    let &viminfofile = $MYVIMRUNTIME . '/viminfo'
endif

function! s:UpdateColorColumn() abort
    let &l:colorcolumn = &modifiable ? '+1' : '' " hide when nomodifiable
endfunction

augroup current_window_cursorline_and_colorcolumn
    autocmd!
    autocmd OptionSet modifiable call s:UpdateColorColumn()
    autocmd WinEnter,BufWinEnter *
                \ call s:UpdateColorColumn() | setlocal cursorline
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

" Distributed Plugin Settings {{{1
packadd cfilter

" if nvim, store the .netrwhist file in the data directory
if has('nvim')
    let g:netrw_home = stdpath('data')
endif

let g:c_no_curly_error = 1 " don't show [{}] as an error; it's valid C++11
let g:markdown_folding = 1
let g:qf_disable_statusline = 1

" Status Line Settings {{{1
function! StatusLine(is_current) abort
    let line  = '%(%w %)'                                   " preview win flag

    " relative file name
    let line .= '%(%{empty(bufname()) ? ''[No Name]'' '
    let line .= ': fnamemodify(bufname(), '':~:.'')} %)'

    let line .= '%([%M%R] %)'                               " modified, RO flag
    let line .= '%(%y %)'                                   " file type
    let line .= '%([%{&spell ? &spelllang : ''''}] %)'      " spell check

    " paste indicator
    if a:is_current && &paste
        let line .= '[%#WarningMsg#PASTE%*] '
    endif

    " plugin-specific status line elements
    for Fn in get(g:, 'plugin_statusline_functions', [])
        let line .= Fn(a:is_current)
    endfor

    let line .= '%='                                        " align right
    let line .= '%-14(%l,%c%V%) '                           " cursor line & col
    let line .= '%P'                                        " scroll percentage
    return line
endfunction

set laststatus=2

" Let statuslines know if they are attached to the currently-active window or
" not. Newer versions of (Neo)Vim can do this easily using 'g:statusline_winid',
" but older versions can achieve the same result using autocommands.
if has('patch-8.1.1372') || has('nvim-0.5')
    set statusline=%!StatusLine(g:statusline_winid\ ==\ win_getid())
else
    set statusline=%!StatusLine(0)

    augroup current_statusline_winid_compatibility
        autocmd!
        autocmd VimEnter,WinEnter * setl statusline=%!StatusLine(1)
        autocmd WinLeave * setl statusline=%!StatusLine(0)
    augroup END
endif

" Tab Line Settings {{{1
function! TabLabel(tabnum) abort
    let buffers = tabpagebuflist(a:tabnum)
    let winnum = tabpagewinnr(a:tabnum)
    let bufname = expand('#' . buffers[winnum - 1] . ':t')

    " default to the working directory's tail component if empty
    if empty(bufname)
        let bufname = fnamemodify(getcwd(winnum, a:tabnum), ':t')
    endif

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

" disable suspend mapping for nvim on windows as there is no way to resume the
" process, which causes a lot of frustration!
if has('nvim') && has('win32')
    nnoremap <silent> <c-z> <nop>
endif

" NOTE: disable flow control for your terminal to use the <C-S> maps!
" press <C-Q> to unfreeze the terminal if you have accidently activated it
nnoremap <silent> <c-s> :update<cr>
inoremap <silent> <c-s> <c-\><c-o>:update<cr>

" Argument list {{{2
nnoremap <leader>a :args<cr>
nnoremap <silent> ]a :next<cr>
nnoremap <silent> [a :previous<cr>

" Buffers and Find {{{2
nnoremap <leader>b :buffer *
nnoremap <leader>f :find *
nnoremap <silent> ]b :bnext<cr>2<c-g>
nnoremap <silent> [b :bprevious<cr>2<c-g>

" QuickFix and Location lists {{{2
nnoremap <silent> <leader>c :cwindow<cr>
nnoremap <silent> <leader>l :lwindow<cr>

nnoremap <silent> ]c :cnext<cr>
nnoremap <silent> [c :cprevious<cr>
nnoremap <silent> ]C :cnewer<cr>
nnoremap <silent> [C :colder<cr>

nnoremap <silent> ]l :lnext<cr>
nnoremap <silent> [l :lprevious<cr>
nnoremap <silent> ]L :lnewer<cr>
nnoremap <silent> [L :lolder<cr>

" Source optional configurations before plugins are loaded {{{1
runtime init_local.vim " machine-specific settings; un-versioned
runtime plugin_conf.vim

" Use my vanilla color scheme choice if one wasn't set {{{1
if !exists('g:colors_name')
    set background=dark
    silent! colorscheme torte
endif
