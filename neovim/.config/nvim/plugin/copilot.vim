if exists('g:loaded_copilot')
    finish
endif

" We could just set g:copilot_enabled = 0, but this still loads an instance of
" node in the background, so let's lazy load copilot instead...
augroup conf_copilot_lazy_load
    autocmd!
    autocmd CmdUndefined Copilot ++once packadd copilot.vim
augroup END
