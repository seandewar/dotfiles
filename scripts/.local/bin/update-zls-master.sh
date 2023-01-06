#!/bin/bash
set -eo pipefail

tmpdir=$(mktemp -d --tmpdir zls.XXXXXXXXXX)
echo "using $tmpdir as the temporary directory"

echo 'downloading zls master...'
wget https://zig.pm/zls/downloads/x86_64-linux/bin/zls -O "$tmpdir/zls-master"

echo "moving old zls to $tmpdir/zls-old ..."
mv ~/.local/bin/zls "$tmpdir/zls-old" || true

echo 'moving new zls to ~/.local/bin/zls ...'
mv "$tmpdir/zls-master" ~/.local/bin/zls
chmod +x ~/.local/bin/zls
