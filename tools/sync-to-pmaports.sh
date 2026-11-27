#!/bin/sh
# Copy this repository's packages, the kernel package (from the mojito-mainline repository) and the firmware package into a
# pmaports checkout, where "pmbootstrap build" / "pmbootstrap install" read them. The mainline device-xiaomi-mojito
# (pkgver 2) replaces pmaports' downstream package of the same name in device/testing/.
#
# Usage: tools/sync-to-pmaports.sh [pmaports] [mojito-mainline clone] [firmware package dir]
#   defaults: $PMAPORTS (else `pmbootstrap config aports`), $MOJITO_MAINLINE, $MOJITO_FIRMWARE
set -eu
HERE=$(dirname "$(realpath "$0")")/..
PMA=${1:-${PMAPORTS:-$(pmbootstrap config aports 2>/dev/null)}}
MAIN=${2:-${MOJITO_MAINLINE:?give the mojito-mainline clone (argument 2 or MOJITO_MAINLINE)}}
FW=${3:-${MOJITO_FIRMWARE:?give the firmware package directory (argument 3 or MOJITO_FIRMWARE)}}
[ -d "$PMA/device" ] || { echo "not a pmaports checkout: $PMA" >&2; exit 1; }
T=$PMA/device/testing
for p in device-xiaomi-mojito hexagonrpcd-mojito u-boot-xiaomi-mojito; do
	rsync -a --delete --exclude 'src/' --exclude 'pkg/' "$HERE/$p/" "$T/$p/"
done
rsync -a --delete "$MAIN/mainline/linux-postmarketos-qcom-sm6150/" "$T/linux-postmarketos-qcom-sm6150/"
mkdir -p "$T/firmware-xiaomi-mojito-mainline"
rsync -a --delete --exclude '.git' --exclude 'README.md' "$FW/" "$T/firmware-xiaomi-mojito-mainline/"
echo "synced into $T: device-xiaomi-mojito hexagonrpcd-mojito u-boot-xiaomi-mojito linux-postmarketos-qcom-sm6150 firmware-xiaomi-mojito-mainline"
