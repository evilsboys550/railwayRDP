#!/bin/bash

echo "[*] Starting PulseAudio..."
mkdir -p /run/pulse
pulseaudio --start

echo "[*] Starting SSH..."
service ssh start

echo "[*] Starting Docker daemon..."
dockerd &

echo "[*] Starting D-Bus..."
service dbus start

echo "[*] Starting XRDP..."
service xrdp restart

echo "[*] Starting Web Terminal (ttyd)..."
/usr/local/bin/ttyd -p 7681 -u root -c root:root bash &

echo "✅ RDP ready on port 3389"
echo "✅ Web Terminal ready on http://localhost:7681 (user: root / pass: root)"
echo "✅ SSH ready on port 22 (user: root / pass: root)"

tail -f /var/log/xrdp-sesman.log
