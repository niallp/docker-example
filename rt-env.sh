#!/bin/bash
# Here are some default settings.
# Make sure DOCKER_WORKDIR is created and owned by current user.

# Docker

DOCKER_IMAGE_TAG="rt-yocto"
DOCKER_WORKDIR="/datadrive/rt-yocto-docker"

# Yocto

YOCTO_DIR="${DOCKER_WORKDIR}/rt-yocto-setup"

MACHINE="pos-fp-swordtail"
DISTRO="poseidon-fp"
IMAGES="poseidon-image-fp"