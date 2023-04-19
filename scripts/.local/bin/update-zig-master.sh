#!/bin/bash
set -eo pipefail

# url=https://ziglang.org/download/index.json
url=https://raw.githubusercontent.com/ziglang/www.ziglang.org/master/data/releases.json
echo "downloading metadata from $url ..."
metadata=$(wget -nv $url -O - | jq '.master')
zig_version=$(echo "$metadata" | jq -r '.version')
echo "zig master (precompiled) version is $zig_version"
if type ~/.local/lib/zig/zig >/dev/null 2>&1; then
    installed_zig_version=$(~/.local/lib/zig/zig version)
    echo "installed version is $installed_zig_version"
    if [ "$installed_zig_version" == "$zig_version" ]; then
        echo 'latest version is already installed; nothing to do'
        rm -rf "$tmpdir"
        exit 0
    fi
else
    echo "zig is not currently installed"
fi

tmpdir=$(mktemp -d --tmpdir zig.XXXXXXXXXX)
echo "using $tmpdir as the temporary directory"
echo "downloading zig..."
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

echo "extracting archive to $tmpdir/zig-master ..."
tar -C "$tmpdir" -xvf "$tmpdir/zig-master"

echo "moving old zig to $tmpdir/zig-old ..."
mv ~/.local/lib/zig "$tmpdir/zig-old" || true

echo 'moving new zig to ~/.local/lib/zig ...'
mkdir -p ~/.local/lib
mv "$tmpdir/$toplevel_files" ~/.local/lib/zig

if [[ ! -f ~/.local/bin/zig ]]; then
    echo 'creating symbolic link at ~/.local/bin/zig ...'
    mkdir -p ~/.local/bin
    ln -s ~/.local/lib/zig/zig ~/.local/bin/zig
fi
