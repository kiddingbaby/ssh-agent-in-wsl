# SSH Agent Persistence for Dev Containers

[English](README.md) | [中文](README_CN.md)

## 简介

本工具通过 systemd 托管 `ssh-agent` 和 `socat`，提供一个**固定且持久**的 Socket 路径 (`/tmp/ssh-agent.sock`)，解决 WSL2/Linux 下 Dev Container 无法稳定复用宿主机 SSH 密钥的问题。

## 核心优势

1. **Git 操作免密**：宿主机 SSH 密钥自动透传进容器，无需复制私钥。
2. **路径固定**：解决 WSL2 重启导致 `/tmp/ssh-XXXXXX/` 路径变化的问题，配置一次永久有效。
3. **安全隔离**：密钥保留在宿主机，容器只拥有使用权。

## 快速使用

1. **安装服务**（在 WSL2/Linux 宿主机执行）

   ```bash
   cd ssh-agent-in-wsl && make install
   ```

   > **提示**: 安装脚本会自动配置并启动 systemd 服务。如果服务已存在，它会尝试重启以应用最新配置。
   > 建议将 `export SSH_AUTH_SOCK=/tmp/ssh-agent.sock` 加入 `~/.bashrc` 或 `~/.zshrc`。

2. **配置 Dev Container**

   在 `.devcontainer/devcontainer.json` 中加入：

   ```jsonc
   "mounts": [
     "source=/tmp/ssh-agent.sock,target=/ssh-agent,type=bind"
   ],
   "remoteEnv": {
     "SSH_AUTH_SOCK": "/ssh-agent"
   }
   ```

## 验证与维护

### 验证状态

```bash
# 宿主机查看密钥
SSH_AUTH_SOCK=/tmp/ssh-agent.sock ssh-add -l

# 检查服务状态
systemctl --user status ssh-agent.service ssh-agent-socat.service
```

### 手动重启服务

如果需要手动重载配置：

```bash
systemctl --user daemon-reload
systemctl --user restart ssh-agent.service ssh-agent-socat.service
```

## 卸载

```bash
make uninstall
```
