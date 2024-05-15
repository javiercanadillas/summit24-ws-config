FROM us-central1-docker.pkg.dev/cloud-workstations-images/predefined/code-oss:latest

ARG DEBIAN_FRONTEND=noninteractive

## Copy image setting scripts and customize image
RUN mkdir -p /root/.config/install
COPY ./scripts/install/* .config/install/
RUN .config/install/full_install.bash

## Set up OS-level configuration for all users
RUN mkdir -p /root/.config/configure
COPY ./scripts/configure/* .config/configure/
RUN .config/configure/full_configure.bash

## Set up common system-wide utilities
# COPY ./extra/*.bash /usr/local/bin/

## Boot time user scripts
# Managing dotfiles is the recommended way to manage user settings, so I'm skipping these
# COPY ./scripts/boot/* /etc/workstation-startup.d/