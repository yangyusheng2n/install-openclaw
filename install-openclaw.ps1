# OpenCLAW Windows 安装脚本
$ErrorActionPreference = "Continue"

Write-Host "=========================================="
Write-Host "  OpenCLAW 自动安装脚本 (Windows)" -ForegroundColor Cyan
Write-Host "=========================================="
Write-Host ""

function Add-NpmPath {
    $npmPath = "$env:APPDATA\npm"
    if (Test-Path $npmPath) {
        $currentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
        if ($currentPath -notlike "*$npmPath*") {
            [System.Environment]::SetEnvironmentVariable("Path", "$npmPath;$currentPath", "User")
            $env:Path = "$npmPath;$env:Path"
            Write-Host "已添加 npm 路径到 PATH" -ForegroundColor Green
        }
    }
}

function Test-Node {
    $node = Get-Command node -ErrorAction SilentlyContinue
    if ($node) {
        $v = node --version
        Write-Host "Node.js $v 已安装" -ForegroundColor Green
        return $true
    }
    return $false
}

function Install-Node {
    Write-Host "正在安装 Node.js 22..." -ForegroundColor Cyan
    
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "使用 winget 安装..."
        winget install -e --id OpenJS.NodeJS.LTS --accept-source-ads --accept-package-agreements --silent
        Write-Host ""
        Write-Host "=========================================="
        Write-Host "Node.js 安装完成！" -ForegroundColor Green
        Write-Host "=========================================="
        Write-Host ""
        Write-Host "请重新打开 PowerShell 后运行：" -ForegroundColor Yellow
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
    Write-Host "下载完成" -ForegroundColor Green
    
    Write-Host "安装中 (可能需要几分钟)..."
    Start-Process msiexec.exe -ArgumentList "/i `"$msi`" /quiet /qn /norestart" -Wait
    
    Write-Host ""
    Write-Host "=========================================="
    Write-Host "Node.js 安装完成！" -ForegroundColor Green
    Write-Host "=========================================="
    Write-Host ""
    Write-Host "请重新打开 PowerShell 后运行：" -ForegroundColor Yellow
    Write-Host "irm https://gitee.com/yangyusheng2n/install-openclaw/raw/master/install-openclaw.ps1 | iex"
    Write-Host ""
    Remove-Item $tmp -Recurse -Force
    Read-Host "按回车键退出"
    exit 0
}

function Install-OpenCLAW {
    Write-Host ""
    Write-Host "正在安装 OpenCLAW..." -ForegroundColor Cyan
    Write-Host ""
    
    # 调用 OpenCLAW 官方安装脚本
    Write-Host "执行官方安装脚本..."
    & ([scriptblock]::Create((Invoke-WebRequest -Uri "https://openclaw.ai/install.ps1" -UseBasicParsing))) -Tag beta
    
    Write-Host ""
    Write-Host "=========================================="
    Write-Host "  安装完成！" -ForegroundColor Green
    Write-Host "=========================================="
    Write-Host ""
    Write-Host "下一步运行以下命令完成配置：" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  openclaw onboard --install-daemon"
    Write-Host ""
    Write-Host "启动 Dashboard：" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  openclaw dashboard"
    Write-Host ""
    Write-Host "------------------------------------------"
    Write-Host "SiliconFlow 邀请链接 (送积分)：" -ForegroundColor Cyan
    Write-Host "  https://cloud.siliconflow.cn/i/ABtlZLIj"
    Write-Host "------------------------------------------"
    Write-Host ""
    Write-Host "感谢使用 OpenCLAW！" -ForegroundColor Green
    Write-Host ""
    Read-Host "按回车键退出"
}

# 主流程
Write-Host "检测操作系统: Windows"
Write-Host ""

Add-NpmPath
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

if (-not (Test-Node)) {
    Install-Node
}

if (Test-Node) {
    Install-OpenCLAW
}
