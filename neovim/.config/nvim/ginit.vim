""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sean Dewar's (Neo)Vim GUI Configuration <https://github.com/seandewar>       "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" some nvim GUIs don't set $MYGVIMRC for us.
" ensure it is set to this file, resolving links along the way.
let $MYGVIMRC = resolve(empty($MYGVIMRC) ? expand('<sfile>:p') : $MYGVIMRC)

" disable pretty much all GUI features and use command-line dialogs.
" (:Gui* commands are for older versions of nvim-qt)
set guioptions=c
silent! GuiTabline 0
silent! GuiPopupmenu 0

" try to use my choice of font, if available
if exists('GuiFont')
    GuiFont! Roboto Mono:h11
else
    silent! set guifont=Roboto\ Mono:h11
endif
