FROM ubuntu:16.04

# Defines
ARG USER=builder
ARG POKY_BRANCH=morty
ARG OPENEMBEDDED_BRANCH=morty
ARG BUILD_PATH=/home/$USER/build
ARG HOST_CONF_PATH=build/conf
ARG HOST_LAYERS_PATH=layers

# Intended command for the image
CMD "/bin/bash"

# Update
RUN apt-get update && apt-get -y upgrade

# Set the locale
RUN apt-get install -y locales
RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8' POKY_PATH=/home/$USER/poky BBLAYERS_PATH=/home/$USER/bblayers

# Install utilities
RUN apt-get install -y build-essential unzip cpio checkinstall chrpath diffstat gawk git wget libncurses5-dev pkg-config subversion texi2html texinfo python2.7 libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev

# Link python 2.7 package as 'python' that the Yocto 2.2 branch requires
RUN ln -sf /usr/bin/python2.7 /usr/bin/python
RUN apt-get install -y python-software-properties software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa && apt update
RUN apt install -y python3.6
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 3
RUN update-alternatives --install /usr/bin/python python /usr/bin/python2.7 2

RUN apt install -y vim

# Create a non-root user that will perform the actual build
RUN id build 2>/dev/null || useradd --uid 30000 --create-home $USER
RUN echo $USER" ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers

# Get dependencies
WORKDIR /home/$USER
# RUN wget http://git.yoctoproject.org/cgit/cgit.cgi/poky/snapshot/poky-$POKY_BRANCH.zip && unzip poky-$POKY_BRANCH.zip && mv poky-$POKY_BRANCH $POKY_PATH && rm poky-$POKY_BRANCH.zip
RUN git clone --depth=1 git://git.yoctoproject.org/poky -b morty $POKY_PATH
# RUN wget http://git.openembedded.org/meta-openembedded/snapshot/meta-openembedded-$OPENEMBEDDED_BRANCH.zip && unzip meta-openembedded-$OPENEMBEDDED_BRANCH.zip && mv meta-openembedded-$OPENEMBEDDED_BRANCH $POKY_PATH && rm meta-openembedded-$OPENEMBEDDED_BRANCH.zip
RUN git clone --depth=1 https://github.com/openembedded/meta-openembedded.git -b morty $POKY_PATH/meta-openembedded
# Copy host's build and layers folders to container
COPY $HOST_CONF_PATH $BUILD_PATH/conf
COPY $HOST_LAYERS_PATH $BBLAYERS_PATH
RUN chmod -R 777 $BUILD_PATH

RUN echo "export LANG='en_US.UTF-8'" >> /home/$USER/.bashrc
RUN echo "export LANGUAGE='en_US:en'" >> /home/$USER/.bashrc
RUN echo "export LC_ALL='en_US.UTF-8'" >> /home/$USER/.bashrc

# Run the build
USER $USER
ARG BITBAKE_TARGET=core-image-sato
RUN /bin/bash -c "source $POKY_PATH/oe-init-build-env $BUILD_PATH && MACHINE=beaglebone bitbake $BITBAKE_TARGET"

# EOF
