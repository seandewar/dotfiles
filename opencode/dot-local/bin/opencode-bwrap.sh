#!/bin/bash
set -euo pipefail

mkdir -p \
    "$HOME/.config/opencode" \
    "$HOME/.local/share/opencode" \
    "$HOME/.local/state/opencode" \
    "$HOME/.cache/opencode"

# TODO: maybe allow opencode to update itself? Dunno what perms are required;
# writable bind to the executable file itself isn't enough.
# TODO: access to .local/ binaries? Cautious about giving access to all of
# .local/share though, but some binaries may not work properly without.

bwrap \
    --unshare-all \
    --share-net \
    --die-with-parent \
    --hostname opencode \
    --ro-bind "$(which opencode)" "$(which opencode)" \
    --proc /proc \
    --dev /dev \
    --tmpfs /tmp \
    --tmpfs /run \
    --dir "/run/user/$(id -u)" \
    --setenv XDG_RUNTIME_DIR "/run/user/$(id -u)" \
    --ro-bind /usr /usr \
    --ro-bind /etc/alternatives /etc/alternatives \
    --ro-bind /etc/resolv.conf /etc/resolv.conf \
    --symlink usr/bin /bin \
    --symlink usr/sbin /sbin \
    --symlink usr/lib /lib \
    --symlink usr/lib64 /lib64 \
    --bind "$HOME/.config/opencode" "$HOME/.config/opencode" \
    --bind "$HOME/.local/share/opencode" "$HOME/.local/share/opencode" \
    --bind "$HOME/.local/state/opencode" "$HOME/.local/state/opencode" \
    --bind "$HOME/.cache/opencode" "$HOME/.cache/opencode" \
    --bind "$PWD" "$PWD" \
    --chdir "$PWD" \
    -- "$(which opencode)" "$@"
