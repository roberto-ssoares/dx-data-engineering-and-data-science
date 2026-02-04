# 10-welcome.ps1 — One-time welcome (apenas 1x por sessão)

if (-not $global:ProfileLoadedOnce) {
    $global:ProfileLoadedOnce = $true
    Write-Host "PowerShell 7 pronto para Data Engineering & Data Science 🚀" -ForegroundColor Magenta
}
