""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sean Dewar's (Neo)Vim GUI Configuration <https://github.com/seandewar>       "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Some nvim GUIs don't set $MYGVIMRC for us.
" Ensure it is set to this file, resolving links along the way.
let $MYGVIMRC = resolve(empty($MYGVIMRC) ? expand('<sfile>:p') : $MYGVIMRC)

if exists('g:GuiLoaded')
    " Using a GUI that uses the nvim shim helper plugin (e.g nvim-qt)
    GuiTabline 0
    GuiPopupmenu 0
    silent! GuiRenderLigatures 1  " Not supported by older versions of nvim-qt
    GuiFont! Iosevka:h13.5
else
    set guioptions=Mc
    silent! set guifont=Iosevka:h13.5
endif

if exists('g:neovide')
    let g:neovide_cursor_animation_length = 0
    silent! set guifont=Iosevka:h18
endif
