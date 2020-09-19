""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sean Dewar's (Neo)Vim GUI Configuration <https://github.com/seandewar>       "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let $MYGVIMRC = resolve($MYGVIMRC)

" Disable pretty much all GUI features and use command-line dialogs.
" (:Gui* commands are for older versions of nvim-qt)
set guioptions=c
silent! GuiTabline 0
silent! GuiPopupmenu 0

" Try to use my choice of font, if available
if exists('GuiFont')
    GuiFont! Roboto Mono:h11
else
    silent! set guifont=Roboto\ Mono:h11
endif
