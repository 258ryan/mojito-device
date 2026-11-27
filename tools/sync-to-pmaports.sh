#!/bin/sh
# Copy this repo's packages, the private firmware package and the mainline kernel package into the local
# pmaports checkout, where "pmbootstrap build" reads them. The mainline device-xiaomi-mojito (pkgver 2)
# replaces pmaports' downstream one of the same name in device/testing/.
# Usage: tools/sync-to-pmaports.sh [pmaports] [mojito-mainline clone] [mojito-firmware clone]
set -eu
HERE=$(dirname "$(realpath "$0")")/..
PMA=${1:-$HOME/.local/var/pmbootstrap/cache_git/pmaports}
MAIN=${2:-$HOME/.claude-work/mojito-mainline-repo}
FW=${3:-$HOME/.claude-work/mojito-firmware-repo}
T=$PMA/device/testing
for p in device-xiaomi-mojito hexagonrpcd-mojito u-boot-xiaomi-mojito finderlinux finderapps; do
	rsync -a --delete --exclude 'src/' --exclude 'pkg/' "$HERE/$p/" "$T/$p/"
done
rsync -a --delete "$MAIN/mainline/linux-postmarketos-qcom-sm6150/" "$T/linux-postmarketos-qcom-sm6150/"
mkdir -p "$T/firmware-xiaomi-mojito-mainline"
rsync -a --delete --exclude '.git' --exclude 'README.md' "$FW/" "$T/firmware-xiaomi-mojito-mainline/"
echo "synced into $T:"
echo "  device-xiaomi-mojito hexagonrpcd-mojito u-boot-xiaomi-mojito linux-postmarketos-qcom-sm6150 firmware-xiaomi-mojito-mainline"
