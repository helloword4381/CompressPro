#!/usr/bin/env pwsh
<#
.SYNOPSIS
    CompressPro Build Script — Self-contained edition
.DESCRIPTION
    Auto-downloads 7z.dll + builds Release
#>

$ErrorActionPreference = "Stop"
$OutputDir = "src\CompressPro.Gui\bin\Release\net8.0-windows"

Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║    CompressPro Build — 集成版            ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Step 0: Download 7z.dll
Write-Host "[0/4] Checking 7z.dll..." -ForegroundColor Yellow
& "$PSScriptRoot\external\download_7z_dll.bat"
if ($LASTEXITCODE -ne 0) { throw "7z.dll download failed" }
Write-Host "[✓] 7z.dll ready" -ForegroundColor Green

# Step 1: Check .NET SDK
try {
    $dotnetVersion = dotnet --version
    Write-Host "[✓] .NET SDK $dotnetVersion" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] .NET SDK not found" -ForegroundColor Red
    exit 1
}

# Step 2: Restore
Write-Host "[2/4] Restoring packages..." -ForegroundColor Yellow
dotnet restore
if ($LASTEXITCODE -ne 0) { throw "Restore failed" }
Write-Host "[✓] Restore complete" -ForegroundColor Green

# Step 3: Build
Write-Host "[3/4] Building Release..." -ForegroundColor Yellow
dotnet build -c Release --no-restore
if ($LASTEXITCODE -ne 0) { throw "Build failed" }
Write-Host "[✓] Build complete" -ForegroundColor Green

# Step 4: Copy 7z.dll
Write-Host "[4/4] Copying runtime deps..." -ForegroundColor Yellow
if (Test-Path "external\7z.dll") {
    Copy-Item "external\7z.dll" "$OutputDir\" -Force
    Write-Host "[✓] 7z.dll copied" -ForegroundColor Green
}
if (Test-Path "external\7z.exe") {
    Copy-Item "external\7z.exe" "$OutputDir\" -Force
    Write-Host "[✓] 7z.exe copied" -ForegroundColor Green
}

Write-Host ""
Write-Host "══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host " ✓ Build successful!" -ForegroundColor Green
Write-Host "   Output: $OutputDir" -ForegroundColor White
Write-Host "══════════════════════════════════════════" -ForegroundColor Cyan
