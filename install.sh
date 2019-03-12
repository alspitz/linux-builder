#!/bin/sh
set -e

if [ -z $1 ]; then
  echo "Please specify the build directory of the kernel you wish to install."
  exit 1
fi

set -u

build_dir=$1

source ./util.sh

install_kernel_image ${build_dir}/vmlinuz
dpkg -i ${build_dir}/modules.deb
