<#
.SYNOPSIS
    应用或恢复 Antigravity 2.0 中文汉化。

.PARAMETER Restore
    恢复为英文原版。

.EXAMPLE
    .\apply.ps1           # 应用汉化
    .\apply.ps1 -Restore  # 恢复英文
#>
[CmdletBinding()]
param(
    [switch]$Restore,
    [string]$AntigravityPath = "$env:LOCALAPPDATA\Programs\Antigravity"
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot

Write-Host "=== Antigravity 2.0 汉化安装工具 ===" -ForegroundColor Cyan

# 检测安装
$appOut = "$AntigravityPath\resources\app\out"
if (-not (Test-Path "$appOut\nls.messages.json")) {
    Write-Error "未找到 Antigravity NLS 文件: $appOut"
    exit 1
}

# 检查进程
$running = Get-Process -Name "Antigravity" -ErrorAction SilentlyContinue
if ($running) {
    Write-Warning "Antigravity 正在运行，请先关闭后再操作。"
    $choice = Read-Host "是否强制关闭? (y/N)"
    if ($choice -eq "y") {
        $running | Stop-Process -Force
        Start-Sleep -Seconds 2
    } else {
        exit 0
    }
}

if ($Restore) {
    # 恢复模式
    Write-Host "`n[恢复] 恢复英文原版..." -ForegroundColor Yellow

    $backupFile = "$appOut\nls.messages.json.bak"
    if (Test-Path $backupFile) {
        Copy-Item $backupFile "$appOut\nls.messages.json" -Force
        Write-Host "  已恢复 nls.messages.json" -ForegroundColor Green
    } else {
        Write-Error "未找到备份文件: $backupFile"
        exit 1
    }

    # 恢复 jetskiAgent 补丁
    $jetskiBak = "$appOut\jetskiAgent\main.js.bak"
    if (Test-Path $jetskiBak) {
        Copy-Item $jetskiBak "$appOut\jetskiAgent\main.js" -Force
        Write-Host "  已恢复 jetskiAgent/main.js" -ForegroundColor Green
    }

    Write-Host "`n恢复完成！请重启 Antigravity。" -ForegroundColor Cyan
} else {
    # 汉化模式
    Write-Host "`n[安装] 应用中文汉化..." -ForegroundColor Yellow

    # 版本检查
    $versionFile = Join-Path $ProjectRoot "version.json"
    $version = Get-Content $versionFile -Raw | ConvertFrom-Json
    $pkgJson = Get-Content "$AntigravityPath\resources\app\package.json" -Raw | ConvertFrom-Json
    if ($pkgJson.version -ne $version.internalVersion) {
        Write-Warning "版本不匹配! 汉化包: $($version.internalVersion), 当前: $($pkgJson.version)"
        $choice = Read-Host "继续安装? (y/N)"
        if ($choice -ne "y") { exit 0 }
    }

    # 备份原始文件
    Write-Host "  备份原始文件..." -ForegroundColor White
    if (-not (Test-Path "$appOut\nls.messages.json.bak")) {
        Copy-Item "$appOut\nls.messages.json" "$appOut\nls.messages.json.bak" -Force
    }
    if (-not (Test-Path "$appOut\jetskiAgent\main.js.bak")) {
        Copy-Item "$appOut\jetskiAgent\main.js" "$appOut\jetskiAgent\main.js.bak" -Force
    }

    # 应用 NLS 翻译
    $translationFile = Join-Path $ProjectRoot "translations\nls.messages.zh-CN.json"
    if (Test-Path $translationFile) {
        Copy-Item $translationFile "$appOut\nls.messages.json" -Force
        Write-Host "  已应用 NLS 翻译 (nls.messages.json)" -ForegroundColor Green
    } else {
        Write-Warning "NLS 翻译文件不存在: $translationFile"
    }

    # 应用 jetskiAgent 补丁
    $jetskiPatch = Join-Path $ProjectRoot "patches\jetskiAgent.patch.js"
    if (Test-Path $jetskiPatch) {
        # 读取补丁脚本执行替换
        $jetskiContent = Get-Content "$appOut\jetskiAgent\main.js" -Raw -Encoding UTF8
        $patchData = Get-Content $jetskiPatch -Raw -Encoding UTF8 | ConvertFrom-Json
        foreach ($patch in $patchData) {
            $jetskiContent = $jetskiContent.Replace($patch.original, $patch.translated)
        }
        [System.IO.File]::WriteAllText("$appOut\jetskiAgent\main.js", $jetskiContent, [System.Text.Encoding]::UTF8)
        Write-Host "  已应用 jetskiAgent 补丁" -ForegroundColor Green
    }

    Write-Host "`n汉化安装完成！请重启 Antigravity。" -ForegroundColor Cyan
}
