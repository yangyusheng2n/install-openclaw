# install-openclaw

一行命令安装 OpenCLAW 工具

## 介绍

install-openclaw 是一个一键安装脚本，自动检测系统环境并安装 OpenCLAW 工具。支持 macOS、Windows 和主流 Linux 发行版。

## 功能特性

- 自动检测操作系统（macOS / Windows / Linux）
- 自动检测并安装 Node.js 22+（如未安装）
- 一键安装 OpenCLAW
- 支持多种安装方式：
  - macOS: Homebrew
  - Linux: apt-get / yum / dnf / pacman
  - Windows: winget / MSI 静默安装

## 安装教程

### macOS / Linux

```bash
bash install-openclaw.sh
```

或添加执行权限：

```bash
chmod +x install-openclaw.sh
./install-openclaw.sh
```

### Windows

在 PowerShell 或 Git Bash 中运行：

```powershell
# PowerShell
bash install-openclaw.sh

# 或 Git Bash
./install-openclaw.sh
```

注意：Windows 上首次运行脚本安装 Node.js 后，需要**重新打开终端**再次运行脚本完成 OpenCLAW 安装。

## 使用说明

安装完成后，运行以下命令完成配置：

```bash
# 安装守护进程
openclaw onboard --install-daemon

# 启动 Dashboard
openclaw dashboard
```

## 系统要求

- **操作系统**: macOS / Windows 10+ / Linux
- **Node.js**: 22.0.0+（脚本会自动安装）
- **包管理器**: 
  - macOS: Homebrew
  - Linux: apt-get / yum / dnf / pacman
  - Windows: winget (推荐) 或 MSI 安装包

## 脚本检查

安装前可进行语法检查：

```bash
# 语法检查
bash -n install-openclaw.sh

# ShellCheck 静态分析（需安装 shellcheck）
shellcheck install-openclaw.sh
```

## 参与贡献

1. Fork 本仓库
2. 新建 feat/xxx 分支
3. 提交代码
4. 新建 Pull Request

## 相关链接

- [OpenCLAW 官网](https://openclaw.ai)
- [SiliconFlow 邀请链接](https://cloud.siliconflow.cn/i/ABtlZLIj)（送积分）

## 许可证

MIT License
