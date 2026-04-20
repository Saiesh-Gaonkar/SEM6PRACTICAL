#!/usr/bin/env bash
set -euo pipefail

if [ "${EUID}" -eq 0 ]; then
  echo "Please run this script as a normal user (no sudo)."
  echo "It will use sudo when needed."
  exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
  echo "sudo is required to install packages."
  exit 1
fi

OS_NAME="Unknown"
OS_CODENAME=""
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS_NAME="${PRETTY_NAME:-${NAME}}"
  OS_CODENAME="${VERSION_CODENAME:-}"
fi

echo "Detected OS: ${OS_NAME}"
if [ -n "${OS_CODENAME}" ]; then
  echo "Codename: ${OS_CODENAME}"
fi

case "${OS_CODENAME}" in
  bookworm|bullseye)
    ;;
  *)
    echo "Warning: This script is tested for Raspberry Pi OS Bullseye/Bookworm."
    ;;
 esac

echo "Updating packages..."
sudo apt-get update

echo "Installing base packages..."
sudo apt-get install -y \
  curl \
  ca-certificates \
  build-essential \
  git \
  python3 \
  python3-pip \
  python3-venv

echo "Installing Arduino IDE and CLI..."
if apt-cache show arduino >/dev/null 2>&1; then
  sudo apt-get install -y arduino
elif apt-cache show arduino-ide >/dev/null 2>&1; then
  sudo apt-get install -y arduino-ide
else
  echo "Arduino IDE package not found in apt. Install manually from https://www.arduino.cc/en/software"
fi

if apt-cache show arduino-cli >/dev/null 2>&1; then
  sudo apt-get install -y arduino-cli
else
  echo "arduino-cli package not found in apt. Skipping CLI install."
fi

if [ "${OS_CODENAME}" = "bookworm" ]; then
  sudo apt-get install -y \
    python3-rpi-lgpio \
    python3-libgpiod \
    libgpiod2 \
    python3-picamera2
else
  sudo apt-get install -y \
    python3-rpi.gpio \
    python3-picamera
fi

echo "Installing Flask..."
sudo apt-get install -y python3-flask

echo "Installing DHT libraries..."
if [ "${OS_CODENAME}" = "bookworm" ]; then
  python3 -m pip install --break-system-packages --upgrade pip
  python3 -m pip install --break-system-packages adafruit-circuitpython-dht
else
  python3 -m pip install --upgrade pip
  python3 -m pip install adafruit-circuitpython-dht
fi

echo "Installing MQTT broker..."
sudo apt-get install -y mosquitto mosquitto-clients
if command -v systemctl >/dev/null 2>&1; then
  sudo systemctl enable mosquitto
  sudo systemctl start mosquitto
fi

echo "Installing Node-RED..."
bash <(curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered) \
  --confirm-install \
  --confirm-pi \
  --no-init \
  --restart

if command -v systemctl >/dev/null 2>&1; then
  echo "Enabling Node-RED service..."
  sudo systemctl enable nodered.service
  sudo systemctl start nodered.service
else
  echo "systemctl not found. Start Node-RED with 'node-red-start'."
fi

echo "Installing Node-RED dashboard..."
if [ -d "${HOME}/.node-red" ]; then
  (cd "${HOME}/.node-red" && npm install --no-update-notifier --no-audit --no-fund node-red-dashboard)
else
  echo "Node-RED user directory not found. Skipping dashboard install."
fi

echo "Installing Arduino cores and libraries..."
if command -v arduino-cli >/dev/null 2>&1; then
  if [ ! -f "${HOME}/.arduino15/arduino-cli.yaml" ]; then
    arduino-cli config init >/dev/null
  fi
  ESP8266_URL="http://arduino.esp8266.com/stable/package_esp8266com_index.json"
  arduino-cli core update-index --additional-urls "${ESP8266_URL}"
  arduino-cli core install arduino:avr
  arduino-cli core install esp8266:esp8266 --additional-urls "${ESP8266_URL}"
  arduino-cli lib install \
    "DHT sensor library" \
    "Adafruit Unified Sensor" \
    "Adafruit BMP085 Library" \
    "RTClib" \
    "PubSubClient"
else
  echo "arduino-cli not installed; skipping core/library setup."
fi

echo "Done. Open http://<pi-ip>:1880"
