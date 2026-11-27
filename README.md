# mojito-device (private)

postmarketOS packages for the Xiaomi Redmi Note 10 (mojito / sunny) running mainline Linux. Port notes, kernel package
and patches: [258ryan/mojito-mainline](https://github.com/258ryan/mojito-mainline) (public). Vendor firmware:
258ryan/mojito-firmware (private).

| Package | What |
|---|---|
| `device-xiaomi-mojito` (pkgver 2) | mainline device package: deviceinfo (FAT32 ESP, systemd-boot, fallback boot.img), kernel cmdline, Wi-Fi/sensor bring-up services, UCM, Phosh panel overlay |
| `hexagonrpcd-mojito` | hexagonrpcd 0.4.0 + the sensor-PD patch, as `/usr/bin/hexagonrpcd-mojito` |
| `u-boot-xiaomi-mojito` | upstream U-Boot (qcom_defconfig + qcom-phone.config) as an Android boot image for `boot_b` |

## Boot chain

Xiaomi ABL (boot_b) -> U-Boot -> `blkmap` over the pmOS disk image inside `userdata` -> `bootefi bootmgr` ->
systemd-boot (`EFI/BOOT/BOOTAA64.EFI` on pmOS_boot, written by boot-deploy) -> `linux.efi` + initramfs + DTB.
Kernel and DTB updates are plain package upgrades; nothing is flashed. `boot-deploy` also writes `/boot/boot.img`
(direct kernel, header v2) as a fallback: `fastboot boot /path/to/boot.img`.

## Build

    tools/sync-to-pmaports.sh
    pmbootstrap build linux-postmarketos-qcom-sm6150 firmware-xiaomi-mojito-mainline hexagonrpcd-mojito \
        device-xiaomi-mojito u-boot-xiaomi-mojito

Flash U-Boot once: `fastboot flash boot_b u-boot.img` (from `/usr/share/u-boot/xiaomi-mojito/`). Done on the phone
2026-11-27 (U-Boot 2026.10-r0, kernel r31).

## Installing on an existing (downstream) install

Read the whole `apk add --simulate` output first: replacing the downstream packages also removes
`postmarketos-base-downstream-dropbear` (and with it dropbear, the downstream SSH server). Enable OpenSSH before
rebooting: `rc-update add sshd default`. Reformat `/boot` to FAT32 (`mkfs.vfat -F 32 -n pmOS_boot`), fix its fstab line
(new UUID, `vfat`), mount it, then `apk fix linux-postmarketos-qcom-sm6150` so the kernel files and boot-deploy output
land on it.

## Workarounds in the device package

- `clk_ignore_unused` on the kernel command line (unclaimed bootloader clocks).
- Plain wallpaper (the default JPEG XL one makes glycin exhaust memory into a lock-up).
