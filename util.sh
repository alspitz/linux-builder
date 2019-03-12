get_kconfig() {
  if [ ! -e /proc/config.gz ]; then
    >&2 echo "error: unable to find config at /proc/config.gz"
    false
  fi

  gunzip -c /proc/config.gz
}

update_kernel_source() {
  # Command to run at root of the kernel source tree to pull the latest changes.
  git fetch --depth 5
  git reset origin/master --hard
}

get_timestamp() {
  date +%F-%H-%M-%S
}

make_deb() {
  # Requires variables for control_template to be set correctly.
  local staging_dir=$1
  local output_file=$2
  mkdir ${staging_dir}/DEBIAN
  eval "echo \"$(cat $(dirname ${BASH_SOURCE[0]})/control_template)\"" > ${staging_dir}/DEBIAN/control
  dpkg -b ${staging_dir} ${output_file}
}

install_kernel_image() {
  local image=$1

  if [ ! -f ${image} ]; then
    echo "error: file ${image} does not exist."
    false
  fi

  boot_part=/dev/sda2
  mount_dir=$(mktemp -d)

  mount ${boot_part} ${mount_dir}

  # Don't install if we detect that this image is already installed.
  if [ -e ${mount_dir}/vmlinuz -a \
       "$(md5sum ${mount_dir}/vmlinuz | cut -d' ' -f 1)" = \
       "$(md5sum ${image} | cut -d' ' -f 1)" ]; then
    echo "error: kernel image already installed, bailing..."
    umount ${boot_part}
    false
  fi

  cp ${mount_dir}/vmlinuz ${mount_dir}/vmlinuz-backup
  cp ${image} ${mount_dir}/vmlinuz
  umount ${boot_part}
}

arch=x86_64
