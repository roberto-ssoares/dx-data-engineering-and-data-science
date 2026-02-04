# 70-bootstrap.ps1 — bootstrap new Python projects (uv + ruff + pre-commit + VS Code)
# Repo-local (no global git changes). Safe with a modular $PROFILE loader.

function _Code-Available {
    return [bool](Get-Command code -ErrorAction SilentlyContinue)
}

function _Normalize-BasePath {
    param([Parameter(Mandatory=$true)][string]$BasePath)

    # Fix "D:_DS-Projects" -> "D:\_DS-Projects"
    if ($BasePath -match '^[A-Za-z]:(?!\\)') {
        $BasePath = $BasePath -replace '^([A-Za-z]):', '${1}:\'
    }

    return $BasePath
}

function _Set-RepoGitEOLConfig {
    # Repo-local only (won't touch global git config)
    try {
        git config core.autocrlf false | Out-Null
        git config core.eol lf       | Out-Null
        git config core.safecrlf warn | Out-Null
    } catch {
        Write-Host "Aviso: não consegui ajustar git config (repo-local)." -ForegroundColor Yellow
    }
}

function _Write-GitAttributes-Gold {
    # Minimize LF/CRLF warnings; keep .ps1 as CRLF
    $lines = @(
        "# Auto-normalize text to LF in repo",
        "* text=auto eol=lf",
        "",
        "# Keep PowerShell scripts as CRLF on Windows",
        "*.ps1 text eol=crlf"
    )
    $lines | Set-Content -Encoding UTF8 ".gitattributes"
}

function _Write-EditorConfig {
    $lines = @(
        "root = true",
        "",
        "[*]",
        "charset = utf-8",
        "end_of_line = lf",
        "insert_final_newline = true",
        "trim_trailing_whitespace = true",
        "",
        "[*.ps1]",
        "end_of_line = crlf"
    )
    $lines | Set-Content -Encoding UTF8 ".editorconfig"
}

function _Write-PreCommitConfig_Bootstrap {
    if (Test-Path ".\.pre-commit-config.yaml") { return }

    $lines = @(
        "repos:",
        "  - repo: https://github.com/astral-sh/ruff-pre-commit",
        "    rev: v0.6.9",
        "    hooks:",
        "      - id: ruff",
        "        args: [--fix]",
        "      - id: ruff-format"
    )
    $lines | Set-Content -Encoding UTF8 ".pre-commit-config.yaml"
}

