let g:tokyobones_darkness = 'stark'
let g:tokyobones_solid_float_border = v:true
let g:tokyobones_lighten_noncurrent_window = v:true

if has('nvim')
    packadd lush.nvim
endif

packadd zenbones.nvim
runtime colors/tokyobones.vim
