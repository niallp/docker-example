#!/bin/bash
# This script will run into container

# source the common variables

. imx-5.15.32-2.0.0/env.sh

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

git clone https://github.com/versalogic/meta-versalogic -b kirkstone

# source the yocto env

cd ..

EULA=1 MACHINE="${MACHINE}" DISTRO="${DISTRO}" source imx-setup-release.sh -b build_${DISTRO}

# include meta-versalogic layer in bitbake

cd conf

echo 'BBLAYERS += "${BSPDIR}/sources/meta-versalogic"' >> bblayers.conf

cd ../..

# Build

bitbake ${IMAGES}

