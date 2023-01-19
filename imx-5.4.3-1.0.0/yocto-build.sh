#!/bin/bash
# This script will run into container

# source the common variables

. imx-5.4.3-1.0.0/env.sh

#

mkdir -p ${YOCTO_DIR}
cd ${YOCTO_DIR}

# Init

repo init \
    -u ${REMOTE} \
    -b ${BRANCH} \
    -m ${MANIFEST}

repo sync -j`nproc`

# add meta-versalogic layer
cd sources

git clone https://github.com/versalogic/meta-versalogic -b zeus

# make some edits since some repos were never updated.
# be careful with the sed 303d edit!! This deletes line 303 of imx-base.inc, not just the text. 
# if repeatedly used it will start deleting necessary stuff

sed -i 's/http/https/g' poky/meta/recipes-extended/libarchive/libarchive_3.4.0.bb

sed -i "s:@make_dtb_boot_files(d):KERNEL_DEVICETREE:g" meta-freescale/conf/machine/include/imx-base.inc

sed -i '303d' meta-freescale/conf/machine/include/imx-base.inc

cd ..

# source the yocto env

EULA=1 MACHINE="${MACHINE}" DISTRO="${DISTRO}" source imx-setup-release.sh -b build_${DISTRO}

# include meta-versalogic layer in bitbake

cd conf

echo 'BBLAYERS += "${BSPDIR}/sources/meta-versalogic"' >> bblayers.conf

cd ..

# Build

bitbake ${IMAGES}

