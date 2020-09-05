""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  Sean Dewar's (Neo)Vim Plugin Configuration <https://github.com/seandewar>   "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let $MYPLUGINSVIMRC = expand('<sfile>')

if !&loadplugins
    finish
endif

" General Settings {{{1
" disable netrw (we'll be using dirvish instead) {{{2
let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1

" colorscheme {{{2
colorscheme codedark

" ultisnips {{{2
let g:UltiSnipsSnippetDirectories = [ $VIMUSERDIR . '/ultisnips' ]

" ale {{{2
set completefunc=ale#completion#OmniFunc " lsp as user-defined ins-completion
let g:ale_fix_on_save = 1
let g:ale_linters_explicit = 1
let g:ale_fixers = {
            \ '*': [ 'remove_trailing_lines', 'trim_whitespace' ],
            \ 'c': [ 'clang-format', 'remove_trailing_lines',
            \        'trim_whitespace' ],
            \ 'cpp': [ 'clang-format', 'remove_trailing_lines',
            \          'trim_whitespace' ],
            \ 'markdown': [ 'remove_trailing_lines' ],
            \ 'rust': [ 'rustfmt', 'remove_trailing_lines', 'trim_whitespace' ]
            \ }
let g:ale_linters = {
            \ 'c': [ 'clangd' ],
            \ 'cpp': [ 'clangd' ],
            \ 'rust': [ 'rls' ]
            \ }
let g:ale_c_clangformat_options = '-fallback-style=none'

let g:ale_sign_error = 'E'
let g:ale_sign_warning = 'W'
let g:ale_sign_info = 'I'
let g:ale_echo_msg_format = '[%linter%] %s'

function! ALELintStatusLine() abort
    if !get(g:, 'ale_enabled', 1) || !get(b:, 'ale_enabled', 1)
        return ''
    endif

    if ale#engine#IsCheckingBuffer(bufnr())
        return '...'
    endif

    let counts = ale#statusline#Count(bufnr())
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

let g:plugin_statusline = '%([%{ALELintStatusLine()}] %)'

augroup ale_update_statusline
    autocmd!
    autocmd User ALEJobStarted redrawstatus!
    autocmd User ALELintPost redrawstatus!
    autocmd User ALEFixPost redrawstatus!
augroup END

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
