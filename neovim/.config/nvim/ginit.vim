" Some GUIs don't set $MYGVIMRC for us. Set it to this file, resolving symlinks.
let $MYGVIMRC = resolve(empty($MYGVIMRC) ? expand('<sfile>:p') : $MYGVIMRC)

if exists('g:GuiLoaded')  " nvim-qt
    GuiTabline 0
    GuiPopupmenu 0
    silent! GuiRenderLigatures 1  " Not supported by older versions of nvim-qt
    GuiFont! Iosevka\ Term:h11
else
    set guioptions+=c
    silent! set guifont=Iosevka\ Term:h11
endif

if exists('g:neovide')
    let g:neovide_cursor_animation_length = 0
endif

runtime ginit_local.vim
