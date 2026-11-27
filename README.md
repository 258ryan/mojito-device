# mojito-device

postmarketOS packages for the **Xiaomi Redmi Note 10** (mojito / sunny, SM6150) running **mainline Linux**: the device
package, the patched hexagonrpcd for the ADSP sensor PD, and U-Boot chainloaded by the Xiaomi bootloader. The kernel
package, its patches and the port's notes are in [mojito-mainline](https://github.com/258ryan/mojito-mainline).

| Package | What |
|---|---|
| `device-xiaomi-mojito` (pkgver 2) | deviceinfo (FAT32 ESP, systemd-boot, fallback boot.img), kernel cmdline, the Wi-Fi/Bluetooth loader and sensors services, UCM, Phosh panel overlay, accelerometer mount matrix |
| `hexagonrpcd-mojito` | hexagonrpcd 0.4.0 + the sensor-PD patch as `/usr/bin/hexagonrpcd-mojito`, with its OpenRC service (fastrpc user, secure node) |
| `u-boot-xiaomi-mojito` | upstream U-Boot (qcom_defconfig + qcom-phone.config) as an Android boot image for `boot_b` |

## Boot chain

Xiaomi ABL (`boot_b`) -> U-Boot -> `blkmap` over the pmOS disk image inside `userdata` -> `bootefi bootmgr` ->
systemd-boot (`EFI/BOOT/BOOTAA64.EFI` on pmOS_boot, written by boot-deploy) -> `linux.efi` + initramfs + DTB.
Kernel and DTB updates are plain package upgrades; nothing is flashed. `boot-deploy` also writes `/boot/boot.img`
(direct kernel, header v2) as a fallback: `fastboot boot boot.img`.

## Build

    tools/sync-to-pmaports.sh <pmaports> <mojito-mainline clone> <firmware package dir>
    pmbootstrap build linux-postmarketos-qcom-sm6150 firmware-xiaomi-mojito-mainline hexagonrpcd-mojito \
        device-xiaomi-mojito u-boot-xiaomi-mojito

Flash U-Boot once (phone in Xiaomi fastboot, bootloader unlocked): `fastboot erase dtbo_b; fastboot flash boot_b u-boot.img;
fastboot set_active b` (`u-boot.img` is in `/usr/share/u-boot/xiaomi-mojito/`).

## Installing over an existing (downstream) install

Read the whole `apk add --simulate` output first: replacing the downstream packages also removes
`postmarketos-base-downstream-dropbear` (and with it dropbear, the downstream SSH server). Enable OpenSSH before
rebooting: `rc-update add sshd default`. Reformat `/boot` to FAT32 (`mkfs.vfat -F 32 -n pmOS_boot`), fix its fstab line
(new UUID, `vfat`), mount it, then `apk fix linux-postmarketos-qcom-sm6150` so the kernel files and boot-deploy output
land on it.

## Workarounds in the device package

- Plain wallpaper (the default JPEG XL one makes glycin exhaust memory into a lock-up).
- Wi-Fi and Bluetooth are loaded by `mojito-wifi` in the order the WCN3950 firmware requires (see the service's header).
