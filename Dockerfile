FROM ubuntu:22.04

# Set environment to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Set timezone
RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    echo "Etc/UTC" > /etc/timezone

# Install system packages and GUI tools
RUN apt update && apt upgrade -y && \
    apt install -y sudo xrdp xfce4 xfce4-goodies \
    firefox wget curl gnupg2 software-properties-common \
    dbus-x11 xterm policykit-1 \
    pulseaudio alsa-utils pavucontrol \
    net-tools unzip nano openssh-server \
    docker.io git ca-certificates python3 python3-pip fuse \
    gvfs-backends gvfs-fuse build-essential cmake \
    ttyd && \
    apt clean

# Enable SSH
RUN mkdir /var/run/sshd

# Allow root login and set password
RUN echo 'root:root' | chpasswd && \
    sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Configure XRDP to use XFCE and allow root login
RUN echo "startxfce4" > /root/.xsession && \
    if [ -f /etc/X11/Xwrapper.config ]; then \
        sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config; \
    fi && \
    if [ -f /etc/xrdp/startwm.sh ]; then \
        sed -i '/fi/a startxfce4' /etc/xrdp/startwm.sh; \
    fi

# Configure PulseAudio for root
RUN echo "unix-user:root;" > /etc/pulse/client.conf

# Fix policykit to allow GUI elevation as root
RUN echo '[Configuration]\nAdminIdentities=unix-user:root' > /etc/polkit-1/localauthority.conf.d/02-allow-root.conf

# Expose services
EXPOSE 3389 22 7681

# Start all services including SSH, XRDP, and ttyd (web terminal)
CMD service dbus start && \
    service pulseaudio start || true && \
    service ssh start && \
    service xrdp start && \
    ttyd -p 7681 bash
