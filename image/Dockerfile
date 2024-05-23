FROM us-central1-docker.pkg.dev/cloud-workstations-images/predefined/code-oss:latest

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /root

## INSTALL SECTION
## Copy image setting scripts and customize image
RUN mkdir -p .config/install
COPY ./scripts/install/* .config/install/
RUN .config/install/full_install.bash

## CONFIGURE SECTION
## Set up OS-level configuration for all users
RUN mkdir -p /root/.config/configure
COPY ./scripts/configure/* .config/configure/
RUN .config/configure/full_configure.bash

## EXTRA SECTION
## Set up common system-wide utilities
COPY ./scripts/extra/ws_*.bash /usr/local/bin/

## BOOT SECTION
## Boot time user scripts
COPY ./scripts/boot/[0-9][0-9][0-9]*.sh /etc/workstation-startup.d/