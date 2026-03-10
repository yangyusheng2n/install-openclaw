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
    else
        echo -e "${RED}✗ 不支持的操作系统: $os${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Node.js 安装完成${NC}"
}

install_openclaw() {
    local os=$(detect_os)
    echo ""
    echo "正在安装 OpenCLAW..."
    
    if [ "$os" = "macos" ] || [ "$os" = "linux" ]; then
        curl -fsSL https://openclaw.ai/install.sh | bash
    else
        echo -e "${RED}✗ 不支持的操作系统${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ OpenCLAW 安装完成${NC}"
}

main() {
    local os=$(detect_os)
    echo "检测到操作系统: $os"
    echo ""
    
    if ! check_node; then
        install_node
        
        if [ "$(detect_os)" = "macos" ]; then
            export PATH="/opt/homebrew/bin:$PATH"
        elif [ "$(detect_os)" = "linux" ]; then
            export PATH="/usr/local/bin:/usr/bin:$PATH"
        fi
        
        if ! check_node; then
            echo -e "${YELLOW}⚠ Node.js 安装完成，请重新打开终端或运行: source ~/.bashrc ~/.zshrc${NC}"
            echo "重新加载后，手动运行以下命令继续安装 OpenCLAW："
            echo "  curl -fsSL https://openclaw.ai/install.sh | bash"
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
