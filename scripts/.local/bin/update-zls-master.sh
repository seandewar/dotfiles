#!/bin/bash
set -eo pipefail

echo 'querying latest successful zls master branch GitHub Actions run...'
run_id=$(gh run list --repo zigtools/zls --branch master --workflow CI \
    --status success --limit 1 --json databaseId --jq '.[0].databaseId')

tmpdir=$(mktemp -d --tmpdir zls.XXXXXXXXXX)
echo "using $tmpdir as the temporary directory"

echo "downloading zls master from GHA run ID $run_id ..."
gh run download "$run_id" --repo zigtools/zls --name zls-x86_64-linux \
    --dir "$tmpdir"

chmod +x "$tmpdir/zls"
zls_version=$("$tmpdir/zls" --version)
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
mv "$tmpdir/zls" ~/.local/bin/zls
