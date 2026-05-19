<#
.SYNOPSIS
    Apply or restore Antigravity 2.0 Chinese localization.
.PARAMETER Restore
    Restore the original English version.
.EXAMPLE
    .\apply.ps1
    .\apply.ps1 -Restore
#>
[CmdletBinding()]
param(
    [switch]$Restore,
    [string]$AntigravityPath = "$env:LOCALAPPDATA\Programs\Antigravity"
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot

Write-Host "=== Antigravity 2.0 Chinese Localization Tool ===" -ForegroundColor Cyan

# Verify path
$appOut = "$AntigravityPath\resources\app\out"
if (-not (Test-Path "$appOut\nls.messages.json")) {
    Write-Error "Antigravity installation not found at: $AntigravityPath"
    exit 1
}

if ($Restore) {
    Write-Host "`n[Restore] Restoring original English files..." -ForegroundColor Yellow

    # 1. Restore app.asar
    $asarPath = "$AntigravityPath\resources\app.asar"
    if (Test-Path "$asarPath.bak") {
        Copy-Item "$asarPath.bak" $asarPath -Force
        Write-Host "  Restored app.asar" -ForegroundColor Green
    }

    # 2. Restore nls.messages.json
    $backupFile = "$appOut\nls.messages.json.bak"
    if (Test-Path $backupFile) {
        Copy-Item $backupFile "$appOut\nls.messages.json" -Force
        Write-Host "  Restored nls.messages.json" -ForegroundColor Green
    }

    # 3. Restore product.json
    $productBak = "$AntigravityPath\resources\app\product.json.bak"
    if (Test-Path $productBak) {
        Copy-Item $productBak "$AntigravityPath\resources\app\product.json" -Force
        Write-Host "  Restored product.json" -ForegroundColor Green
    }

    # 4. Restore extensions
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
            Write-Host "  Restored $ext/package.json" -ForegroundColor Green
        }
    }

    # 5. Clean up translated UI file from UserData
    $appDataPath = "$env:APPDATA\Antigravity"
    $translatedUiFile = Join-Path $appDataPath "zh_cn_ui_main.js"
    if (Test-Path $translatedUiFile) {
        Remove-Item $translatedUiFile -Force
        Write-Host "  Cleaned up translated UI main bundle" -ForegroundColor Green
    }

    Write-Host "`nRestore complete! Please restart Antigravity." -ForegroundColor Cyan
} else {
    Write-Host "`n[Install] Applying Chinese localization..." -ForegroundColor Yellow

    # Check process occupation
    $processes = Get-Process -Name "Antigravity" -ErrorAction SilentlyContinue
    if ($processes) {
        Write-Warning "Antigravity is currently running! Please close it first."
        $choice = Read-Host "Kill running processes now? (y/N)"
        if ($choice -eq "y" -or $choice -eq "Y") {
            Stop-Process -Name "Antigravity" -Force
            Start-Sleep -Seconds 2
            Write-Host "  Stopped Antigravity processes." -ForegroundColor Green
        } else {
            Write-Host "Please close the application and run this script again." -ForegroundColor Yellow
            exit 0
        }
    }

    # 1. Run python UI translation script to generate zh_cn_ui_main.js
    Write-Host "  Generating UI translation resources..." -ForegroundColor White
    python "$ProjectRoot\scripts\translate_ui.py"

    # 2. Back up and repack app.asar
    $asarPath = "$AntigravityPath\resources\app.asar"
    $extractedPath = "$AntigravityPath\resources\extracted_asar"
    if (Test-Path $extractedPath) {
        if (-not (Test-Path "$asarPath.bak")) {
            Copy-Item $asarPath "$asarPath.bak" -Force
            Write-Host "  Created backup of original app.asar" -ForegroundColor Green
        }
        Write-Host "  Repacking app.asar (including interception & window localization)..." -ForegroundColor White
        npx asar pack $extractedPath $asarPath
        Write-Host "  Repacked app.asar successfully" -ForegroundColor Green
    } else {
        Write-Error "Unpacked directory not found: $extractedPath"
        exit 1
    }

    # 3. Apply NLS translations to VS Code core
    Write-Host "  Applying VS Code core NLS translations..." -ForegroundColor White
    if (-not (Test-Path "$appOut\nls.messages.json.bak")) {
        Copy-Item "$appOut\nls.messages.json" "$appOut\nls.messages.json.bak" -Force
    }
    $translationFile = Join-Path $ProjectRoot "translations\nls.messages.zh-CN.json"
    if (Test-Path $translationFile) {
        Copy-Item $translationFile "$appOut\nls.messages.json" -Force
        Write-Host "  Applied NLS translations" -ForegroundColor Green
    }

    # 4. Apply product.json translations
    Write-Host "  Applying product.json translations..." -ForegroundColor White
    if (-not (Test-Path "$AntigravityPath\resources\app\product.json.bak")) {
        Copy-Item "$AntigravityPath\resources\app\product.json" "$AntigravityPath\resources\app\product.json.bak" -Force
    }
    $productTrans = Join-Path $ProjectRoot "translations\product.json"
    if (Test-Path $productTrans) {
        Copy-Item $productTrans "$AntigravityPath\resources\app\product.json" -Force
        Write-Host "  Applied product.json translations" -ForegroundColor Green
    }

    # 5. Apply extensions translations
    Write-Host "  Applying extension translations..." -ForegroundColor White
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
            $extPkgTrans = Join-Path $ProjectRoot "translations\extensions\$ext\package.json"
            if (Test-Path $extPkgTrans) {
                Copy-Item $extPkgTrans "$extPath\package.json" -Force
                Write-Host "  Applied $ext/package.json translations" -ForegroundColor Green
            }
        }
    }

    Write-Host "`nLocalization applied successfully! Please restart Antigravity manually." -ForegroundColor Cyan
}
