param(
    [string]$ApiBaseUrl = "https://nutrimon-backend-production.up.railway.app",
    [string]$UpdateSiteUrl = "https://nutrimon-frontend.vercel.app",
    [string]$ReleaseMessage = "Now called NutriFit. Same app, new name."
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$flutter = "C:\Users\anubh\Flutter\flutter\bin\flutter.bat"
if (-not (Test-Path $flutter)) {
    $flutter = "flutter"
}

$pubspec = Get-Content (Join-Path $root "pubspec.yaml") -Raw
if ($pubspec -match 'version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)') {
    $version_name = $Matches[1]
    $build_number = [int]$Matches[2]
} else {
    throw "Could not read version from pubspec.yaml"
}

$version_json = @{
    latest_version = $version_name
    build_number = $build_number
    apk_url = "downloads/nutrimorning.apk"
    message = $ReleaseMessage
    force_update = $false
} | ConvertTo-Json

$version_path = Join-Path $root "website\version.json"
Set-Content -Path $version_path -Value $version_json -Encoding utf8

Write-Host "Building release APK..."
Write-Host "API: $ApiBaseUrl"
Write-Host "Version: $version_name+$build_number"
Write-Host "Update check: $UpdateSiteUrl/version.json"
Write-Host ""

& $flutter build apk --release `
    --dart-define="API_BASE_URL=$ApiBaseUrl" `
    --dart-define="UPDATE_CHECK_URL=$UpdateSiteUrl/version.json"

if ($LASTEXITCODE -ne 0) {
    throw "Flutter APK build failed with exit code $LASTEXITCODE"
}

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
Write-Host "  version.json: $version_path"
Write-Host ""
Write-Host "Before releasing a new version:"
Write-Host "  1. Bump version in pubspec.yaml (e.g. 1.0.1+2)"
Write-Host "  2. Run this script again"
Write-Host "  3. Push to GitHub so Vercel serves the new APK + version.json"
