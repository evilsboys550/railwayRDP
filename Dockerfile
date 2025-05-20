FROM ubuntu:22.04

# Disable interactive frontend and set root password
ENV DEBIAN_FRONTEND=noninteractive
RUN echo 'root:root' | chpasswd

# Install required packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    sudo xrdp xfce4 xfce4-goodies \
    firefox wget curl gnupg2 dbus-x11 xterm policykit-1 \
    pulseaudio alsa-utils pavucontrol \
    net-tools unzip nano openssh-server \
    docker.io git ca-certificates python3 python3-pip fuse \
    build-essential cmake g++ pkg-config libjson-c-dev \
    software-properties-common && \
    apt-get clean

# Fix missing dev libraries
RUN apt-get install -y libwebsockets-dev

# Enable SSH
RUN systemctl enable ssh

# Configure XRDP and XFCE
RUN echo "startxfce4" > /root/.xsession && \
    sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config && \
    sed -i '/fi/a startxfce4' /etc/xrdp/startwm.sh

# Install ttyd (Web Terminal)
RUN git clone https://github.com/tsl0922/ttyd.git /opt/ttyd && \
    cd /opt/ttyd && mkdir build && cd build && \
    cmake .. && make && make install && \
    rm -rf /opt/ttyd

# Enable Docker inside container
RUN usermod -aG docker root

# Expose ports: RDP (3389), SSH (22), Web Terminal (7681)
EXPOSE 3389 22 7681

# Start services
CMD service ssh start && \
    service xrdp start && \
    ttyd -p 7681 -t title="Web Terminal" bash && \
    tail -f /dev/null
