DISCLAIMER: This Docker example is based off of NXP's Docker example. Original repository is here:
https://github.com/nxp-imx/imx-docker

[VersaLogic Info:: If you have already setup docker on your workstation and have it functioning
 then you should be safe to skip down to "Build i.MX with Docker". 
Otherwise it is highly recommended to at least review all steps below and possibly the docker
tutorials on docker.com. Docker is very dependent on open network ports and group permissions.

VersaLogic has found that even with a good proper environment that the scripts are not always 
very stable. This is to be expected as even when they are run the bash script
will warn about using 'apt'. Of course these scripts themselves only build example
Embedded Linux images via the Yocto Project build system and in the end it is recommended to
use the Docker images downloaded by docker to go in and modify the Yocto recipes and layers as
seen fit for the end product.]


This setup helps to build i.MX BSP in an isolated environment with docker.

Prerequisites
=============

Install Docker
--------------

There are various methods of installing [docker], i.e. by docker script:
  ```{.sh}
  $ curl -fsSL https://get.docker.com -o get-docker.sh
  $ sudo sh get-docker.sh
  ```

Run docker without sudo
-----------------------

To work better with docker, without `sudo`, add your user to `docker group`.
  ```{.sh}
  $ sudo usermod -aG docker <your_user>
  ```

Log out and log back in so that your group membership is re-evaluated.

Set docker to work with proxy
-----------------------------

Create a docker config file at `~/.docker/config.json` and enter the following:

```{.sh}
{
"proxies":
    {
     "default":
         {
          "httpProxy":"http://proxy.example.com:80"
         }
    }
}
```
Note: replace the 'example' proxy with your proxy info.

Create docker service
---------------------
  ```{.sh}
  $ sudo mkdir -p /etc/systemd/system/docker.service.d
  $ sudo vim /etc/systemd/system/docker.service.d/http-proxy.conf
  ```

add the following:

```{.sh}
[Service]
Environment="HTTP_PROXY=http://proxy.example.com:80/"
Environment="NO_PROXY=localhost,someservices.somecompany.com"
```

Restart Docker

```{.sh}
  $ sudo systemctl daemon-reload
  $ sudo systemctl restart docker
```

Build i.MX with docker
======================
```{.sh}
.
├── Dockerfile-Ubuntu-18.04
├── Dockerfile-Ubuntu-20.04
├── README.md
├── docker-build.sh
├── docker-run.sh
├── env.sh -> imx-5.15.32-2.0.0/env.sh
└── imx-5.15.32-2.0.0
    ├── env.sh
    └── yocto-build.sh
```

Set variables
-------------

Use `env.sh` to set variables for your build setup. Make sure you have 
created a working directory, owned by current user, on a larger partition.

Create a yocto-ready docker image
---------------------------------

Run `docker-build.sh` with one argument, related to Dockerfile, corresponding 
to the operating system, for example the Dockerfile for Ubuntu version 20.04:

```{.sh}
  $ ./docker-build.sh Dockerfile-Ubuntu-20.04
```

Build the yocto imx-image in a docker container
-----------------------------------------------

```{.sh}
  $ ./docker-run.sh ${IMX_RELEASE}/yocto-build.sh

  i.e IMX_RELEASE=imx-5.15.32-2.0.0
```

or just go to the docker container prompt (and run the build script from there):

```{.sh}
  $ ./docker-run.sh
```

When running, volumes are used to save the build artifacts on host.
  - `{DOCKER_WORKDIR}` as the main workspace
  - `{DOCKER_WORKDIR}/${IMX_RELEASE}` to make available the yocto build scripts 
    into container
  - `{HOME}` to mount the current home user, to make available the user 
    settings inside the container (ssh keys, git config, etc)

Build using RT script (Yocto Dunfell) : for POS Flowpressor
=====================================

To build container for building g3 and swordtail images using the Reach Technologies:

```{.sh}
  $ ./rt-docker-build.sh Dockerfile-rt-yocto
```

This docker image is setup to use host volumes for persistent code and build artifacts. This can be initially populated from host or within container:

```{.sh}
source rt-env.sh
mkdir -p $YOCTO_DL_DIR
cd $DOCKER_WORKDIR
git clone --depth 1 --branch FSL-QT5-1.1.1 git@github.com:jmore-reachtech/rt-yocto-setup.git
cd $YOCTO_DIR
./setup.sh fsl $YOCTO_DL_DIR
cd sources
git clone git@ssh.dev.azure.com:v3/PoseidonDev/FlowPressor/KernelRecipes meta-poseidon
cd ../build/conf
echo 'BBLAYERS += "${BSPDIR}/sources/meta-poseidon"' >> bblayers.conf
cd ../..
```

To run container:

```{.sh}
./rt-docker-run.sh
```

Example of swordtail image build (within docker container)

```{.sh}
cd rt-yocto-setup
source sources/poky/oe-init-build-env
MACHINE=swordtail bitbake flowpressor
```

Completed build artifacts are stored in image directory. For the example above /datadrive/rt-yocto-docker/rt-yocto-setup/build/tmp/deploy/images/swordtail ... the file usually downloaded and copied to uSD card is flowpressor-swordtail.sdimg.bz2 which is a link to latest build.


[docker]: https://docs.docker.com/engine/install/ubuntu/ "DockerInstall/Ubuntu"
