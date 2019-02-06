""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  Sean Dewar's Vim/Neovim GUI Configuration
"  (this runs after the .vimrc)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" disable pretty much all GUI features and use command-line dialogs
" (the Gui* commands are for neovim, which doesn't properly respect guioptions)
set guioptions=c
silent! GuiTabline 0
silent! GuiPopupmenu 0

" set GUI font (GuiFont is used for older versions of neovim instead)
if (has('win32'))
  if (exists(':GuiFont'))
    GuiFont! Consolas:h11
  else
    set guifont=Consolas:h11
  endif
endif
