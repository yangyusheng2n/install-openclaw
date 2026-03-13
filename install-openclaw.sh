#!/bin/bash
set -e

echo "=========================================="
echo "  OpenCLAW 自动安装脚本"
echo "=========================================="

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

detect_os() {
    case "$(uname -s)" in
        Linux*)     echo "linux";;
        Darwin*)    echo "macos";;
        CYGWIN*|MINGW*|MSYS*) echo "windows";;
        *)          echo "unknown";;
    esac
}

check_git() {
    if command -v git &> /dev/null; then
        return 0
    fi
    return 1
}

install_git() {
    local os=$(detect_os)
    echo "正在安装 Git..."
    
    if [ "$os" = "macos" ]; then
        if command -v brew &> /dev/null; then
            brew install git
        else
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            export PATH="/opt/homebrew/bin:$PATH"
            brew install git
        fi
    elif [ "$os" = "linux" ]; then
        if command -v apt-get &> /dev/null; then
            [ "$EUID" -eq 0 ] || echo "需要 sudo 权限"
            apt-get update && apt-get install -y git
        elif command -v yum &> /dev/null; then
            [ "$EUID" -eq 0 ] || echo "需要 sudo 权限"
            yum install -y git
        elif command -v dnf &> /dev/null; then
            [ "$EUID" -eq 0 ] || echo "需要 sudo 权限"
            dnf install -y git
        elif command -v pacman &> /dev/null; then
            pacman -S --noconfirm git
        fi
    fi
    
    if check_git; then
        echo -e "${GREEN}✓ Git 安装成功${NC}"
    else
        echo -e "${RED}✗ Git 安装失败，请手动安装${NC}"
    fi
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
            export PATH="/opt/homebrew/bin:$PATH"
            brew install node@22
            brew link node@22
        fi
    elif [ "$os" = "linux" ]; then
        if command -v apt-get &> /dev/null; then
            if [ "$EUID" -ne 0 ]; then
                echo -e "${YELLOW}需要 sudo 权限安装 Node.js${NC}"
            fi
            curl -fsSL https://deb.nodesource.com/setup_22.x | bash - 
            apt-get install -y nodejs
        elif command -v yum &> /dev/null; then
            if [ "$EUID" -ne 0 ]; then
                echo -e "${YELLOW}需要 sudo 权限安装 Node.js${NC}"
            fi
            curl -fsSL https://rpm.nodesource.com/setup_22.x | bash -
            yum install -y nodejs
        elif command -v dnf &> /dev/null; then
            if [ "$EUID" -ne 0 ]; then
                echo -e "${YELLOW}需要 sudo 权限安装 Node.js${NC}"
            fi
            curl -fsSL https://rpm.nodesource.com/setup_22.x | bash -
            dnf install -y nodejs
        elif command -v pacman &> /dev/null; then
            pacman -S --noconfirm nodejs npm
        else
            echo -e "${RED}✗ 无法识别包管理器，请手动安装 Node.js 22+${NC}"
            exit 1
        fi
    fi
    
    if [ "$os" = "windows" ]; then
        echo "请使用 PowerShell 运行此脚本"
        exit 1
    fi
}

install_openclaw() {
    echo ""
    echo "正在安装 OpenCLAW..."
    echo ""
    
    curl -sSL https://openclaw.ai/install.sh | bash
}

main() {
    local os=$(detect_os)
    echo "检测到操作系统: $os"
    echo ""
    
    export PATH="/opt/homebrew/bin:$PATH"
    export PATH="/usr/local/bin:$PATH"
    
    # 检查并安装 Git
    if ! check_git; then
        echo "检测到 Git 未安装，正在安装..."
        install_git
    fi
    
    if ! check_node; then
        install_node
        
        if ! check_node; then
            echo ""
            echo "=========================================="
            echo -e "${YELLOW}Node.js 安装完成${NC}"
            echo "=========================================="
            echo ""
            echo "请重新打开终端，然后再次运行以下命令："
            echo ""
            echo "curl -fsSL https://gitee.com/yangyusheng2n/install-openclaw/raw/master/install-openclaw.sh | bash"
            echo ""
            read -p "按回车键退出..."
            exit 0
        fi
    fi
    
    install_openclaw
    
    echo ""
    echo "=========================================="
    echo -e "${GREEN}  安装完成！${NC}"
    echo "=========================================="
    echo ""
    echo -e "${YELLOW}下一步运行以下命令完成配置：${NC}"
    echo ""
    echo "  openclaw onboard --install-daemon"
    echo ""
    echo -e "${YELLOW}启动 Dashboard：${NC}"
    echo ""
    echo "  openclaw dashboard"
    echo ""
    echo "------------------------------------------"
    echo -e "${CYAN}SiliconFlow 邀请链接 (送积分)：${NC}"
    echo "  https://cloud.siliconflow.cn/i/ABtlZLIj"
    echo "------------------------------------------"
    echo ""
    echo -e "${GREEN}感谢使用 OpenCLAW！${NC}"
    echo ""
    read -p "按回车键退出..."
}

main "$@"
