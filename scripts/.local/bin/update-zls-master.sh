#!/bin/bash
set -eo pipefail

tmpdir=$(mktemp -d --tmpdir zls.XXXXXXXXXX)
echo "using $tmpdir as the temporary directory"

echo 'downloading zls master...'
wget https://zig.pm/zls/downloads/x86_64-linux/bin/zls -O "$tmpdir/zls-master"

chmod +x "$tmpdir/zls-master"
zls_version=$("$tmpdir/zls-master" --version)
echo "downloaded zls version is $zls_version"
if type ~/.local/bin/zls >/dev/null 2>&1; then
    installed_zls_version=$(~/.local/bin/zls --version)
    echo "installed version is $installed_zls_version"
    if [ "$installed_zls_version" == "$zls_version" ]; then
        echo 'latest version is already installed; nothing to do'
        rm -rf "$tmpdir"
        exit 0
    fi
else
    echo "zls is not currently installed"
fi

echo "moving old zls to $tmpdir/zls-old ..."
mv ~/.local/bin/zls "$tmpdir/zls-old" || true

echo 'moving new zls to ~/.local/bin/zls ...'
mkdir -p ~/.local/bin
mv "$tmpdir/zls-master" ~/.local/bin/zls
