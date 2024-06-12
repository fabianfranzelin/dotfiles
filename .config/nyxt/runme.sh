#!/bin/bash
#=============================================================================
#  C O P Y R I G H T
#-----------------------------------------------------------------------------
#  Copyright (c) 2024 Robert Bosch GmbH.
#
#  The reproduction, distribution and utilization of this file as
#  well as the communication of its contents to others without express
#  authorization is prohibited. Offenders will be held liable for the
#  payment of damages. All rights reserved in the event of the grant
#  of a patent, utility model or design.
#=============================================================================
#  P R O J E C T   I N F O R M A T I O N
#-----------------------------------------------------------------------------
#  original project: Automotive Operating System
#=============================================================================

# Docker runs as sudo. One needs to give it access to X11
# sudo xhost +si:localuser:root

# Run the container
docker run -it --rm --entrypoint /bin/bash \
       --user "$(whoami)" \
       --net host \
       -e http_proxy \
       -e https_proxy \
       -e DISPLAY \
       -e XAUTHORITY="/tmp/.Xauthority" \
       -e DEBIAN_FRONTEND="noninteractive" \
       -e WEBKIT_DISABLE_COMPOSITING_MODE=1 \
       -e GDK_SYNCHRONIZE=1 \
       -e LIBGL_DEBUG=verbose \
       -e LIBGL_ALWAYS_INDIRECT=1 \
       -e NO_AT_BRIDGE=1 \
       -v "${HOME}/.Xauthority:/tmp/.Xauthority" \
       -v "/tmp/.X11-unix:/tmp/.X11-unix" \
       -v "/var/run/docker.sock:/var/run/docker.sock" \
       -v "${HOME}/.config/nyxt:${HOME}/.config/nyxt" \
       nyxt:latest \
       "$@"
