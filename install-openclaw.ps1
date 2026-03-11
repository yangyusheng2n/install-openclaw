# OpenCLAW Windows PowerShell 安装脚本
# 使用方式: irm https://gitee.com/yangyusheng2n/install-openclaw/raw/master/install-openclaw.ps1 | iex

$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  OpenCLAW 自动安装脚本 (Windows)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

function Get-OS {
    return "windows"
}

function Test-NodeInstalled {
    try {
        $nodeVersion = node --version 2>$null
        if ($nodeVersion) {
            $version = $nodeVersion -replace 'v', ''
            $major = [int]($version.Split('.')[0])
            if ($major -ge 22) {
                Write-Host "✓ Node.js $nodeVersion 已安装" -ForegroundColor Green
                return $true
            } else {
                Write-Host "⚠ Node.js 版本过低: $nodeVersion，需要 22+" -ForegroundColor Yellow
                return $false
            }
        }
    } catch {
        Write-Host "⚠ Node.js 未安装" -ForegroundColor Yellow
        return $false
    }
    return $false
}

function Install-Node {
    Write-Host "正在安装 Node.js 22..." -ForegroundColor Cyan
    
    # 尝试使用 winget
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "使用 winget 安装 Node.js LTS..."
        
        try {
            winget install -e --id OpenJS.NodeJS.LTS --accept-source-ads --accept-package-agreements --silent
            
            # 刷新环境变量
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
            
            Write-Host "✓ Node.js 安装完成" -ForegroundColor Green
            Write-Host ""
            Write-Host "请关闭当前 PowerShell 窗口并重新打开，然后再次运行此脚本完成 OpenCLAW 安装" -ForegroundColor Yellow
            exit 0
        } catch {
            Write-Host "⚠ winget 安装失败，尝试直接下载安装..." -ForegroundColor Yellow
        }
    }
    
    # 手动下载安装
    $tempDir = "$env:TEMP\node_install_$PID"
    $installer = "$tempDir\node-installer.msi"
    New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
    
    Write-Host "正在下载 Node.js 安装包..."
    
    try {
        Invoke-WebRequest -Uri "https://nodejs.org/dist/v22.12.0/node-v22.12.0-x64.msi" -OutFile $installer -UseBasicParsing
        
        Write-Host "正在安装 Node.js..."
        
        $process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i", "`"$installer`"", "/quiet", "/qn", "/norestart" -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            # 刷新环境变量
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
            
            Write-Host "✓ Node.js 安装完成" -ForegroundColor Green
            Write-Host ""
            Write-Host "请关闭当前 PowerShell 窗口并重新打开，然后再次运行此脚本完成 OpenCLAW 安装" -ForegroundColor Yellow
            Remove-Item -Recurse -Force $tempDir
            exit 0
        } else {
            Write-Host "✗ Node.js 安装失败，请手动下载安装: https://nodejs.org/dist/v22.12.0/node-v22.12.0-x64.msi" -ForegroundColor Red
            Remove-Item -Recurse -Force $tempDir
            exit 1
        }
    } catch {
        Write-Host "✗ 下载失败，请手动下载安装: https://nodejs.org/dist/v22.12.0/node-v22.12.0-x64.msi" -ForegroundColor Red
        Remove-Item -Recurse -Force $tempDir
        exit 1
    }
}

function Install-OpenCLAW {
    Write-Host ""
    Write-Host "正在安装 OpenCLAW..." -ForegroundColor Cyan
    
    # 刷新环境变量
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    # 添加 npm 全局 bin 路径到 PATH
    $npmPrefix = npm config get prefix
    if ($npmPrefix -and (Test-Path "$npmPrefix")) {
        $npmBinPath = "$npmPrefix"
        if (-not $env:Path.Contains($npmBinPath)) {
            $env:Path = "$npmBinPath;$env:Path"
        }
    }
    
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        try {
            npm install -g openclaw
            Write-Host "✓ OpenCLAW 安装完成" -ForegroundColor Green
            
            # 再次添加 npm bin 路径以确保 openclaw 命令可用
            $npmPrefix = npm config get prefix
            if ($npmPrefix -and (Test-Path "$npmPrefix")) {
                $npmBinPath = "$npmPrefix"
                if (-not $env:Path.Contains($npmBinPath)) {
                    $env:Path = "$npmBinPath;$env:Path"
                }
            }
            
            Write-Host ""
            Write-Host "正在验证 openclaw 命令..." -ForegroundColor Cyan
            
            # 尝试刷新命令缓存并验证
            $openclawPath = Get-Command openclaw -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
            if ($openclawPath) {
                Write-Host "✓ openclaw 命令已可用: $openclawPath" -ForegroundColor Green
            } else {
                Write-Host "⚠ openclaw 命令暂未生效，请重新打开 PowerShell 后使用" -ForegroundColor Yellow
                Write-Host ""
                Write-Host "如需立即生效，可在当前窗口运行以下命令：" -ForegroundColor Yellow
                Write-Host "  `$env:Path = \"$npmPrefix;`$env:Path\"" -ForegroundColor White
            }
        } catch {
            Write-Host "✗ OpenCLAW 安装失败: $_" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "✗ Node.js 未正确安装，请先安装 Node.js" -ForegroundColor Red
        exit 1
    }
}

# 主流程
$os = Get-OS
Write-Host "检测到操作系统: $os"
Write-Host ""

if (-not (Test-NodeInstalled)) {
    Install-Node
}

# 再次检查 Node.js
if (Test-NodeInstalled) {
    Install-OpenCLAW
    
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "  安装完成！" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "下一步运行以下命令完成配置：" -ForegroundColor White
    Write-Host "  openclaw onboard --install-daemon" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "启动 Dashboard:" -ForegroundColor White
    Write-Host "  openclaw dashboard" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "------------------------------------------" -ForegroundColor DarkGray
    Write-Host "💡 SiliconFlow 邀请链接 (送积分):" -ForegroundColor White
    Write-Host "  https://cloud.siliconflow.cn/i/ABtlZLIj" -ForegroundColor Cyan
    Write-Host "------------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
}
