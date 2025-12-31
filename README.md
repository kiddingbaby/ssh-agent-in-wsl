# SSH Agent Persistence for Dev Containers

[English](README.md) | [中文](README_CN.md)

## Overview

This tool uses **systemd** to manage `ssh-agent` and `socat`, providing a **fixed and persistent** socket path (`/tmp/ssh-agent.sock`). It solves the issue of Dev Containers on WSL2/Linux being unable to reliably reuse host SSH keys.

## Key Advantages

1. **Passwordless Git operations**: Host SSH keys are automatically available inside the container without copying private keys.  
2. **Fixed path**: Avoids the changing `/tmp/ssh-XXXXXX/` path issue after WSL2 restarts; configure once and it works persistently.  
3. **Secure isolation**: Keys remain on the host; the container only has usage access.  

## Quick Start

### 1. Install the service (on WSL2 host)

```bash
# Install the service
cd ssh-agent-in-wsl && make install

# Check service status
systemctl --user status ssh-agent.service ssh-agent-socat.service

# Add your SSH key
ssh-add ~/.ssh/<your-private-key>

# Verify the key is accessible
SSH_AUTH_SOCK=/tmp/ssh-agent.sock ssh-add -l
```

> **Tip**: The install script automatically configures and starts the systemd services.  
> If the service already exists, it will attempt to restart and apply the latest configuration.  
> It is recommended to add `export SSH_AUTH_SOCK=/tmp/ssh-agent.sock` to `~/.bashrc` for automatic setup on login.

### 2. Configure Dev Container

Add the following to `.devcontainer/devcontainer.json`:

```jsonc
"mounts": [
  "source=/tmp/ssh-agent.sock,target=/ssh-agent,type=bind"
],
"remoteEnv": {
  "SSH_AUTH_SOCK": "/ssh-agent"
}
```

### 3. Uninstall the service

```bash
make uninstall
```

## Usage Flow Overview

1. Start the systemd services on the host and add SSH keys.  
2. Dev Container mounts the fixed socket path to reuse host keys for Git or other SSH operations without copying the keys.  
3. SSH Agent remains persistent even after WSL2 or container restarts.
