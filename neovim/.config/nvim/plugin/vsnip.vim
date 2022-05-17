set completefunc=conf#vsnip#completefunc

imap <expr> <C-J> vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-J>'
smap <expr> <C-J> vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-J>'
imap <expr> <C-K> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-K>'
smap <expr> <C-K> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-K>'
xmap <C-J> <Plug>(vsnip-cut-text)
