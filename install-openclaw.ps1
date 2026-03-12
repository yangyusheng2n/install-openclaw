# OpenCLAW Windows 安装脚本
$ErrorActionPreference = "SilentlyContinue"

function Write-Green { param($m) Write-Host $m -ForegroundColor Green }
function Write-Yellow { param($m) Write-Host $m -ForegroundColor Yellow }
function Write-Red { param($m) Write-Host $m -ForegroundColor Red }
function Write-Cyan { param($m) Write-Host $m -ForegroundColor Cyan }

Write-Host "=========================================="
Write-Cyan "  OpenCLAW 自动安装脚本 (Windows)"
Write-Host "=========================================="
Write-Host ""

function Add-NpmPath {
    $npmPath = "$env:APPDATA\npm"
    if (Test-Path $npmPath) {
        $currentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
        if ($currentPath -notlike "*$npmPath*") {
            [System.Environment]::SetEnvironmentVariable("Path", "$npmPath;$currentPath", "User")
            $env:Path = "$npmPath;$env:Path"
            Write-Green "已添加 npm 路径到 PATH"
        }
    }
}

function Test-Node {
    $node = Get-Command node -ErrorAction SilentlyContinue
    if ($node) {
        $v = node --version
        Write-Green "Node.js $v 已安装"
        return $true
    }
    return $false
}

function Install-Node {
    Write-Cyan "正在安装 Node.js 22 (可能需要几分钟)..."
    
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "使用 winget 安装..."
        winget install -e --id OpenJS.NodeJS.LTS --accept-source-ads --accept-package-agreements --silent
        Write-Host ""
        Write-Host "=========================================="
        Write-Green "Node.js 安装完成！"
        Write-Host "=========================================="
        Write-Host ""
        Write-Yellow "请重新打开一个 PowerShell 窗口，然后再次运行以下命令："
        Write-Host ""
        Write-Host "irm https://gitee.com/yangyusheng2n/install-openclaw/raw/master/install-openclaw.ps1 | iex"
        Write-Host ""
        Read-Host "按回车键退出"
        exit 0
    }
    
    $tmp = "$env:TEMP\node_$PID"
    New-Item -ItemType Directory -Force -Path $tmp | Out-Null
    $msi = "$tmp\node.msi"
    
    Write-Host "下载 Node.js..."
    Invoke-WebRequest -Uri "https://nodejs.org/dist/v22.12.0/node-v22.12.0-x64.msi" -OutFile $msi -UseBasicParsing
    Write-Green "下载完成"
    
    Write-Host "安装中 (可能需要几分钟)..."
    $p = Start-Process msiexec.exe -ArgumentList "/i `"$msi`" /quiet /qn /norestart" -PassThru -NoNewWindow -Wait
    
    Remove-Item $tmp -Recurse -Force
    
    Write-Host ""
    Write-Host "=========================================="
    if ($p.ExitCode -eq 0) {
        Write-Green "Node.js 安装完成！"
    } else {
        Write-Red "安装失败，请手动下载: https://nodejs.org/dist/v22.12.0/node.0-x64.msi"
        Write-Yellow "-v22.12安装完成后，请重新打开一个 PowerShell 窗口，然后再次运行以下命令："
    }
    Write-Host "=========================================="
    Write-Host ""
    Write-Yellow "请重新打开一个 PowerShell 窗口，然后再次运行以下命令："
    Write-Host ""
    Write-Host "irm https://gitee.com/yangyusheng2n/install-openclaw/raw/master/install-openclaw.ps1 | iex"
    Write-Host ""
    Read-Host "按回车键退出"
    exit 0
}

function Install-OpenCLAW {
    Write-Host ""
    Write-Cyan "正在安装 OpenCLAW (可能需要几分钟)..."
    
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        Write-Host "清理 npm 缓存..."
        npm cache clean --force 2>$null
        
        Write-Host "安装 openclaw..."
        npm install -g openclaw --loglevel=info 2>$null
        Write-Green "OpenCLAW 安装完成"
        
        Add-NpmPath
        
        Write-Host ""
        Write-Host "=========================================="
        Write-Green "  安装完成！"
        Write-Host "=========================================="
        Write-Host ""
        Write-Yellow "下一步运行以下命令完成配置："
        Write-Host ""
        Write-Host "  openclaw onboard --install-daemon"
        Write-Host ""
        Write-Yellow "启动 Dashboard："
        Write-Host ""
        Write-Host "  openclaw dashboard"
        Write-Host ""
        Write-Host "------------------------------------------"
        Write-Cyan "SiliconFlow 邀请链接 (送积分)："
        Write-Host "  https://cloud.siliconflow.cn/i/ABtlZLIj"
        Write-Host "------------------------------------------"
        Write-Host ""
        Write-Green "感谢使用 OpenCLAW！"
        Write-Host ""
        Read-Host "按回车键退出"
    } else {
        Write-Red "npm 未找到，请先安装 Node.js"
        Write-Host ""
        Read-Host "按回车键退出"
    }
}

# 主流程
Write-Host "检测操作系统: Windows"
Write-Host ""

Add-NpmPath

if (-not (Test-Node)) {
    Install-Node
}

if (Test-Node) {
    Install-OpenCLAW
}
