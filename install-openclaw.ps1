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
    Write-Host "正在安装 Node.js 22 (可能需要几分钟)..." -ForegroundColor Cyan
    
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "使用 winget 安装..."
        winget install -e --id OpenJS.NodeJS.LTS --accept-source-ads --accept-package-agreements --silent
        Write-Host ""
        Write-Host "==========================================" -ForegroundColor Green
        Write-Host "Node.js 安装完成！" -ForegroundColor Green
        Write-Host "=========================================="
        Write-Host ""
        Write-Host "请重新打开一个 PowerShell 窗口，然后再次运行以下命令：" -ForegroundColor Yellow
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
    Write-Host "下载链接: https://nodejs.org/dist/v22.12.0/node-v22.12.0-x64.msi"
    
    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFileTaskAsync("https://nodejs.org/dist/v22.12.0/node-v22.12.0-x64.msi", $msi).Wait()
        Write-Host "下载完成" -ForegroundColor Green
    } catch {
        Write-Host "使用备用方式下载..."
        Invoke-WebRequest -Uri "https://nodejs.org/dist/v22.12.0/node-v22.12.0-x64.msi" -OutFile $msi -UseBasicParsing
        Write-Host "下载完成" -ForegroundColor Green
    }
    
    Write-Host "安装中 (可能需要几分钟，请耐心等待)..." -ForegroundColor Cyan
    
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "msiexec.exe"
    $psi.Arguments = "/i `"$msi`" /quiet /qn /norestart"
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    
    $process = [System.Diagnostics.Process]::Start($psi)
    $process.WaitForExit()
    
    Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
    
    Write-Host ""
    Write-Host "=========================================="
    if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
        Write-Host "Node.js 安装完成！" -ForegroundColor Green
    } else {
        Write-Host "安装可能未成功，ExitCode: $($process.ExitCode)" -ForegroundColor Yellow
    }
    Write-Host "=========================================="
    Write-Host ""
    Write-Host "请重新打开一个 PowerShell 窗口，然后再次运行以下命令：" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "irm https://gitee.com/yangyusheng2n/install-openclaw/raw/master/install-openclaw.ps1 | iex"
    Write-Host ""
    Read-Host "按回车键退出"
    exit 0
}

function Install-OpenCLAW {
    Write-Host ""
    Write-Host "正在安装 OpenCLAW (可能需要几分钟)..." -ForegroundColor Cyan
    
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        Write-Host "清理 npm 缓存..."
        npm cache clean --force 2>$null
        
        Write-Host "安装 openclaw..."
        npm install -g openclaw 2>$null
        Write-Host "OpenCLAW 安装完成" -ForegroundColor Green
        
        Add-NpmPath
        
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
    } else {
        Write-Host "npm 未找到，请先安装 Node.js" -ForegroundColor Red
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
