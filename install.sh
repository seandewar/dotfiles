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
    local submod_name="$1"
    local relative_dst="$2"

    local dst="$target_dir/$relative_dst"
    echo "MKDIR: $relative_dst"
    mkdir -p "$(dirname "$dst")"

    submod="$stow_dir/.submodules/$submod_name"
    echo "LINK: $relative_dst => SUBMODULE $submod_name"
    ln -fsn "$submod" "$dst"
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

            # Need to be on a branch for updating to work.
            echo 'CHECKOUT master: SUBMODULE tpm'
            git -C "$submod" checkout -q master
            ;;
    esac
done
