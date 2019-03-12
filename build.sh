#!/bin/bash

# Fail on errors.
set -e

source ./util.sh

build_name=build-$(get_timestamp)
if [ "$1" = "custom" ]; then
  linux_config=menuconfig
  if [ ! -z $2 ]; then
    build_name=$2
  fi
else
  linux_config=olddefconfig
fi

# Fail on unbound variables.
set -u

# Clean linux kernel source tree
linux_dir=/sources/linux

# Working directory of this build
build_dir=$(pwd)/builds/${build_name}

# Linux kernel build directory
linux_build_dir=${build_dir}/linux-build

# Create symlink to currently building kernel.
working_dirname=working
rm -f ${working_dirname}
ln -sf ${build_dir} ${working_dirname}

# Set the build timestamp for a bitwise repoducible build.
export KBUILD_BUILD_TIMESTAMP="Sun Jan 9 01:23:45 UTC+2 1994"

# Use the current kernel config file for the build.
mkdir -p ${linux_build_dir}
get_kconfig > ${linux_build_dir}/.config

# Update and configure the kernel source.
pushd ${linux_dir} > /dev/null
echo "Updating kernel source..."
update_kernel_source
make O=${linux_build_dir} ${linux_config}
popd > /dev/null

# Begin the kernel build.
pushd ${linux_build_dir} > /dev/null
make -j3

cp arch/${arch}/boot/bzImage ${build_dir}/vmlinuz

# Install the kernel modules.
mod_dir=$(mktemp -d)
make modules_install INSTALL_MOD_PATH=${mod_dir}
kernel_version=$(make kernelversion)
popd > /dev/null

# Package up the modules in a deb.
package_name="linux-modules-${kernel_version}"
package_version=1.0
package_description="linux modules by AutoKern"
# Appease dpkg-deb.
chmod -R a-s ${mod_dir}
make_deb ${mod_dir} ${build_dir}/modules.deb
rm -rf ${mod_dir}


# Delete the last successful build's linux build directory.
rm -rf latest/linux-build

# Switch the symlinks to indicate a successful build.
rm ${working_dirname}
rm -f latest
ln -sf ${build_dir} latest
