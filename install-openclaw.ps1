# OpenCLAW Windows 安装脚本
$ErrorActionPreference = "SilentlyContinue"

Write-Host "=========================================="
Write-Host "  OpenCLAW 自动安装脚本 (Windows)"
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
        Write-Host "安装完成，请重新打开 PowerShell 后再次运行此脚本" -ForegroundColor Yellow
        exit 0
    }
    
    $tmp = "$env:TEMP\node_$PID"
    New-Item -ItemType Directory -Force -Path $tmp | Out-Null
    $msi = "$tmp\node.msi"
    
    Write-Host "下载 Node.js..."
    Invoke-WebRequest -Uri "https://nodejs.org/dist/v22.12.0/node-v22.12.0-x64.msi" -OutFile $msi -UseBasicParsing
    
    Write-Host "安装中..."
    Start-Process msiexec.exe -ArgumentList "/i `"$msi`" /quiet /qn /norestart" -Wait
    
    Remove-Item $tmp -Recurse -Force
    Write-Host "安装完成，请重新打开 PowerShell 后再次运行此脚本" -ForegroundColor Yellow
    exit 0
}

function Install-OpenCLAW {
    Write-Host ""
    Write-Host "正在安装 OpenCLAW..." -ForegroundColor Cyan
    
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        npm install -g openclaw
        Write-Host "OpenCLAW 安装完成" -ForegroundColor Green
        
        Add-NpmPath
        
        Write-Host ""
        Write-Host "=========================================="
        Write-Host "  安装完成！" -ForegroundColor Green
        Write-Host "=========================================="
        Write-Host ""
        Write-Host "下一步运行：openclaw onboard --install-daemon"
        Write-Host ""
    } else {
        Write-Host "npm 未找到，请先安装 Node.js" -ForegroundColor Red
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
