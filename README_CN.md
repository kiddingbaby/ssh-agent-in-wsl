# SSH Agent Persistence for Dev Containers

[English](README.md) | [中文](README_CN.md)

## 简介

本工具通过 **systemd** 托管 `ssh-agent` 和 `socat`，提供一个**固定且持久**的 Socket 路径 (`/tmp/ssh-agent.sock`)，解决 WSL2/Linux 下 Dev Container 无法稳定复用宿主机 SSH 密钥的问题。

## 核心优势

1. **Git 操作免密**：宿主机 SSH 密钥自动透传进容器，无需复制私钥。  
2. **路径固定**：解决 WSL2 重启导致 `/tmp/ssh-XXXXXX/` 路径变化的问题，配置一次永久有效。  
3. **安全隔离**：密钥保留在宿主机，容器只拥有使用权。  

## 快速使用

### 1. 安装服务（在 WSL2 宿主机上执行）

```bash
# 安装服务
cd ssh-agent-in-wsl && make install

# 检查服务状态
systemctl --user status ssh-agent.service ssh-agent-socat.service

# 添加密钥
ssh-add ~/.ssh/<your-private-key>

# 验证密钥是否可用
SSH_AUTH_SOCK=/tmp/ssh-agent.sock ssh-add -l
```

> **提示**: 安装脚本会自动配置并启动 systemd 服务。如果服务已存在，它会尝试重启以应用最新配置。  
> 建议将 `export SSH_AUTH_SOCK=/tmp/ssh-agent.sock` 加入 `~/.bashrc`，以便每次登录自动生效。

### 2. 配置 Dev Container

在 `.devcontainer/devcontainer.json` 中加入：

```jsonc
"mounts": [
  "source=/tmp/ssh-agent.sock,target=/ssh-agent,type=bind"
],
"remoteEnv": {
  "SSH_AUTH_SOCK": "/ssh-agent"
}
```

### 3. 卸载服务

```bash
make uninstall
```

## 使用流程概览

1. 在宿主机启动 systemd 服务，并添加 SSH 密钥。  
2. Dev Container 通过挂载固定 Socket 路径，复用宿主机密钥进行 Git 等操作，无需复制密钥。  
3. 重启 WSL2 或容器后仍可保持 SSH Agent 持久性。
