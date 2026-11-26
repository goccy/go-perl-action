#!/usr/bin/env bash
# install.sh installs the gperl release GPERL_VERSION names ("latest" or a
# tag) for this runner. The archive is checked against the release's
# checksums.txt, and checksums.txt against the build provenance the release
# workflow attested, before gperl is put on PATH.
set -euo pipefail

repo=goccy/go-perl

case "$RUNNER_OS" in
Linux) os=linux ;;
macOS) os=darwin ;;
*)
	echo "::error::setup supports Linux and macOS runners, not $RUNNER_OS"
	exit 1
	;;
esac
case "$RUNNER_ARCH" in
X64) arch=amd64 ;;
ARM64) arch=arm64 ;;
*)
	echo "::error::gperl has no release for $RUNNER_ARCH"
	exit 1
	;;
esac

if [ "$GPERL_VERSION" = latest ]; then
	tag=$(gh release view --repo "$repo" --json tagName --jq .tagName)
else
	tag=v${GPERL_VERSION#v}
fi
asset=gperl_${tag}_${os}_${arch}.tar.gz

work=$(mktemp -d "$RUNNER_TEMP/gperl.XXXXXX")
gh release download "$tag" --repo "$repo" --dir "$work" --pattern "$asset" --pattern checksums.txt
gh attestation verify "$work/checksums.txt" --repo "$repo" --signer-workflow "$repo/.github/workflows/release.yml"
awk -v name="$asset" '$2 == name' "$work/checksums.txt" >"$work/asset.sha256"
if [ ! -s "$work/asset.sha256" ]; then
	echo "::error::checksums.txt of gperl $tag has no $asset"
	exit 1
fi
if [ "$os" = darwin ]; then
	(cd "$work" && shasum -a 256 -c asset.sha256)
else
	(cd "$work" && sha256sum -c asset.sha256)
fi

dest=$RUNNER_TOOL_CACHE/gperl/${tag#v}/$arch
rm -rf "$dest"
mkdir -p "$dest"
tar -xzf "$work/$asset" -C "$dest"
rm -rf "$work"

echo "$dest" >>"$GITHUB_PATH"
echo "gperl-version=$tag" >>"$GITHUB_OUTPUT"
