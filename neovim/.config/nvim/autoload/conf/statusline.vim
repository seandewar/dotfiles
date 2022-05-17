" TODO: Nvim doesn't yet support passing containers by reference via the bridge,
" so we need this wrapper function to update the components dictionary.
function! conf#statusline#define_component(name, fn) abort
    let g:conf_statusline_components[a:name] = a:fn
endfunction
