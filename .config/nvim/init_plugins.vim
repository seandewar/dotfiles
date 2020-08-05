""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  Sean Dewar's (Neo)Vim Plugin Configuration <https://github.com/seandewar>   "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" General Settings {{{1
let $MYPLUGINSVIMRC = expand('<sfile>')

" can't continue if vim-plug isn't installed
if empty(globpath(&runtimepath, '/autoload/plug.vim'))
    autocmd! VimEnter *
             \ echomsg 'vim-plug is not installed; using minimal configuration.'
    finish
endif

" NOTE: run :PlugUpdate to update plugins, :PlugUpgrade to update vim-plug
call plug#begin($VIMUSERDIR . '/plugged')

Plug 'w0rp/ale' " vim8/nvim async linting engine & lsp client (w/o code actions)
Plug 'ianding1/leetcode.vim' " leetcode integration
Plug 'SirVer/ultisnips' " snippets engine
Plug 'tomasiser/vim-code-dark' " color scheme
Plug 'tpope/vim-commentary' " commands for (un)commenting lines
Plug 'easymotion/vim-easymotion' " easier motions using <leader><leader>
Plug 'derekwyatt/vim-fswitch' " switch between companion files (.h, .c, etc.)
Plug 'tpope/vim-fugitive' " git integration
Plug 'plasticboy/vim-markdown' " markdown file type support
Plug 'sheerun/vim-polyglot' " language support package
Plug 'tpope/vim-repeat' " repeat command (.) support for plugins
Plug 'tpope/vim-surround' " commands for editing surrounding (), '', etc.
Plug 'tpope/vim-vinegar' " enhancements for the netrw directory viewer

if has('nvim-0.5.0')
    Plug 'neovim/nvim-lsp' " lang server configs for nvim's native lsp client
endif

call plug#end()

" runs :PlugInstall synchronously, showing a message, while leaving the window
" active and open
function! s:PlugInstall() abort
    echomsg 'Trying to install missing plugins with vim-plug...'
    PlugInstall --sync
endfunction

" auto run :PlugInstall if we detect missing plugins on startup, otherwise
" prompt user. if installation fails after manually prompting, keep prompting if
" it continues to fail (avoids uncontrollably looping on startup if an auto
" install would continuously fail).
while len(filter(values(g:plugs), '!isdirectory(v:val.dir)')) > 0
    if v:vim_did_enter
        if confirm('Some plugins are missing, try to install them?',
                 \ "&Yes\n&No, abort configuration", 1) == 1
            call s:PlugInstall()
        else
            finish " abort if plugins missing to avoid possible errors
        endif
    else
        autocmd! VimEnter * call s:PlugInstall() | quit | source $MYPLUGINSVIMRC
        finish " cannot continue until after startup; abort for now
    endif
endwhile

" configure color scheme
colorscheme codedark

" configure ultisnips
let g:UltiSnipsSnippetDirectories = [ $VIMUSERDIR . '/ultisnips' ]

" configure ale and its fixing and linting preferences
set completefunc=ale#completion#OmniFunc " lsp as user-defined ins-completion
let g:ale_fix_on_save = 1
let g:ale_linters_explicit = 1
let g:ale_fixers = {
            \ '*': [ 'remove_trailing_lines', 'trim_whitespace' ],
            \ 'c': [ 'clang-format', 'remove_trailing_lines',
                   \ 'trim_whitespace' ],
            \ 'cpp': [ 'clang-format', 'remove_trailing_lines',
                     \ 'trim_whitespace' ],
            \ 'markdown': [ 'remove_trailing_lines' ],
            \ 'rust': [ 'rustfmt', 'remove_trailing_lines', 'trim_whitespace' ]
            \ }
let g:ale_linters = {
            \ 'c': [ 'clangd' ],
            \ 'cpp': [ 'clangd' ],
            \ 'rust': [ 'rls' ]
            \ }
let g:ale_c_clangformat_options = '-fallback-style=none'

" ale gutter error/warning symbols and message configuration
let g:ale_sign_error = 'E'
let g:ale_sign_warning = 'W'
let g:ale_sign_info = 'I'
let g:ale_echo_msg_format = '[%linter%] %s'

" configure leetcode.vim
let g:leetcode_solution_filetype = 'cpp'

" Mappings {{{1
" ale {{{2
" NOTE: most of these binds only work for lsp servers
nnoremap <leader>al :ALELint<cr>
nnoremap <leader>af :ALEFix<cr>
nnoremap <leader>ah :ALEHover<cr>
nnoremap <leader>as :ALESymbolSearch<space>
nnoremap <leader>ar :ALEFindReferences<cr>
nnoremap <leader>aR :ALERename<cr>
nnoremap <leader>ad :ALEGoToDefinition<cr>
nnoremap <leader>at :ALEGoToTypeDefinition<cr>

" ultisnips {{{2
let g:UltiSnipsExpandTrigger = '<c-j>'
let g:UltiSnipsListSnippets = '<c-k>'
let g:UltiSnipsJumpForwardTrigger = '<c-j>'
let g:UltiSnipsJumpBackwardTrigger = '<c-k>'

" vim-fswitch {{{2
nnoremap <leader>oo :FSHere<cr>
nnoremap <leader>oh :FSLeft<cr>
nnoremap <leader>ol :FSRight<cr>
nnoremap <leader>ok :FSAbove<cr>
nnoremap <leader>oj :FSBelow<cr>
nnoremap <leader>oH :FSSplitLeft<cr>
nnoremap <leader>oL :FSSplitRight<cr>
nnoremap <leader>oK :FSSplitAbove<cr>
nnoremap <leader>oJ :FSSplitBelow<cr>

" vim-fugitive {{{2
nnoremap <leader>gg :Git<cr>
nnoremap <silent> <leader>gl :0Gclog<cr>:copen<cr>
nnoremap <silent> <leader>gL :Gclog<cr>:copen<cr>
nnoremap <leader>ge :Gedit<cr>
nnoremap <leader>gd :Gdiffsplit<cr>
nnoremap <leader>gb :Git blame<cr>
nnoremap <leader>gc :Git commit<cr>
nnoremap <leader>gw :Gwrite<cr>
nnoremap <leader>gr :Gread<cr>
nnoremap <leader>gps :Git push<cr>
nnoremap <leader>gpl :Git pull<cr>
