#!/bin/bash

service dbus start
pulseaudio --start --exit-idle-time=-1
dockerd &

while(! docker info > /dev/null 2>&1); do
    echo "Waiting for Docker daemon..."
    sleep 1
done

service xrdp start
service ssh start

# Start ttyd web terminal on port 7681
ttyd -p 7681 bash &

tail -f /dev/null
