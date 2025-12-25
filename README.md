# SSH Agent Persistence for Dev Containers

## 功能简介

本方案通过 systemd 托管 `ssh-agent` 和 `socat` 代理，提供一个**重启后依然有效**的固定 Socket 路径 (`/tmp/ssh-agent.sock`)，彻底解决 WSL2/Linux 下 Dev Container 无法稳定复用宿主机 SSH 密钥的痛点。

## 为什么需要这个？（使用场景）

如果你遇到过以下情况，这个工具就是为你准备的：

1. **在 Dev Container 中拉取私有 Git 仓库报错**
   * *痛点*：每次在容器里 `git pull` 都要重新输入密码，或者要把私钥复制到容器里（不安全！）。
   * *解决*：宿主机的 SSH 密钥自动透传进容器，像在本地一样丝滑操作 Git。

2. **WSL2 重启后 SSH Agent 失效**
   * *痛点*：WSL2 每次重启 `/tmp/ssh-XXXXXX/agent.sock` 路径都会变，导致 Dev Container 的配置失效，必须手动改配置。
   * *解决*：提供固定的 `/tmp/ssh-agent.sock` 路径，配置一次，永久有效。

3. **在容器内管理远程服务器 (Ansible/Terraform)**
   * *痛点*：运维容器需要连接生产服务器，但不想把高权限的 SSH Key 放在镜像或容器文件系统中。
   * *解决*：密钥保留在宿主机，容器只通过 Socket 使用密钥，用完即走，更安全。

## 极简使用

1. **安装服务**（在 WSL2/Linux 宿主机执行）

   ```bash
   cd ssh-agent-in-wsl && make install
   ```

   > **提示**: 安装完成后，建议将 `export SSH_AUTH_SOCK=/tmp/ssh-agent.sock` 添加到你的 `~/.bashrc` 或 `~/.zshrc` 中，以便在宿主机终端中也能自动使用该 Agent。

2. **配置 Dev Container**

   在项目的 `.devcontainer/devcontainer.json` 中加入以下配置：

   ```jsonc
   "mounts": [
     "source=/tmp/ssh-agent.sock,target=/ssh-agent,type=bind"
   ],
   "remoteEnv": {
     "SSH_AUTH_SOCK": "/ssh-agent"
   }
   ```

## 验证方法

* **宿主机**：`SSH_AUTH_SOCK=/tmp/ssh-agent.sock ssh-add -l` （查看当前加载的密钥）
* **容器内**：`ssh-add -l` （应显示与宿主机相同的密钥）

## 卸载

```bash
make uninstall
```
