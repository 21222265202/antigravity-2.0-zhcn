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

# 提示手动重启
Write-Host "提示: 汉化文件将在复制后生效，请在安装完毕后手动重启 Antigravity。" -ForegroundColor Yellow


if ($Restore) {
    # 恢复模式
    Write-Host "`n[恢复] 恢复英文原版..." -ForegroundColor Yellow

    # 1. 恢复 nls.messages.json
    $backupFile = "$appOut\nls.messages.json.bak"
    if (Test-Path $backupFile) {
        Copy-Item $backupFile "$appOut\nls.messages.json" -Force
        Write-Host "  已恢复 nls.messages.json" -ForegroundColor Green
    } else {
        Write-Error "未找到备份文件: $backupFile"
        exit 1
    }

    # 2. 恢复 jetskiAgent 补丁
    $jetskiBak = "$appOut\jetskiAgent\main.js.bak"
    if (Test-Path $jetskiBak) {
        Copy-Item $jetskiBak "$appOut\jetskiAgent\main.js" -Force
        Write-Host "  已恢复 jetskiAgent/main.js" -ForegroundColor Green
    }

    # 3. 恢复 product.json
    $productBak = "$AntigravityPath\resources\app\product.json.bak"
    if (Test-Path $productBak) {
        Copy-Item $productBak "$AntigravityPath\resources\app\product.json" -Force
        Write-Host "  已恢复 product.json" -ForegroundColor Green
    }

    # 4. 恢复 5 个扩展的 package.json
    $extDir = "$AntigravityPath\resources\app\extensions"
    $agyExtensions = @(
        "antigravity",
        "antigravity-code-executor",
        "antigravity-dev-containers",
        "antigravity-remote-openssh",
        "antigravity-remote-wsl"
    )
    foreach ($ext in $agyExtensions) {
        $extPkgBak = "$extDir\$ext\package.json.bak"
        if (Test-Path $extPkgBak) {
            Copy-Item $extPkgBak "$extDir\$ext\package.json" -Force
            Write-Host "  已恢复 $ext/package.json" -ForegroundColor Green
        }
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
    if (-not (Test-Path "$AntigravityPath\resources\app\product.json.bak")) {
        Copy-Item "$AntigravityPath\resources\app\product.json" "$AntigravityPath\resources\app\product.json.bak" -Force
    }

    # 备份 5 个扩展的 package.json
    $extDir = "$AntigravityPath\resources\app\extensions"
    $agyExtensions = @(
        "antigravity",
        "antigravity-code-executor",
        "antigravity-dev-containers",
        "antigravity-remote-openssh",
        "antigravity-remote-wsl"
    )
    foreach ($ext in $agyExtensions) {
        $extPath = "$extDir\$ext"
        if (Test-Path $extPath) {
            if (-not (Test-Path "$extPath\package.json.bak")) {
                Copy-Item "$extPath\package.json" "$extPath\package.json.bak" -Force
            }
        }
    }

    # 1. 应用 NLS 翻译
    $translationFile = Join-Path $ProjectRoot "translations\nls.messages.zh-CN.json"
    if (Test-Path $translationFile) {
        Copy-Item $translationFile "$appOut\nls.messages.json" -Force
        Write-Host "  已应用 NLS 翻译 (nls.messages.json)" -ForegroundColor Green
    } else {
        Write-Warning "NLS 翻译文件不存在: $translationFile"
    }

    # 2. 应用 jetskiAgent 补丁
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

    # 3. 应用 product.json 翻译
    $productTrans = Join-Path $ProjectRoot "translations\product.json"
    if (Test-Path $productTrans) {
        Copy-Item $productTrans "$AntigravityPath\resources\app\product.json" -Force
        Write-Host "  已应用 product.json 翻译" -ForegroundColor Green
    }

    # 4. 应用 5 个扩展的 package.json 翻译
    foreach ($ext in $agyExtensions) {
        $extPkgTrans = Join-Path $ProjectRoot "translations\extensions\$ext\package.json"
        $extPkgDest = "$extDir\$ext\package.json"
        if (Test-Path $extPkgTrans) {
            Copy-Item $extPkgTrans $extPkgDest -Force
            Write-Host "  已应用 $ext/package.json 翻译" -ForegroundColor Green
        }
    }

    Write-Host "`n汉化安装完成！请重启 Antigravity。" -ForegroundColor Cyan
}
