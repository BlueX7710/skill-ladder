# Builds the app (build-app.ps1 -> source/app) and copies it to the repository root,
# which GitHub Pages serves at https://bluex7710.github.io/skill-ladder/
# Run from anywhere:  powershell -ExecutionPolicy Bypass -File source/build-github.ps1
# Then commit and push the repository.
$ErrorActionPreference = "Stop"
$src = $PSScriptRoot
$site = Split-Path $src -Parent
& powershell -ExecutionPolicy Bypass -File (Join-Path $src "build-app.ps1")
Get-ChildItem (Join-Path $src "app") -File | Where-Object { $_.Name -ne "netlify.toml" } | Copy-Item -Destination $site -Force
# serve files as-is (no Jekyll processing)
if (-not (Test-Path (Join-Path $site ".nojekyll"))) { New-Item -ItemType File (Join-Path $site ".nojekyll") | Out-Null }
"Built the site into $site"
