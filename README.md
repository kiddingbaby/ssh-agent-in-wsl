# SSH Agent Persistence for Dev Containers

[English](README.md) | [中文](README_CN.md)

## Introduction

This tool manages `ssh-agent` and `socat` via systemd, providing a **fixed and persistent** Socket path (`/tmp/ssh-agent.sock`). It solves the issue where Dev Containers in WSL2/Linux cannot stably reuse the host's SSH keys.

## Key Features

1. **Passwordless Git Operations**: Host SSH keys are automatically passed through to the container without copying private keys.
2. **Fixed Path**: Solves the issue of `/tmp/ssh-XXXXXX/` path changing after WSL2 restarts. Configure once, valid forever.
3. **Secure Isolation**: Keys remain on the host; the container only has usage rights.

## Quick Start

1. **Install Service** (Run on WSL2/Linux host)

   ```bash
   cd ssh-agent-in-wsl && make install
   ```

   > **Tip**: The install script automatically configures and starts systemd services. If services exist, it attempts to restart them to apply the latest config.
   > It is recommended to add `export SSH_AUTH_SOCK=/tmp/ssh-agent.sock` to `~/.bashrc` or `~/.zshrc`.

2. **Configure Dev Container**

   Add the following to `.devcontainer/devcontainer.json`:

   ```jsonc
   "mounts": [
     "source=/tmp/ssh-agent.sock,target=/ssh-agent,type=bind"
   ],
   "remoteEnv": {
     "SSH_AUTH_SOCK": "/ssh-agent"
   }
   ```

## Verification & Maintenance

### Verify Status

```bash
# Check keys on host
SSH_AUTH_SOCK=/tmp/ssh-agent.sock ssh-add -l

# Check service status
systemctl --user status ssh-agent.service ssh-agent-socat.service
```

### Manually Restart Service

If you need to manually reload the configuration:

```bash
systemctl --user daemon-reload
systemctl --user restart ssh-agent.service ssh-agent-socat.service
```

## Uninstall

```bash
make uninstall
```
