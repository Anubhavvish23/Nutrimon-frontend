param(
    [string]$ApiBaseUrl = "https://nutrimon-backend-production.up.railway.app"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$flutter = "C:\Users\anubh\Flutter\flutter\bin\flutter.bat"
if (-not (Test-Path $flutter)) {
    $flutter = "flutter"
}

Write-Host "Building release APK..."
Write-Host "API: $ApiBaseUrl"
Write-Host ""

& $flutter build apk --release `
    --dart-define="API_BASE_URL=$ApiBaseUrl"

$apk_source = Join-Path $root "build\app\outputs\flutter-apk\app-release.apk"
$downloads_dir = Join-Path $root "website\downloads"
$apk_dest = Join-Path $downloads_dir "nutrimorning.apk"

if (-not (Test-Path $apk_source)) {
    throw "APK not found at $apk_source"
}

New-Item -ItemType Directory -Force -Path $downloads_dir | Out-Null
Copy-Item -Path $apk_source -Destination $apk_dest -Force

$size_mb = [math]::Round((Get-Item $apk_dest).Length / 1MB, 1)

Write-Host ""
Write-Host "Done!"
Write-Host "  APK: $apk_dest"
Write-Host "  Size: ${size_mb} MB"
Write-Host ""
Write-Host "Website folder: $root\website"
Write-Host "  Open index.html locally or deploy to Firebase / GitHub Pages / Railway"
Write-Host ""
Write-Host "Quick test: open website\index.html in browser and tap Download"
