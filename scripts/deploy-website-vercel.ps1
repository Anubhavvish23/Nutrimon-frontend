param(
    [string]$ApiBaseUrl = "https://nutrimon-backend-production.up.railway.app"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$apk = Join-Path $root "website\downloads\nutrimorning.apk"
if (-not (Test-Path $apk)) {
    Write-Host "APK missing — building first..."
    & (Join-Path $PSScriptRoot "build-release-apk.ps1") -ApiBaseUrl $ApiBaseUrl
}

if (-not (Get-Command vercel -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Vercel CLI..."
    npm install -g vercel
}

Write-Host "Deploying website to Vercel..."
vercel --prod

Write-Host ""
Write-Host "Done. Share the URL Vercel prints above."
