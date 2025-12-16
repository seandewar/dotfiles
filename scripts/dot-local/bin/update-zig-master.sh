#!/bin/bash
set -eo pipefail

url=https://ziglang.org/download/index.json
echo "downloading metadata from $url ..."
metadata=$(wget -nv $url -O - | jq '.master')
zig_version=$(echo "$metadata" | jq -r '.version')
echo "zig master (precompiled) version is $zig_version"
if type ~/.local/share/zig/zig >/dev/null 2>&1; then
    installed_zig_version=$(~/.local/share/zig/zig version)
    echo "installed version is $installed_zig_version"
    if [ "$installed_zig_version" == "$zig_version" ]; then
        echo 'latest version is already installed; nothing to do'
        rm -rf "$tmpdir"
        exit 0
    fi
else
    echo 'zig is not currently installed'
fi

tmpdir=$(mktemp -d --tmpdir zig.XXXXXXXXXX)
echo "using $tmpdir as the temporary directory"
echo 'downloading zig...'
echo "$metadata" | jq -r '."x86_64-linux".tarball' \
    | wget -i - -O "$tmpdir/zig-master"

echo 'verifying checksum...'
zig_checksum=$(echo "$metadata" | jq -r '."x86_64-linux".shasum')
echo "$zig_checksum $tmpdir/zig-master" | sha256sum -c

echo 'checking archive...'
toplevel_files=$(tar --exclude='*/*' -tf "$tmpdir/zig-master")
toplevel_count=$(echo -n "$toplevel_files" | grep -c '^')
if [[ "$toplevel_count" -ne 1 ]]; then
    echo "ERROR: archive had $toplevel_count toplevel files; expected 1"
    exit 1
fi

# /tmp is commonly mounted to a different filesystem, which can make copying
# operations between it and the root fs slow. Zig has lots of files, so avoid
# copying too many things between filesystems. It's OK to extract the archive
# from /tmp though.
echo 'moving old zig to zig-old ...'
rm -rf ~/.local/share/zig-old || true
mv ~/.local/share/zig ~/.local/share/zig-old || true

echo 'extracting archive to ~/.local/share/zig ...'
mkdir -p ~/.local/share/zig
tar -C ~/.local/share/zig --strip-components=1 -xf "$tmpdir/zig-master"

if [[ ! -f ~/.local/bin/zig ]]; then
    echo 'creating symbolic link at ~/.local/bin/zig ...'
    mkdir -p ~/.local/bin
    ln -s ~/.local/share/zig/zig ~/.local/bin/zig
fi

echo 'removing old zig ...'
rm -rf ~/.local/share/zig-old || true
