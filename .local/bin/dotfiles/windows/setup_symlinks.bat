mklink /D %LOCALAPPDATA%\nvim %USERPROFILE%\.config\nvim
mklink /D %LOCALAPPDATA%\nvim-data %USERPROFILE%\.local\share\nvim

mklink /D %USERPROFILE%\vimfiles %USERPROFILE%\.config\nvim
mklink /D %USERPROFILE%\vimfiles\pack %USERPROFILE%\.local\share\nvim\site\pack
mklink %USERPROFILE%\vimfiles\vimrc %USERPROFILE%\.config\nvim\init.vim
mklink %USERPROFILE%\vimfiles\gvimrc %USERPROFILE%\.config\nvim\ginit.vim

mklink %USERPROFILE%\_ideavimrc %USERPROFILE%\.ideavimrc
