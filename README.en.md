# install-openclaw

One-command installation for OpenCLAW tool

## Description

install-openclaw is a one-click installation script that automatically detects your system environment and installs OpenCLAW tool. Supports macOS and major Linux distributions.

## Features

- Automatic OS detection (macOS / Linux)
- Automatic Node.js 22+ installation (if not present)
- One-command OpenCLAW installation
- Supports multiple package managers (brew / apt-get / yum / dnf / pacman)

## Installation

### Option 1: Run directly

```bash
bash install-openclaw.sh
```

### Option 2: Add executable permission

```bash
chmod +x install-openclaw.sh
./install-openclaw.sh
```

## Usage

After installation, run the following commands to complete setup:

```bash
# Install daemon
openclaw onboard --install-daemon

# Start Dashboard
openclaw dashboard
```

## System Requirements

- **OS**: macOS or Linux
- **Node.js**: 22.0.0+ (installed automatically by script)
- **Package Manager**: Homebrew (macOS), apt-get/yum/dnf/pacman (Linux)

## Script Validation

Validate the script before running:

```bash
# Syntax check
bash -n install-openclaw.sh

# ShellCheck static analysis (requires shellcheck)
shellcheck install-openclaw.sh
```

## Contribution

1. Fork the repository
2. Create feat/xxx branch
3. Commit your code
4. Create Pull Request

## Links

- [OpenCLAW Official Website](https://openclaw.ai)
- [SiliconFlow Referral Link](https://cloud.siliconflow.cn/i/ABtlZLIj) (free credits)

## License

MIT License
