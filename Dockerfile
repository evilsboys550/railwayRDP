FROM docker:dind

# Enable root login
RUN echo "root:root" | chpasswd

# Install packages you need
RUN apk update && apk add --no-cache \
    sudo xrdp xfce4 xfce4-goodies firefox \
    bash curl dbus-x11 pulseaudio alsa-utils \
    openssh nano git python3 py3-pip \
    gvfs gvfs-fuse cmake g++ make pkgconfig \
    libwebsockets libwebsockets-dev \
    xterm dbus policykit polkit-gnome

# Setup XRDP and XFCE
RUN echo "startxfce4" > /root/.xsession && \
    mkdir -p /etc/X11 && \
    echo "allowed_users=anybody" > /etc/X11/Xwrapper.config && \
    sed -i '/fi/a startxfce4' /etc/xrdp/startwm.sh

# Install ttyd (Web Terminal)
RUN git clone https://github.com/tsl0922/ttyd.git /opt/ttyd && \
    cd /opt/ttyd && mkdir build && cd build && \
    cmake .. && make && make install && rm -rf /opt/ttyd

# Expose RDP, SSH, ttyd
EXPOSE 3389 22 7681

# Start services and ttyd
CMD dockerd-entrypoint.sh & \
    service ssh start && \
    service xrdp start && \
    ttyd -p 7681 -t title="Web Terminal" bash && \
    tail -f /dev/null
