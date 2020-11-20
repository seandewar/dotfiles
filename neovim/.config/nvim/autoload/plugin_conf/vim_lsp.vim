""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sean Dewar's Configuration for vim-lsp <https://github.com/seandewar>        "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" General Plugin Settings {{{1
packadd vim-lsp
packadd vim-lsp-settings
packadd vim-lsp-snippets
packadd vim-lsp-ultisnips

if &encoding ==# 'utf-8'
    let g:lsp_signs_error = {'text': '⛔'}
    let g:lsp_signs_warning = {'text': '⚠'}
    let g:lsp_signs_information = {'text': 'ℹ'}
    let g:lsp_signs_hint = {'text': '💡'}
else
    let g:lsp_signs_error = {'text': 'X'}
    let g:lsp_signs_warning = {'text': '!'}
    let g:lsp_signs_information = {'text': '>'}
    let g:lsp_signs_hint = {'text': '*'}
endif

let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_diagnostics_echo_delay = 0
let g:lsp_highlights_enabled = 0
let g:lsp_highlight_references_enabled = 0
let g:lsp_textprop_enabled = 0
let g:lsp_virtual_text_enabled = 0

function! plugin_conf#vim_lsp#enable() abort
    call lsp#enable()
endfunction

function! s:SetupBuffer() abort
    " vim-lsp handles completion menu preview and floating/popup windows itself
    setlocal completeopt-=preview completeopt-=popup
    setlocal omnifunc=lsp#complete
    call s:SetupBufferMappings()
endfunction

augroup lsp_setup_buffer
    autocmd!
    autocmd User lsp_buffer_enabled call s:SetupBuffer()
augroup END

" Status Line Settings {{{1
function! plugin_conf#vim_lsp#statusline(is_current) abort
    if !a:is_current || !exists('g:lsp_loaded')
        return ''
    endif

    let counts = lsp#get_buffer_diagnostics_counts()
    let items = []

    if counts['error'] > 0
        let items += ['%#LspErrorText#'
                    \ . get(get(g:, 'lsp_signs_error', {}), 'text', 'E')
                    \ . counts['error']]
    endif
    if counts['warning'] > 0
        let items += ['%#LspWarningText#'
                    \ . get(get(g:, 'lsp_signs_warning', {}), 'text', 'W')
                    \ . counts['warning']]
    endif
    if counts['information'] > 0
        let items += [get(get(g:, 'lsp_signs_information', {}), 'text', 'I')
                    \ . counts['information']]
    endif
    if counts['hint'] > 0
        let items += [get(get(g:, 'lsp_signs_hint', {}), 'text', 'H')
                    \ . counts['hint']]
    endif

    return !empty(items) ? '[' . join(items, '%* ') . '%*] ' : ''
endfunction

" Mappings {{{1
function! s:SetupBufferMappings() abort
    " override tag jumping behaviour for jumping to definitions
    if exists('+tagfunc')
        setlocal tagfunc=lsp#tagfunc
    else
        nmap <buffer> <silent> <c-]> <plug>(lsp-definition)
    endif

    nmap <buffer> <silent> gd <plug>(lsp-declaration)
    nmap <buffer> <silent> gD <plug>(lsp-implementation)
    nmap <buffer> <silent> 1gD <plug>(lsp-type-definition)
    nmap <buffer> <silent> gr <plug>(lsp-references)

    if &filetype !~# 'vim'
        nmap <buffer> <silent> K <plug>(lsp-hover)
    endif
    nmap <buffer> <silent> gK <plug>(lsp-signature-help)

    nmap <buffer> <silent> g0 <plug>(lsp-document-symbol)
    nmap <buffer> <silent> gW <plug>(lsp-workspace-symbol)
    nmap <buffer> <silent> 1gW :LspWorkspaceSymbol <c-r><c-w><cr>

    if exists(':LspDocumentSwitchSourceHeader')
        nmap <buffer> <silent> <leader>ls :LspDocumentSwitchSourceHeader<cr>
    endif

    nmap <buffer> <silent> <leader>la <plug>(lsp-code-action)
    nmap <buffer> <silent> <leader>lc <plug>(lsp-code-lens)

    nmap <buffer> <silent> <leader>lf <plug>(lsp-document-format)
    xmap <buffer> <silent> <leader>lf <plug>(lsp-document-range-format)

    nmap <buffer> <silent> <leader>ll <plug>(lsp-document-diagnostics)
    nmap <buffer> <silent> ]l <plug>(lsp-next-diagnostic)
    nmap <buffer> <silent> [l <plug>(lsp-previous-diagnostic)
endfunction
