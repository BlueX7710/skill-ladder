# Builds the installable Android web app in ./app from the same source as the Claude artifact.
#   skill-ladder.html      the app itself (shared with the artifact)
#   app-src/               manifest, offline worker, app shell (install button + update notice)
# Run:  powershell -ExecutionPolicy Bypass -File build-app.ps1
$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$out = Join-Path $root "app"
New-Item -ItemType Directory -Force $out | Out-Null

$body = [IO.File]::ReadAllText((Join-Path $root "skill-ladder.html"))
$shell = [IO.File]::ReadAllText((Join-Path $root "app-src\app-shell.html"))
$version = (Get-Date).ToUniversalTime().ToString("yyyyMMddHHmmss")

$head = @"
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<meta name="app-version" content="$version">
<meta name="theme-color" content="#15232A">
<meta name="description" content="Calisthenics skill tree with guided workouts and progress tracking.">
<meta name="mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
<link rel="manifest" href="manifest.webmanifest">
<link rel="icon" type="image/png" href="icon-192.png">
<link rel="apple-touch-icon" href="icon-192.png">
<style>:root{color-scheme:light;padding-top:env(safe-area-inset-top);padding-bottom:env(safe-area-inset-bottom)}body{margin:0;font:14px/1.4 system-ui,-apple-system,"Segoe UI",sans-serif}img{max-width:100%}[hidden]{display:none!important}</style>
</head>
<body>
"@

$html = $head + $body + "`n" + $shell + "`n</body>`n</html>`n"
[IO.File]::WriteAllText((Join-Path $out "index.html"), $html, (New-Object Text.UTF8Encoding $false))
foreach ($f in "manifest.webmanifest", "sw.js", "netlify.toml") { Copy-Item (Join-Path $root "app-src\$f") (Join-Path $out $f) -Force }
Get-ChildItem (Join-Path $root "app-src") -Filter "icon-*.png" | Copy-Item -Destination $out -Force
"Built app/ version $version"
