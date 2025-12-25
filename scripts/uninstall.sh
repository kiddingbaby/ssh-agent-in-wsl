#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="$HOME/.config/systemd/user"

echo "Disabling and removing ssh-agent user units"
systemctl --user disable --now ssh-agent.service ssh-agent-socat.service || true
rm -f "$TARGET_DIR/ssh-agent.service" "$TARGET_DIR/ssh-agent-socat.service"
rm -f /tmp/ssh-agent.sock || true
systemctl --user daemon-reload || true

echo "Uninstalled ssh-agent user services and removed proxy socket."
echo ""
echo "Please remember to remove 'export SSH_AUTH_SOCK=/tmp/ssh-agent.sock' from your ~/.bashrc or ~/.zshrc if you added it."
