let g:neoformat_basic_format_trim = 1

function! ConfNeoformatExpr() abort
    if !empty(v:char)
        return 1 " Use built-in formatting when automatically invoked.
    endif
    let msg = execute(v:lnum .. ',' .. (v:lnum + v:count - 1) .. 'Neoformat',
                \     '')
    return 0
endfunction

set formatexpr=ConfNeoformatExpr()
