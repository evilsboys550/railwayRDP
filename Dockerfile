FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt update && apt upgrade -y && \
    apt install -y --no-install-recommends \
      sudo \
      xrdp \
      xfce4 \
      xfce4-goodies \
      firefox \
      wget \
      curl \
      gnupg2 \
      software-properties-common \
      dbus-x11 \
      xterm \
      policykit-1 \
      pulseaudio \
      alsa-utils \
      pavucontrol \
      net-tools \
      unzip \
      nano \
      openssh-server \
      docker.io \
      git \
      ca-certificates \
      python3 \
      python3-pip \
      fuse3 \
      gvfs-backends \
      gvfs-fuse \
      build-essential \
      cmake && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Install Google Chrome
RUN curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt update && apt install -y google-chrome-stable && apt clean && rm -rf /var/lib/apt/lists/*

# Download and install prebuilt ttyd binary
RUN TTYD_VERSION=1.7.4 && \
    curl -Lo /usr/local/bin/ttyd https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/ttyd.x86_64 && \
    chmod +x /usr/local/bin/ttyd

# Configure XFCE for XRDP
RUN echo "startxfce4" > /root/.xsession && \
    sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config && \
    sed -i '/fi/a startxfce4' /etc/xrdp/startwm.sh

# PulseAudio config for forwarding
RUN echo "default-server = unix:/run/pulse/native" >> /etc/pulse/client.conf && \
    echo "autospawn = no" >> /etc/pulse/client.conf && \
    echo "daemon-binary = /bin/true" >> /etc/pulse/client.conf

# Enable GUI apps as root
RUN echo -e '[Configuration]\nAdminIdentities=unix-user:root' > /etc/polkit-1/localauthority.conf.d/02-allow-root.conf

# Expose ports: 3389 (RDP), 22 (SSH), 7681 (ttyd)
EXPOSE 3389 22 7681

# Copy start script
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
