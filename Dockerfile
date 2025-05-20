FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Set root password
RUN echo "root:root" | chpasswd

# Base system tools and GUI
RUN apt update && apt upgrade -y && \
    apt install -y sudo xrdp xfce4 xfce4-goodies \
    firefox wget curl gnupg2 software-properties-common \
    dbus-x11 xterm policykit-1 \
    pulseaudio alsa-utils pavucontrol \
    net-tools unzip nano openssh-server \
    docker.io git ca-certificates python3 python3-pip fuse \
    gvfs-backends gvfs-fuse build-essential cmake && \
    apt clean

# Install Google Chrome
RUN curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt update && apt install -y google-chrome-stable && apt clean

# Install ttyd (Web terminal)
RUN git clone https://github.com/tsl0922/ttyd.git /opt/ttyd && \
    cd /opt/ttyd && mkdir build && cd build && cmake .. && make && make install

# Configure XFCE for RDP
RUN echo "startxfce4" > /root/.xsession && \
    sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config && \
    sed -i '/fi/a startxfce4' /etc/xrdp/startwm.sh

# PulseAudio config
RUN echo "default-server = unix:/run/pulse/native" >> /etc/pulse/client.conf && \
    echo "autospawn = no" >> /etc/pulse/client.conf && \
    echo "daemon-binary = /bin/true" >> /etc/pulse/client.conf

# Enable GUI apps as root
RUN echo '[Configuration]\nAdminIdentities=unix-user:root' > /etc/polkit-1/localauthority.conf.d/02-allow-root.conf

# Expose RDP, SSH, and Web Terminal ports
EXPOSE 3389 22 7681

# Copy startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