function _Bootstrap-Project {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][string]$BasePath,
        [Parameter(Mandatory=$true)][ValidateSet("de","ds")][string]$Kind,
        [string]$Python = "3.11",
        [switch]$OpenVSCode
    )

    if ($Name -match '[\\/:*?"<>|]') { Write-Host "Nome inválido." -ForegroundColor Red; return }
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) { Write-Host "git não encontrado." -ForegroundColor Red; return }
    if (-not (Get-Command uv -ErrorAction SilentlyContinue))  { Write-Host "uv não encontrado."  -ForegroundColor Red; return }

    $BasePath = _Normalize-BasePath -BasePath $BasePath
    if (-not (Test-Path $BasePath)) { New-Item -ItemType Directory -Path $BasePath -Force | Out-Null }

    $projectPath = Join-Path $BasePath $Name

    if (Test-Path $projectPath) {
        Write-Host "Já existe: $projectPath" -ForegroundColor Yellow
        Microsoft.PowerShell.Management\Set-Location $projectPath
        return
    }

    New-Item -ItemType Directory -Path $projectPath | Out-Null
    Microsoft.PowerShell.Management\Set-Location $projectPath

    # Skeleton
    "src","tests","notebooks","docs","artifacts","data\raw","data\processed",".vscode" | ForEach-Object {
        New-Item -ItemType Directory -Path $_ -Force | Out-Null
    }

    # ----------------------------
    # Init git first (so pre-commit hooks can install)
    # ----------------------------
    git init | Out-Null
    _Set-RepoGitEOLConfig
    _Write-GitAttributes-Gold
    _Write-EditorConfig

    # ----------------------------
    # Base files from other modules (if present)
    # ----------------------------
    if (Get-Command _Write-GitIgnore -ErrorAction SilentlyContinue)  { _Write-GitIgnore }
    if (Get-Command _Write-EnvExample -ErrorAction SilentlyContinue) { _Write-EnvExample }
    if (Get-Command _Write-RuffToml -ErrorAction SilentlyContinue) { _Write-RuffToml -Python $Python }
    if (Get-Command _Write-PreCommitConfig -ErrorAction SilentlyContinue) { _Write-PreCommitConfig }

    _Write-PreCommitConfig_Bootstrap

    # README
    if ($Kind -eq "de") {
        if (Get-Command _Write-README-DE -ErrorAction SilentlyContinue) { _Write-README-DE -Name $Name -Python $Python }
    } else {
        if (Get-Command _Write-README-DS -ErrorAction SilentlyContinue) { _Write-README-DS -Name $Name -Python $Python }
    }

    # VSCode tasks/settings
    if (Get-Command _Write-VSCode-Files -ErrorAction SilentlyContinue) {
        _Write-VSCode-Files -Kind $Kind
    }

    # ----------------------------
    # uv init / venv / deps
    # ----------------------------
    if (-not (Test-Path ".\pyproject.toml")) {
        uv init | Out-Null
    }

    # Align requires-python to >=$Python (avoid uv defaulting to >=3.13)
    try {
        $pp = Get-Content ".\pyproject.toml" -Raw
        if ($pp -match 'requires-python\s*=') {
            $pp = $pp -replace 'requires-python\s*=\s*".*?"', "requires-python = `">=$Python`""
        }
        Set-Content -Encoding UTF8 ".\pyproject.toml" -Value $pp
    } catch {
        Write-Host "Aviso: não consegui ajustar requires-python no pyproject.toml" -ForegroundColor Yellow
    }

    # Avoid uv hardlink warning (common when cache/target on different disks) only during bootstrap
    $prevLinkMode = $env:UV_LINK_MODE
    $env:UV_LINK_MODE = "copy"

    try {
        uv venv --python $Python | Out-Null

        if ($Kind -eq "de") {
            uv add duckdb polars pandas pyarrow ipykernel ruff pre-commit pytest | Out-Null
        } else {
            uv add pandas numpy scikit-learn matplotlib ipykernel ruff pre-commit pytest | Out-Null
        }

        uv lock | Out-Null
        uv sync | Out-Null
    } finally {
        $env:UV_LINK_MODE = $prevLinkMode
    }

    # ----------------------------
    # pre-commit install (robust)
    # ----------------------------
    try {
        if (Test-Path ".\.pre-commit-config.yaml") {
            .\.venv\Scripts\python.exe -m pre_commit install | Out-Null
        } else {
            Write-Host "Aviso: .pre-commit-config.yaml ausente — pulando pre-commit install" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Aviso: pre-commit install falhou (ignorado)." -ForegroundColor Yellow
    }

    # ----------------------------
    # First commit (best effort)
    # ----------------------------
    git add . | Out-Null
    try {
        git commit -m "chore: bootstrap project (uv + venv + ruff + pre-commit + tasks)" | Out-Null
    } catch {
        Write-Host "Aviso: git commit falhou (talvez user.name/email). Ignore por enquanto." -ForegroundColor Yellow
    }

    if ($OpenVSCode -and (_Code-Available)) { code . }

    Write-Host "OK! Projeto criado em: $projectPath" -ForegroundColor Green
    Write-Host "Dica: rode 'workon' para ativar a .venv (ou autovenv on)." -ForegroundColor DarkGray
}

function newdeproj {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$Name,
        [string]$BasePath = "D:\_DE-Projects",
        [string]$Python = "3.11",
        [switch]$OpenVSCode
    )
    _Bootstrap-Project -Name $Name -BasePath $BasePath -Kind "de" -Python $Python -OpenVSCode:$OpenVSCode
}

function newdsproj {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$Name,
        [string]$BasePath = "D:\_DS-Projects",
        [string]$Python = "3.11",
        [switch]$OpenVSCode
    )
    _Bootstrap-Project -Name $Name -BasePath $BasePath -Kind "ds" -Python $Python -OpenVSCode:$OpenVSCode
}

Set-Alias nde newdeproj
Set-Alias nds newdsproj
