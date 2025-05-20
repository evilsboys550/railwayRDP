FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Set timezone
RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    echo "Etc/UTC" > /etc/timezone

# Avoid frontend errors during installation
RUN apt-get update && apt-get install -y \
    software-properties-common && \
    add-apt-repository universe

# Install required packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    sudo xrdp xfce4 xfce4-goodies \
    firefox wget curl gnupg2 \
    dbus-x11 xterm policykit-1 \
    pulseaudio alsa-utils pavucontrol \
    net-tools unzip nano openssh-server \
    docker.io git ca-certificates \
    python3 python3-pip fuse \
    gvfs-backends gvfs-fuse build-essential cmake \
    cmake g++ pkg-config libjson-c-dev libwebsockets-dev \
    && apt-get clean

# Install ttyd (web-based terminal)
RUN git clone https://github.com/tsl0922/ttyd.git /opt/ttyd && \
    cd /opt/ttyd && mkdir build && cd build && \
    cmake .. && make && make install && \
    rm -rf /opt/ttyd

# Enable SSH and allow root login
RUN mkdir /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    sed -i 's/#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Configure XRDP to use XFCE and support root login
RUN echo "startxfce4" > /root/.xsession && \
    sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config && \
    sed -i '/fi/a startxfce4' /etc/xrdp/startwm.sh

# Fix policykit for GUI elevation
RUN echo '[Configuration]\nAdminIdentities=unix-user:root' > /etc/polkit-1/localauthority.conf.d/02-allow-root.conf

# Allow pulseaudio for root
RUN echo "unix-user:root;" > /etc/pulse/client.conf

# Expose required ports
EXPOSE 3389 22 7681

# Start services: SSH, XRDP, and ttyd
CMD service dbus start && \
    service ssh start && \
    service xrdp start && \
    ttyd -p 7681 bash
