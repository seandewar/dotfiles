""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  Sean Dewar's (Neo)Vim GUI Configuration <https://github.com/seandewar>      "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NOTE: this file will auto run after the vimrc if running in a GUI

" disable pretty much all GUI features and use command-line dialogs.
" (Gui commands are for older versions of nvim-qt)
set guioptions=c
silent! GuiTabline 0
silent! GuiPopupmenu 0

" try some default fonts that have a good chance of being installed.
" (the GuiFont commands are again for older versions of nvim-qt)
if has('win32')
    if exists('GuiFont')
        GuiFont! Consolas:h11
    else
        silent! set guifont=Consolas:h11
    endif
else " assume UNIX-like
    if exists('GuiFont')
        GuiFont! DejaVu Sans Mono:h11
    else
        silent! set guifont=DejaVu\ Sans\ Mono\ 11 " assumes GTK+ 2 or 3
    endif
endif

" load an optional system-specific configuration (un-versioned)
runtime ginit_local.vim
