""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  Sean Dewar's Vanilla (Neo)Vim Configuration <https://github.com/seandewar>  "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" General Settings {{{1
" get the path to the vim user runtime directory
function! s:GetUserDir() abort
    if exists('*stdpath') " currently an nvim 0.3+ feature; use if available
        return stdpath('config')
    endif

    let basedir = $XDG_CONFIG_HOME
    if empty(basedir)
        let basedir = has('win32') ? '~/AppData/Local' : '~/.config'
    endif

    if has('nvim')
        return expand(basedir . '/nvim')
    else " vim
        " NOTE: vim doesn't respect the XDG spec yet
        return expand(has('win32') ? '~/vimfiles' : '~/.vim')
    endif
endfunction
let $VIMUSERDIR = s:GetUserDir()

" don't crowd working dirs with swap, persistent undo & other files; use the
" user dir instead. NOTE: this doesn't include backup files
if !has('nvim') " neovim does this by default
    silent! call mkdir($VIMUSERDIR . '/swap', 'p')
    silent! call mkdir($VIMUSERDIR . '/undo', 'p')
    let &directory = $VIMUSERDIR . '/swap//,' . &directory
    let &undodir = $VIMUSERDIR . '/undo,' . &undodir
    let &viminfofile = $VIMUSERDIR . '/viminfo'
endif

" use ripgrep over grep if available
if executable('rg')
    set grepprg=rg\ --vimgrep
endif

filetype plugin indent on " turn on auto file type and indent detection
syntax on " turn on syntax highlighting

set autoread " auto read file if changed outside of vim (w/o unsaved changes)
set backspace=indent,eol,start
set belloff=all " disable bell sounds
set encoding=utf-8 " default internal char encoding used by vim
set foldmethod=marker " enable text markers in files for automatic folding
set hidden
set hlsearch incsearch ignorecase smartcase
set lazyredraw " don't redraw while executing untyped commands (e.g: macros)
set nojoinspaces " don't insert 2 spaces after . ? or ! when joining lines
set nrformats-=octal
set number relativenumber
set ruler
set scrolloff=1 sidescroll=5 " auto scroll when cursor is near screen boundaries
set sessionoptions+=localoptions " save local option settings in sessions
set shortmess+=I " disable the intro message
set spelllang=en_gb
set splitbelow splitright
set textwidth=80
set title

" 16-bit true colour is available if Win32 virtual console support is active
if has('vcon')
    set termguicolors
endif

" configure vanilla color scheme; assume dark background
set background=dark
colorscheme torte

" don't indent C/C++ switch cases, class access specifiers & namespace blocks
set cinoptions+=:0,g0,N-s

" configure completion menu - use popups rather than preview window if available
set completeopt=menuone,preview
if has('patch-8.1.1880')
    set completeopt+=popup " overrides preview flag

    if has('patch-8.1.1882')
        set completepopup=border:off
    endif
endif

" enable list mode to draw certain hidden chars (e.g: tabs)
set list listchars=tab:__,trail:.,nbsp:~,extends:>,precedes:<

" don't hide mouse cursor when typing, right-click displays context menu
" ('mouse' is not set, so mouse support is disabled by default for terminals)
set nomousehide mousemodel=popup

" set tab sizes - treat tabs as 8 spaces (as they typically are), insert 4
" spaces when we use tabs or an auto indent, use shiftwidth instead of tabstop
" when inserting tab at the beginning of a line
set tabstop=8 softtabstop=4 shiftwidth=4 autoindent expandtab smarttab

" completion matches for commands (after pressing <tab> or ^D for a list &
" <tab><tab> for the wildmenu)
set wildmenu wildmode=list:longest,full wildignorecase

let c_no_curly_error = 1 " for C++11: don't highlight {} in a [] as a mistake

" make sure we see line numbers in netrw
let g:netrw_bufsettings = 'number relativenumber nomodifiable nomodified
                         \ nobuflisted readonly'

" enforced settings regardless of ftplugin options (easier than creating an
" ftplugin-specific script in .vim/after, but can fail if the ftplugin also
" creates its own autocmd...)
augroup enforce_ft_settings
    autocmd!
    autocmd FileType * setlocal formatoptions=croqljn
    autocmd FileType c,cpp setlocal commentstring=//\ %s
