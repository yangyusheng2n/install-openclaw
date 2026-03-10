# AGENTS.md - OpenCLAW 安装脚本项目指南

## 项目概述

- **项目类型**: Shell 脚本项目（Bash）
- **主要功能**: 自动安装 OpenCLAW 工具，支持 macOS 和 Linux 系统
- **核心文件**: `install-openclaw.sh` - 一键安装脚本

## 构建与测试命令

### 运行安装脚本
```bash
bash install-openclaw.sh
# 或添加执行权限
chmod +x install-openclaw.sh && ./install-openclaw.sh
```

### 脚本检查
```bash
# 语法检查
bash -n install-openclaw.sh

# shellcheck 静态分析
shellcheck install-openclaw.sh

# 安装 shellcheck
brew install shellcheck      # macOS
apt-get install shellcheck  # Debian/Ubuntu
```

## 代码风格指南

### 基础规范
- **解释器**: `#!/bin/bash`，兼容 bash 4.0+
- **严格模式**: 脚本开头 `set -e`
- **缩进**: 4 空格（不用 Tab）
- **行长度**: 最大 100 字符

### 变量与函数
- **局部变量**: 使用 `local` 关键字
- **常量**: `readonly` 或全大写
- **函数名**: 小写 + 下划线 (`detect_os`)
- **变量引用**: 双引号 `${variable}`

```bash
# 正确
local result=$(some_command)
if [ "$result" = "expected" ]; then
    echo "成功"
fi
```

### 错误处理
```bash
set -e
if ! command -v node &> /dev/null; then
    echo -e "${RED}✗ Node.js 未安装${NC}" >&2
    exit 1
fi
```

### 颜色输出
```bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}✓ 成功${NC}"
echo -e "${RED}✗ 失败${NC}"
```

### 字符串处理
- **命令替换**: `$(command)` 不用反引号
- **模式匹配**: `[[ ]]` 替代 `[ ]`

```bash
major_version=$(echo "$node_version" | cut -d. -f1)
```

### 函数设计
- **单一职责**: 一个函数只做一件事
- **返回值**: 0 = 成功，1 = 失败

```bash
detect_os() {
    case "$(uname -s)" in
        Linux*)     echo "linux";;
        Darwin*)    echo "macos";;
        *)          echo "unknown";;
    esac
}
```

### 主函数模式
```bash
main() {
    local os=$(detect_os)
    if ! check_node; then
        install_node
    fi
    install_openclaw
}
main "$@"
```

## ShellCheck 规则
- SC2086: 变量加引号
- SC2166: 用 `[[ ]]` 替代 `[ ]` 模式匹配

## Git 提交规范
```bash
git add install-openclaw.sh
git commit -m "fix: handle Node.js 22 version check"
```
分支: `feat/xxx`, `fix/xxx`, `chore/xxx`

## 注意事项
1. **幂等性**: 脚本可重复运行
2. **权限提示**: root 权限操作需明确提示
3. **兼容性**: 支持 macOS 和主流 Linux
4. **日志**: 关键步骤需用户可见提示

## 相关文档
- [README.md](./README.md) - 项目中文介绍
- [README.en.md](./README.en.md) - 项目英文介绍
