#!/bin/bash
set -e

echo "=========================================="
echo "  OpenCLAW 自动安装脚本"
echo "=========================================="

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

detect_os() {
    case "$(uname -s)" in
        Linux*)     echo "linux";;
        Darwin*)    echo "macos";;
        CYGWIN*|MINGW*|MSYS*) echo "windows";;
        *)          echo "unknown";;
    esac
}

check_node() {
    if command -v node &> /dev/null; then
        local node_version=$(node --version 2>/dev/null | sed 's/v//')
        local major_version=$(echo "$node_version" | cut -d. -f1)
        
        if [ "$major_version" -ge 22 ]; then
            echo -e "${GREEN}✓ Node.js $node_version 已安装${NC}"
            return 0
        else
            echo -e "${YELLOW}⚠ Node.js 版本过低: $node_version，需要 22+${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}⚠ Node.js 未安装${NC}"
        return 1
    fi
}

install_node() {
    local os=$(detect_os)
    echo "正在安装 Node.js 22..."
    
    if [ "$os" = "macos" ]; then
        if command -v brew &> /dev/null; then
            brew install node@22
            brew link node@22
        else
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            brew install node@22
            brew link node@22
        fi
    elif [ "$os" = "linux" ]; then
        if command -v apt-get &> /dev/null; then
            if [ "$EUID" -ne 0 ]; then
                echo -e "${YELLOW}⚠ 需要 sudo 权限安装 Node.js${NC}"
            fi
            curl -fsSL https://deb.nodesource.com/setup_22.x | bash - 
            apt-get install -y nodejs
        elif command -v yum &> /dev/null; then
            if [ "$EUID" -ne 0 ]; then
                echo -e "${YELLOW}⚠ 需要 sudo 权限安装 Node.js${NC}"
            fi
            curl -fsSL https://rpm.nodesource.com/setup_22.x | bash -
            yum install -y nodejs
        elif command -v dnf &> /dev/null; then
            if [ "$EUID" -ne 0 ]; then
                echo -e "${YELLOW}⚠ 需要 sudo 权限安装 Node.js${NC}"
            fi
            curl -fsSL https://rpm.nodesource.com/setup_22.x | bash -
            dnf install -y nodejs
        elif command -v pacman &> /dev/null; then
            pacman -S --noconfirm nodejs npm
        else
            echo -e "${RED}✗ 无法识别包管理器，请手动安装 Node.js 22+${NC}"
            exit 1
        fi
    elif [ "$os" = "windows" ]; then
        install_node_windows
    else
        echo -e "${RED}✗ 不支持的操作系统: $os${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Node.js 安装完成${NC}"
}

install_node_windows() {
    if command -v winget &> /dev/null; then
        echo "使用 winget 安装 Node.js LTS..."
        
        if winget install -e --id OpenJS.NodeJS.LTS --accept-source-ads --accept-package-agreements 2>/dev/null; then
            echo -e "${GREEN}✓ Node.js 安装完成${NC}"
            echo ""
            echo -e "${YELLOW}⚠ 请关闭当前终端并重新打开，然后再次运行此脚本完成 OpenCLAW 安装${NC}"
            echo ""
            exit 0
        else
            echo -e "${YELLOW}⚠ winget 安装失败，尝试直接下载安装...${NC}"
            install_node_windows_manual
        fi
    else
        echo -e "${YELLOW}⚠ 未检测到 winget，尝试直接下载安装...${NC}"
        install_node_windows_manual
    fi
}

install_node_windows_manual() {
    local temp_dir="$TEMP/node_install_$$"
    local installer="$temp_dir/node-installer.msi"
    
    mkdir -p "$temp_dir"
    
    echo "正在下载 Node.js 安装包..."
    
    if curl -fsSL -o "$installer" "https://nodejs.org/dist/v22.12.0/node-v22.12.0-x64.msi"; then
        echo "正在安装 Node.js..."
        
        if msiexec /i "$installer" /quiet /qn /norestart; then
            echo -e "${GREEN}✓ Node.js 安装完成${NC}"
            echo ""
            echo -e "${YELLOW}⚠ 请关闭当前终端并重新打开，然后再次运行此脚本完成 OpenCLAW 安装${NC}"
            rm -rf "$temp_dir"
            exit 0
        else
            echo -e "${RED}✗ Node.js 安装失败，请手动下载安装: https://nodejs.org/dist/v22.12.0/node-v22.12.0-x64.msi${NC}"
            rm -rf "$temp_dir"
            exit 1
        fi
    else
        echo -e "${RED}✗ 下载失败，请手动下载安装: https://nodejs.org/dist/v22.12.0/node-v22.12.0-x64.msi${NC}"
        rm -rf "$temp_dir"
        exit 1
    fi
}

install_openclaw() {
    local os=$(detect_os)
    echo ""
    echo "正在安装 OpenCLAW..."
    
    if [ "$os" = "macos" ] || [ "$os" = "linux" ]; then
        curl -fsSL https://openclaw.ai/install.sh | bash
    elif [ "$os" = "windows" ]; then
        install_openclaw_windows
    else
        echo -e "${RED}✗ 不支持的操作系统${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ OpenCLAW 安装完成${NC}"
}

install_openclaw_windows() {
    if command -v npm &> /dev/null; then
        npm install -g openclaw
    else
        echo -e "${RED}✗ Node.js 未正确安装，请先安装 Node.js${NC}"
        exit 1
    fi
}

main() {
    local os=$(detect_os)
    echo "检测到操作系统: $os"
    echo ""
    
    if ! check_node; then
        install_node
        
        local new_os=$(detect_os)
        
        if [ "$new_os" = "macos" ]; then
            export PATH="/opt/homebrew/bin:$PATH"
        elif [ "$new_os" = "linux" ]; then
            export PATH="/usr/local/bin:/usr/bin:$PATH"
        elif [ "$new_os" = "windows" ]; then
            export PATH="$PATH:/c/Program Files/nodejs:/c/Program Files (x86)/nodejs"
        fi
        
        if ! check_node; then
            echo -e "${YELLOW}⚠ Node.js 安装完成，请重新打开终端后再次运行此脚本${NC}"
            exit 0
        fi
    fi
    
    echo ""
    install_openclaw
    
    echo ""
    echo "=========================================="
    echo -e "${GREEN}  安装完成！${NC}"
    echo "=========================================="
    echo ""
    echo "下一步运行以下命令完成配置："
    echo "  openclaw onboard --install-daemon"
    echo ""
    echo "启动 Dashboard:"
    echo "  openclaw dashboard"
    echo ""
    echo "------------------------------------------"
    echo "💡 SiliconFlow 邀请链接 (送积分):"
    echo "  https://cloud.siliconflow.cn/i/ABtlZLIj"
    echo "------------------------------------------"
    echo ""
}

main "$@"
