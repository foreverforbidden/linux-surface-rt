# Examples

These come from a Surface RT that runs Raspberry Pi OS 11 (bullseye, armhf) and boots through the UEFI shell. They are not part of the build.

## `raspbian-bullseye/`: an overlay for older userlands

    OVERLAY=examples/raspbian-bullseye ./build.sh surface-rt

| Option | Why |
| --- | --- |
| `CONFIG_MODULE_COMPRESS` off | The `kmod` 28 in Raspberry Pi OS 11 is built without zstd (`kmod --version` shows `-ZSTD`). It cannot load `.ko.zst` modules. With this repository's config, `mwifiex_sdio` does not load and the tablet has no Wi-Fi. |
| `CONFIG_AUTOFS_FS=y` | systemd uses autofs for its automount units. |
| `CONFIG_HARDEN_BRANCH_PREDICTOR=y` | The 5.17 grate-linux kernel had this Spectre v2 mitigation on. |

Any distribution whose `kmod` has no zstd support needs the first change.

## `uefi-shell/`: one-shot trial boots

`startup-trial.nsh` boots the new kernel once if `trynew.flag` is on the boot partition, and deletes the flag first. Every other boot, and a boot where the new kernel fails, starts the old kernel. Linux creates the flag before a trial reboot (`touch /boot/trynew.flag`). With `panic=10`, a panic also returns to the old kernel.

`startup.nsh` is the default after a good trial. It boots the old kernel once if `oldkernel.flag` exists.

On the tablet we tested that the UEFI shell runs `if exist ... then ... endif` and `rm -q` in `startup.nsh`, and that `rm -q` can delete a file on the vfat boot partition. The trial boot of 7.2.13-surface worked, and the reboot after it came back on the old kernel. The fall-through after a kernel that cannot start, and the `oldkernel.flag` path, are not tested.

Install scripts that automate this, with a network check that reboots a trial kernel with no Wi-Fi, are in [surface-rt-linux](https://github.com/foreverforbidden/surface-rt-linux).
