#!/bin/bash
set -eo pipefail

tmpdir=$(mktemp -d --tmpdir zls.XXXXXXXXXX)
echo "using $tmpdir as the temporary directory"

if type ~/.local/share/zig/zig >/dev/null 2>&1; then
    installed_zig_version=$(~/.local/share/zig/zig version)
    echo "installed zig version is $installed_zig_version"
else
    echo 'zig is not currently installed'
    exit 0
fi

echo 'downloading metadata for appropriate zls version...'
url="https://releases.zigtools.org/v1/zls/select-version?zig_version=$(jq -rn --arg u "$installed_zig_version" '$u|@uri')&compatibility=only-runtime"
metadata=$(wget -nv "$url" -O -)
zls_version=$(echo "$metadata" | jq -r '.version')
echo "newest compatible zls version is $zls_version"
if type ~/.local/bin/zls >/dev/null 2>&1; then
    installed_zls_version=$(~/.local/bin/zls --version)
    echo "installed zls version is $installed_zls_version"
    if [ "$installed_zls_version" == "$zls_version" ]; then
        echo 'latest version is already installed; nothing to do'
        rm -rf "$tmpdir"
        exit 0
    fi
else
    echo 'zls is not currently installed'
fi

echo "downloading zls $zls_version ..."
echo "$metadata" | jq -r '."x86_64-linux".tarball' \
    | wget -i - -O "$tmpdir/zls-tarball"

echo 'verifying checksum...'
zls_checksum=$(echo "$metadata" | jq -r '."x86_64-linux".shasum')
echo "$zls_checksum $tmpdir/zls-tarball" | sha256sum -c

echo 'extracting archive...'
tar -C "$tmpdir" -xf "$tmpdir/zls-tarball"

echo "moving old zls to $tmpdir/zls-old ..."
mv ~/.local/bin/zls "$tmpdir/zls-old" || true

echo 'moving new zls to ~/.local/bin/zls ...'
mkdir -p ~/.local/bin
mv "$tmpdir/zls" ~/.local/bin/zls
