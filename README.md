# linux-builder

Provides a (semi) automated way to pull, build, and install new Linux kernels.

* build.sh: Run to pull latest kernel, configure with current kernel configuration (taken from proc/), and build. Pass "custom" to do menuconfig. Requires a Linux kernel checkout in `$linux_dir`
* install\_latest.sh: Run to install the latest built kernel image. Requires manual configuration of partitions and file names (see source).

Use at your own risk and double check destination directories!

## Limitations

Currently does not support (copy over) ramdisks. Assumes booting without initramfs.
