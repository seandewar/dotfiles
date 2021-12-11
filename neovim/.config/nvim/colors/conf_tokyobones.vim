if has('nvim')
    packadd lush.nvim

    " These options only work in Nvim
    let g:tokyobones_darkness = 'stark'
    let g:tokyobones_solid_float_border = v:true
endif

packadd zenbones.nvim
runtime colors/tokyobones.vim