augroup END

" highlight the line that the cursor is on for the active window
augroup auto_window_cursor_line
    autocmd!
    autocmd VimEnter,WinEnter * setlocal cursorline
    autocmd WinLeave * setlocal nocursorline
augroup END

" hides colorcolumn in unmodifiable mode, otherwise sets to textwidth+1
function! s:ColorColumnUpdate() abort
    let &l:colorcolumn = &modifiable ? '+1' : ''
endfunction

" show the colorcolumn for the active window & update if modifiable is (un)set
augroup auto_window_color_column
    autocmd!
    autocmd OptionSet modifiable call s:ColorColumnUpdate()
    autocmd WinEnter,BufWinEnter * call s:ColorColumnUpdate()
    autocmd WinLeave * setlocal colorcolumn=
augroup END

" Status Line Settings {{{1
" generates status line string with ale's lint info for the current buffer.
function! ALELintStatusLine() abort
    if !get(g:, 'loaded_ale', 0) || !get(g:, 'ale_enabled', 1)
                               \ || !get(b:, 'ale_enabled', 1)
        return ''
    endif

    if ale#engine#IsCheckingBuffer(bufnr('%'))
        return '...'
    endif

    let counts = ale#statusline#Count(bufnr('%'))
    if counts.total == 0
        return get(b:, 'ale_linted', 0) > 0 ? 'OK' : ''
    endif

    let total_err = counts.error + counts.style_error
    let total_warn = counts.warning + counts.style_warning

    let line  = total_err > 0 ? total_err . 'E' : ''
    let line .= total_warn > 0 ? ',' . total_warn . 'W' : ''
    let line .= counts.info > 0 ? ',' . counts.info . 'I' : ''
    return line
endfunction

" generates the status line format string for the current window
function! StatusLine() abort
    let line  = '%(%w %)'                                   " preview win flag
    let line .= '%f '                                       " relative file name
    let line .= '%([%M%R] %)'                               " modified, RO flag
    let line .= '%(%y %)'                                   " file type
    let line .= '%([%{&spell ? &spelllang : ""}] %)'        " spell check
    let line .= '%([%{ALELintStatusLine()}] %)'             " ale lint status
    let line .= '%='                                        " align right
    let line .= '%-14(%l,%c%V%) '                           " cursor line & col
    let line .= '%P'                                        " scroll percentage
    return line
endfunction

set laststatus=2 " always display status line
set statusline=%!StatusLine()

" automatically redraw and update window status lines when necessary
augroup auto_redraw_statuslines
    autocmd!
    autocmd User ALEJobStarted redrawstatus!
    autocmd User ALELintPost redrawstatus!
    autocmd User ALEFixPost redrawstatus!
augroup END

" Tab Line Settings {{{1
" generates label string for the tab line
function! TabName(tabnum) abort
    let buffers = tabpagebuflist(a:tabnum)
    let winnum = tabpagewinnr(a:tabnum)
    let bufname = expand('#' . buffers[winnum - 1] . ':t')
    return empty(bufname) ? '[No Name]' : bufname
endfunction

" generates the tab line format string
function! TabLine() abort
    let line = '%T' " reset tab number for the mouse click line

    for t in range(1, tabpagenr('$'))
        " active tab highlight
        let line .= tabpagenr() == t ? '%#TabLineSel# ' : '%#TabLine# '

        let line .= '%' . t . 'T'                     " tab num for mouse clicks
        let line .= t . ' '                           " tab number label
        let line .= '%{TabName(' . t . ')} '          " tab name label
    endfor

    let line .= '%#TabLineFill#' " fill remaining tab line
    return line
endfunction

set tabline=%!TabLine()
set showtabline=1 " only show the tabline if at least two tabs are open

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

" loclist {{{2
nnoremap <leader>l :lwindow<cr>
nnoremap ]l :lnext<cr>
nnoremap [l :lprevious<cr>

" Extra Sources {{{1
" source other optional configuration files in the runtimepath
runtime init_plugins.vim " plugin-specific configurations
runtime init_local.vim   " system-specific configurations; not versioned
