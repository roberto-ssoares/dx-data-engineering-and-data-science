# 20-shell.ps1  Aliases, git shortcuts, dotenv loader e prompt

# QoL aliases
Set-Alias ll Get-ChildItem
function la { Get-ChildItem -Force }
Set-Alias cls Clear-Host

# Git shortcuts (if available)
if (Get-Command git -ErrorAction SilentlyContinue) {
    function gs  { git status }
    function gl  { git log --oneline --graph --decorate -5 }
    function gp  { git pull }
    function gph { git push }
}

# .env safe loader (does NOT overwrite existing env vars)
function Load-DotEnv {
    param([string]$Path = ".\.env")

    if (-not (Test-Path $Path)) { return }

    Get-Content $Path | ForEach-Object {
        $line = $_.Trim()
        if (-not $line) { return }
        if ($line.StartsWith("#")) { return }

        if ($line -notmatch "^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)\s*$") { return }

        $key = $Matches[1]
        $val = $Matches[2].Trim()

        # Strip surrounding quotes
        if (($val.StartsWith('"') -and $val.EndsWith('"')) -or ($val.StartsWith("'") -and $val.EndsWith("'"))) {
            $val = $val.Substring(1, $val.Length - 2)
        }

        if (-not (Test-Path "Env:$key")) {
            Set-Item -Path "Env:$key" -Value $val
        }
    }
}

# Prompt: user + venv + git branch + cwd
function prompt {
    $cwd = (Get-Location).Path

    $venv = ""
    if ($env:VIRTUAL_ENV) {
        $venv = Split-Path $env:VIRTUAL_ENV -Leaf
    }

    $gitInfo = ""
    if (Get-Command git -ErrorAction SilentlyContinue) {
        try {
            $branch = git rev-parse --abbrev-ref HEAD 2>$null
            if ($LASTEXITCODE -eq 0 -and $branch) {
                $gitInfo = " ($branch)"
            }
        } catch {}
    }

    Write-Host "[$env:USERNAME@DataShell]" -ForegroundColor Cyan -NoNewline
    if ($venv)    { Write-Host " {$venv}" -ForegroundColor Yellow   -NoNewline }
    if ($gitInfo) { Write-Host $gitInfo   -ForegroundColor DarkGray -NoNewline }
    Write-Host " $cwd" -ForegroundColor Green
    return "`n> "
}
