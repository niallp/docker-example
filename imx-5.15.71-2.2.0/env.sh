#!/bin/bash
# Here are some default settings.
# Make sure DOCKER_WORKDIR is created and owned by current user.

# Docker

DOCKER_IMAGE_TAG="imx-yocto"
DOCKER_WORKDIR="/datadrive/swordtail/yocto-docker"

# Yocto

IMX_RELEASE="imx-5.15.71-2.2.0"

YOCTO_DIR="${DOCKER_WORKDIR}/${IMX_RELEASE}-build"

MACHINE="pos-fp-swordtail"
DISTRO="poseidon-fp"
IMAGES="poseidon-image-fp"

REMOTE="https://github.com/nxp-imx/imx-manifest"
BRANCH="imx-linux-kirkstone"
MANIFEST=${IMX_RELEASE}".xml"
