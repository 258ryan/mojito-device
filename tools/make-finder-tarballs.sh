#!/bin/sh
# Make the source tarballs for the finderlinux / finderapps packages from local clones (both repositories are private, so
# pmbootstrap cannot fetch them itself). The tarballs are not committed (.gitignore); run this before pmbootstrap build.
# Usage: tools/make-finder-tarballs.sh [clones dir, default ~/.claude-work/finder]
set -eu
SRC=${1:-$HOME/.claude-work/finder}
HERE=$(cd "$(dirname "$0")/.." && pwd)
for p in finderlinux finderapps; do
	git -C "$SRC/$p" pull -q --ff-only 2>/dev/null || true
	rev=$(git -C "$SRC/$p" log -1 --format=%cs | tr -d -)
	git -C "$SRC/$p" archive --format=tar.gz --prefix="$p-$rev/" -o "$HERE/$p/$p-$rev.tar.gz" HEAD
	echo "$p: $p-$rev.tar.gz ($(git -C "$SRC/$p" log -1 --format=%h))"
done
