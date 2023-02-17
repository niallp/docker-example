#!/bin/bash
# This script will run into container

# source the common variables

. imx-5.15.71-2.2.0/env.sh

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

if [ -d meta-mender ]; then
	cd meta-mender
	git fetch
	cd ..
else
	git clone --single-branch https://github.com/mendersoftware/meta-mender.git -b kirkstone-v2022.10
fi

if [ -d meta-qt5 ]; then
	cd meta-qt5
	git pull
	cd ..
else
	git clone https://github.com/meta-qt5/meta-qt5 -b kirkstone
fi

if [ -d meta-versalogic ]; then
	cd meta-versalogic
	git pull
	cd ..
else
	git clone https://github.com/versalogic/meta-versalogic -b kirkstone
fi

# for poseidon layers
if [ -d meta-poseidon ]; then
	cd meta-poseidon
	git pull
	cd ..
else
	git clone git@ssh.dev.azure.com:v3/PoseidonDev/FlowPressor/G3Kernel meta-poseidon -b dev/niall/swordtail
fi

# source the yocto env

cd ..

EULA=1 MACHINE="${MACHINE}" DISTRO="${DISTRO}" source imx-setup-release.sh -b build_${DISTRO}

# include meta-versalogic layer in bitbake

cd conf

echo 'BBLAYERS += "${BSPDIR}/sources/meta-mender/meta-mender-core"' >> bblayers.conf
echo 'BBLAYERS += "${BSPDIR}/sources/meta-qt5"' >> bblayers.conf
echo 'BBLAYERS += "${BSPDIR}/sources/meta-versalogic"' >> bblayers.conf
echo 'BBLAYERS += "${BSPDIR}/sources/meta-poseidon"' >> bblayers.conf

cd ../..

# Build

bitbake ${IMAGES}

