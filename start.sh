#!/bin/bash

# Start D-Bus (needed by many GUI apps)
service dbus start

# Start PulseAudio daemon
pulseaudio --start --exit-idle-time=-1

# Start Docker daemon in background
dockerd &

# Wait for Docker to be ready (optional, for safety)
while(! docker info > /dev/null 2>&1); do
    echo "Waiting for Docker daemon..."
    sleep 1
done

# Start XRDP service
service xrdp start

# Start SSH daemon
service ssh start

# Start ttyd web terminal on port 7681, root shell, no authentication (secure on private networks)
ttyd -p 7681 bash &

# Keep container running
tail -f /dev/null
