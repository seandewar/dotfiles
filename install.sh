#!/usr/bin/bash
set -eo pipefail

if [[ $# -eq 0 ]]; then
    echo 'error: no stow package names provided'
    exit 1
fi
for arg in "$@"; do
    if [[ $arg == -* ]]; then
        echo 'error: arguments may only consist of stow package names'
        exit 1
    fi
done

stow_dir=$(readlink -f "$(dirname "$0")")
submod_dir="$stow_dir/.submodules"
target_dir=$(readlink -f "$stow_dir/..")

link_submodule () {
    submod="$1"
    dst="$2"

    target="$target_dir/$dst"
    echo "MKDIR: $dst"
    mkdir -p "$(dirname "$target")"

    echo "LINK: $dst => SUBMODULE $submod"
    ln -sni "$stow_dir/.submodules/$submod" "$target"
}

git submodule update --init -- "$submod_dir"
stow -v --no-folding --dotfiles -d "$stow_dir" -t "$target_dir" -R "$@"

for pkg in "$@"; do
    case "$pkg" in
        'neovim')
            link_submodule minpac .local/share/nvim/site/pack/minpac/opt/minpac
            ;;

        'neovim-vim-compat')
            link_submodule minpac .vim/pack/minpac/opt/minpac
            ;;

        'tmux')
            link_submodule tpm .tmux/plugins/tpm
            ;;
    esac
done
