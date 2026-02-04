# 00-env.ps1  Console/encoding + globals básicos
$Host.UI.RawUI.WindowTitle = "PowerShell 7 | Data & Engineering"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

if (-not (Get-Variable AutoVenvEnabled -Scope Global -ErrorAction SilentlyContinue)) {
    $global:AutoVenvEnabled = $true
}

if (-not (Get-Variable AutoVenv_ActiveProjectRoot -Scope Global -ErrorAction SilentlyContinue)) {
    $global:AutoVenv_ActiveProjectRoot = $null
}

if (-not (Get-Variable ProjectRoots -Scope Global -ErrorAction SilentlyContinue)) {
    $global:ProjectRoots = @("D:\_DE-Projects", "D:\_DS-Projects")
}

if (-not (Get-Variable LeaveHome -Scope Global -ErrorAction SilentlyContinue)) {
    $global:LeaveHome = "D:\"
}
