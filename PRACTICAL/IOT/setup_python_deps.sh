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

echo "Updating packages..."
sudo apt-get update

echo "Installing base Python packages..."
sudo apt-get install -y \
  python3 \
  python3-pip \
  python3-venv

if [ "${OS_CODENAME}" = "bookworm" ]; then
  echo "Installing GPIO + camera packages for Bookworm..."
  sudo apt-get install -y \
    python3-rpi-lgpio \
    python3-libgpiod \
    libgpiod2 \
    python3-picamera2 \
    python3-flask
else
  echo "Installing GPIO + camera packages for Bullseye/older..."
  sudo apt-get install -y \
    python3-rpi.gpio \
    python3-picamera \
    python3-flask
fi

echo "Installing DHT libraries..."
if [ "${OS_CODENAME}" = "bookworm" ]; then
  python3 -m pip install --break-system-packages --upgrade pip
  python3 -m pip install --break-system-packages adafruit-circuitpython-dht
else
  python3 -m pip install --upgrade pip
  python3 -m pip install adafruit-circuitpython-dht
fi

echo "Done. Python dependencies for experiments 6-9 are installed."
