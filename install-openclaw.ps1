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
        Write-Host "Git 已安装" -ForegroundColor Green
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
        
        Write-Host "winget 安装的 Git 可能需要手动添加到 PATH" -ForegroundColor Yellow
    }
    
    Write-Host "尝试使用 chocolatey 安装 Git..." -ForegroundColor Yellow
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        choco install git -y
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        Start-Sleep -Seconds 3
        if (Test-Git) {
            Write-Host "Git 安装成功！" -ForegroundColor Green
            return $true
        }
    }
    
    Write-Host "正在下载 Git for Windows..." -ForegroundColor Yellow
    
    $tmp = "$env:TEMP\git_$PID"
    New-Item -ItemType Directory -Force -Path $tmp | Out-Null
    $installer = "$tmp\Git-Setup.exe"
    
    $arch = $env:PROCESSOR_ARCHITECTURE
    if ($arch -eq "ARM64") {
        $downloadUrls = @(
            "https://ghproxy.com/https://github.com/git-for-windows/git/releases/download/v2.53.0.windows.2/Git-2.53.0.2-arm64.exe",
            "https://mirror.ghproxy.com/https://github.com/git-for-windows/git/releases/download/v2.53.0.windows.2/Git-2.53.0.2-arm64.exe",
            "https://github.com/git-for-windows/git/releases/download/v2.53.0.windows.2/Git-2.53.0.2-arm64.exe"
        )
    } else {
        $downloadUrls = @(
            "https://ghproxy.com/https://github.com/git-for-windows/git/releases/download/v2.53.0.windows.2/Git-2.53.0.2-64-bit.exe",
            "https://mirror.ghproxy.com/https://github.com/git-for-windows/git/releases/download/v2.53.0.windows.2/Git-2.53.0.2-64-bit.exe",
            "https://github.com/git-for-windows/git/releases/download/v2.53.0.windows.2/Git-2.53.0.2-64-bit.exe"
        )
    }
    
    $downloaded = $false
    foreach ($url in $downloadUrls) {
        try {
            Write-Host "下载: $url"
            Invoke-WebRequest -Uri $url -OutFile $installer -UseBasicParsing -TimeoutSec 180
            if ((Test-Path $installer) -and (Get-Item $installer).Length -gt 1000000) {
                $downloaded = $true
                Write-Host "下载完成" -ForegroundColor Green
                break
            }
        } catch {
            Write-Host "下载失败: $_"
        }
    }
    
    if (-not $downloaded) {
        Write-Host "自动下载失败，请手动下载安装" -ForegroundColor Red
        Write-Host "下载地址：https://git-scm.com/download/win" -ForegroundColor Yellow
        Write-Host "或者使用：winget install Git.Git" -ForegroundColor Yellow
        Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
        Read-Host "按回车键退出"
        exit 1
    }
    
    Write-Host "安装中 (可能需要几分钟)..."
    Start-Process $installer -ArgumentList "/VERYSILENT /NORESTART /NOCANCEL /SP-" -Wait
    Remove-Item $tmp -Recurse -Force
    
    Write-Host "Git 安装完成，刷新环境变量..." -ForegroundColor Green
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    Start-Sleep -Seconds 2
    
    if (Test-Git) {
        Write-Host "Git 验证成功！" -ForegroundColor Green
        return $true
    }
    
    return $false
}
    
    if (Test-Git) {
        return $true
    }
    
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
        npm cache clean --force
        
        Write-Host "安装 openclaw..."
        Write-Host "------------------------------------------"
        
        $npmPrefix = npm config get prefix
        $env:Path = "$npmPrefix;$env:Path"
        
        npm install -g openclaw
        
        Write-Host "------------------------------------------"
        
        $installed = npm list -g openclaw 2>$null
        if ($installed -like "*openclaw*") {
            Write-Host "OpenCLAW 安装成功" -ForegroundColor Green
        } else {
            Write-Host "安装可能未成功，显示安装结果：" -ForegroundColor Yellow
            npm list -g openclaw
        }
        
        Add-NpmPath
        
        Write-Host ""
        Write-Host "正在验证 openclaw 命令..."
        
        $openclawCmd = Get-Command openclaw -ErrorAction SilentlyContinue
        if ($openclawCmd) {
            Write-Host "openclaw 命令可用" -ForegroundColor Green
        } else {
            Write-Host "openclaw 命令暂不可用，请重新打开 PowerShell 后使用" -ForegroundColor Yellow
        }
        
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

# 刷新环境变量
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# 检查 Git 是否安装
if (-not (Test-Git)) {
    Write-Host "检测到 Git 未安装，OpenCLAW 安装需要 Git，正在自动安装..." -ForegroundColor Yellow
    Install-Git
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    Start-Sleep -Seconds 2
    if (-not (Test-Git)) {
        Write-Host "Git 安装失败，请手动下载：https://git-scm.com/download/win" -ForegroundColor Red
        Read-Host "按回车键退出"
        exit 1
    }
}

if (-not (Test-Node)) {
    Install-Node
}

if (Test-Node) {
    # 刷新环境变量，确保 Git 可用
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    Install-OpenCLAW
}
