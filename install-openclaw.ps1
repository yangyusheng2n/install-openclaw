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

function Test-Git {
    $git = Get-Command git -ErrorAction SilentlyContinue
    if ($git) {
        return $true
    }
    return $false
}

function Install-Git {
    Write-Host "正在安装 Git..." -ForegroundColor Cyan
    
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "使用 winget 安装 Git..."
        winget install -e --id Git.Git --accept-source-ads --accept-package-agreements --silent
        
        Write-Host "刷新环境变量..."
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        Start-Sleep -Seconds 3
        
        if (Test-Git) {
            Write-Host "Git 安装成功！" -ForegroundColor Green
            return $true
        }
        
        Start-Sleep -Seconds 2
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        if (Test-Git) {
            Write-Host "Git 安装成功！" -ForegroundColor Green
            return $true
        }
    }
    
    Write-Host "请手动安装 Git：" -ForegroundColor Yellow
    Write-Host "方式1: winget install Git.Git" -ForegroundColor White
    Write-Host "方式2: https://git-scm.com/download/win" -ForegroundColor White
    Write-Host ""
    return $false
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
        
        Write-Host "刷新环境变量..."
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        
        Add-NpmPath
        Start-Sleep -Seconds 3
        
        if (Test-Node) {
            Write-Host "Node.js 安装成功！" -ForegroundColor Green
            return $true
        }
        
        Start-Sleep -Seconds 2
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        Add-NpmPath
        
        if (Test-Node) {
            Write-Host "Node.js 安装成功！" -ForegroundColor Green
            return $true
        }
        
        Write-Host ""
        Write-Host "Node.js 安装完成，请重新打开 PowerShell 后运行：" -ForegroundColor Yellow
        Write-Host "irm https://gitee.com/yangyusheng2n/install-openclaw/raw/master/install-openclaw.ps1 | iex"
        Read-Host "按回车键退出"
        exit 0
    }
    
    Write-Host "请手动安装 Node.js 22：" -ForegroundColor Yellow
    Write-Host "https://nodejs.org/dist/v22.12.0/node-v22.12.0-x64.msi" -ForegroundColor White
    Read-Host "按回车键退出"
    exit 1
}

function Install-OpenCLAW {
    Write-Host ""
    Write-Host "正在安装 OpenCLAW..." -ForegroundColor Cyan
    Write-Host ""
    
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
    Read-Host "按回车键退出"
}

# 主流程
Write-Host "检测操作系统: Windows"
Write-Host ""

Add-NpmPath
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# 先检查并安装 Git
if (-not (Test-Git)) {
    Write-Host "检测到 Git 未安装，正在安装..." -ForegroundColor Yellow
    $gitResult = Install-Git
    if (-not $gitResult) {
        Write-Host ""
        Write-Host "Git 安装失败或未安装，OpenCLAW 安装可能需要 Git" -ForegroundColor Yellow
    }
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

if (-not (Test-Node)) {
    $nodeResult = Install-Node
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    Add-NpmPath
}

if (Test-Node) {
    Install-OpenCLAW
}
