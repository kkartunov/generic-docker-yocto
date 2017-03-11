# GENERIC DOCKER YOCTO BUILD IMAGE
This is generic docker image that will setup Yocto environment to build custom images and build them inside docker container. It is flexible designed with simple idea in mind: `clone this -> setup custom layers -> configure build/conf` let docker build. Mostly for personal reference to remember how to setup such flow.

## Prerequisites
- docker installed on the host system

## Target OS Configuration
The main target OS configuration happen in `build/conf/local.conf`. This file is Yocto's local config file. There are [many options](http://www.yoctoproject.org/docs/current/dev-manual/dev-manual.html#usingpoky-extend-customimage-localconf) one can set via this file and it is probably the best way to configure the build.

## Docker Configuration
To configure the build this setup provides following [ARG](https://docs.docker.com/engine/reference/builder/#arg) variables and sets defaults:
- `USER=builder` - the user doing the build
- `POKY_BRANCH=morty` - the yocto branch to use. Latest archive will be fetched from Yocto's repos
- `OPENEMBEDDED_BRANCH=morty` - openembedded branch layers to fetch in container
- `BUILD_PATH=/home/$USER/build` - path in container for the build
- `HOST_CONF_PATH=build/conf` - path to conf/ folder on the host that will be copied to container
- `HOST_LAYERS_PATH=layers` - path to layers/ folder on the host that will be copied to container
- `BITBAKE_TARGET` - the target for the build

To configure the build this setup provides following [ENV](https://docs.docker.com/engine/reference/builder/#env) variables and sets defaults:
- `POKY_PATH=/home/$USER/poky` - path to place poky in container
- `BBLAYERS_PATH=/home/$USER/bblayers` - path to copy custom layers from host `$HOST_CONF_PATH` to container

## Layers included
`build/conf/bblayers.conf` is used to setup the paths where Yocto layers will be loaded from. Customize the paths here when needed. Note that `BBLAYERS` is relative to build folder which itself is set via `BUILD_PATH`(see docker conf bellow).

By default this setup will place `poky` layers under `$POKY_PATH` and `openembedded` [repo](http://git.openembedded.org/meta-openembedded/) as sub-folder(meta-openembedded-`<$OPENEMBEDDED_BRANCH>`) of it. So if one needs to include recipes from `meta-openembedded/meta-oe` should append `../poky/meta-openembedded-<$OPENEMBEDDED_BRANCH>/meta-oe` in `bblayers.conf`.

Custom layers placed in `$HOST_LAYERS_PATH` on the host will be copied to container to `$BBLAYERS_PATH`. This is to make possible loading of custom layers to container easily.

## Build the Docker image
In project folder where the Dockerfile is type:

`docker build --build-arg BITBAKE_TARGET=<target> -t my/yocto .`

This will take long time the first time one executes the command as it is large environment to setup and long time to compile Yocto. It could happen that the build fails due to failed fetching of files. In this case restart the build again until it is completed successfully.

## Get the output from the build
Yocto image builds will be placed in container `$BUILD_PATH/tmp/deploy/images/<MASHINE>`.

Start the container `docker run -t my/yocto`

In another terminal type `docker ps` and note the ID of the `my/yocto` container. Then `docker exec -t -i <ID> /bin/bash` and navigate to `$BUILD_PATH/tmp/deploy/images/<MASHINE>` to inspect the build.

## Build flow checklist
1. Setup/clone custom layers in layers folder
2. Edit `build/conf/bblayers.conf` to set correct paths to the layers
3. Edit `build/conf/local.conf` to configure Yocto build
4. Build

## References
[Yocto Project Development Manual](http://www.yoctoproject.org/docs/current/dev-manual/dev-manual.html)

[Dockerfile reference](https://docs.docker.com/engine/reference/builder/)

[Building Raspberry Pi Systems with Yocto](http://www.jumpnowtek.com/rpi/Raspberry-Pi-Systems-with-Yocto.html)
