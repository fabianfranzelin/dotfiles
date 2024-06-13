FROM ubuntu:24.04

# Override user name at build. If build-arg is not passed, will create user named `default_user`
ARG USERNAME=default_user
ARG UID=1

ENV TZ=US
ENV DEBIAN_FRONTEND=noninteractive
ENV HTTP_PROXY="http://127.0.0.1:3128"
ENV HTTPS_PROXY="http://127.0.0.1:3128"
ENV http_proxy="http://127.0.0.1:3128"
ENV https_proxy="http://127.0.0.1:3128"

# create a group and user
RUN echo "Add user ${USERNAME} with ${UID}" && useradd -m -u $UID -U --shell /bin/bash $USERNAME

RUN apt-get update && \
    apt-get install -y \
    git \
    bash \
    sudo \
    wget \
    make \
    tar \
    bzip2 \
    build-essential \
    pkg-config \
    sbcl \
    libfixposix-dev \
    libgstreamer1.0-0 \
    gir1.2-gst-plugins-base-1.0 \
    gir1.2-gst-plugins-bad-1.0 \
    gstreamer1.0-plugins-bad \
    libwebkit2gtk-4.1-0 \
    libfixposix-dev \
    glib-networking \
    gsettings-desktop-schemas \
    xclip \
    enchant-2 \
    gtk3.0 \
    libgtk-3-0 \
    libpangocairo-1.0-0 \
    libcairo2 \
    libgdk-pixbuf2.0-0 \
    libglib2.0-0 \
    libgirepository-1.0-1 \
    libfixposix4t64 \
    gstreamer1.0-gtk3 \
    gstreamer1.0-libav \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-base-apps \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-rtp \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-x \
    # are these needed too?
    # libgstreamer1.0-0 \
    # libgstreamer-plugins-base1.0-0 \
    # libgstreamer-plugins-good1.0-0 \
    # libgstreamer-plugins-bad1.0-0 \
    # libgstreamer-gl1.0-0 \
    alsa-utils \
    libsoundio2 \
    pulseaudio \
    pulseaudio-utils \
    xauth

# make dotfiles available in the docker build context
ADD .config/shell/func/install_nyxt /tmp

# install nyxt
RUN . /tmp/install_nyxt && install_nyxt

ENTRYPOINT [ "nyxt" ]
