#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(dirname "$HERE")"
SYSTEMD_DIR="$PROJECT_ROOT/systemd"
TARGET_DIR="$HOME/.config/systemd/user"

echo "Installing ssh-agent user units to $TARGET_DIR"
mkdir -p "$TARGET_DIR"
cp "$SYSTEMD_DIR/ssh-agent.service" "$TARGET_DIR/ssh-agent.service"
cp "$SYSTEMD_DIR/ssh-agent-socat.service" "$TARGET_DIR/ssh-agent-socat.service"

# Ensure ssh-agent exists
if ! command -v ssh-agent >/dev/null 2>&1; then
  echo "Error: ssh-agent not found. Please install OpenSSH client (package name often 'openssh-client') and re-run." >&2
  exit 1
fi

# Ensure socat is installed (try common package managers)
if ! command -v socat >/dev/null 2>&1; then
  echo "socat not found. Attempting to install (will try apt, dnf, pacman, apk)."
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update && sudo apt-get install -y socat
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y socat
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy --noconfirm socat
  elif command -v apk >/dev/null 2>&1; then
    sudo apk add --no-cache socat
  else
    echo "Please install 'socat' manually and re-run this script." >&2
    exit 1
  fi
fi

# Check if systemd is available
if ! command -v systemctl >/dev/null 2>&1 || ! systemctl --user list-units >/dev/null 2>&1; then
    echo "Error: systemd is not available or not running as user. This script requires systemd." >&2
    exit 1
fi

# Reload user systemd and enable services (idempotent)
systemctl --user daemon-reload
systemctl --user enable ssh-agent.service ssh-agent-socat.service

# (Re)start to ensure updated unit files take effect
systemctl --user restart ssh-agent.service ssh-agent-socat.service

echo "Done. Check with: systemctl --user status ssh-agent.service ssh-agent-socat.service"

echo ""
echo "To use this ssh-agent in your current shell, add the following to your ~/.bashrc or ~/.zshrc:"
echo "    export SSH_AUTH_SOCK=/tmp/ssh-agent.sock"
echo ""

echo "Note: this installer is generic. It exposes /tmp/ssh-agent.sock by default; ensure your container runtime mounts that path."
