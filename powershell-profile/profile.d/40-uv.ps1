# 40-uv.ps1  uv helpers (reprodutibilidade)

function _Assert-UV {
    if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
        Write-Host "uv não encontrado no PATH" -ForegroundColor Red
        return $false
    }
    return $true
}

function _Assert-PyProject {
    if (-not (Test-Path ".\pyproject.toml")) {
        Write-Host "pyproject.toml não encontrado neste diretório" -ForegroundColor Yellow
        return $false
    }
    return $true
}

function uvsync {
    if (-not (_Assert-UV)) { return }
    if (-not (_Assert-PyProject)) { return }

    # garante venv local
    if (-not (Test-Path ".\.venv\Scripts\Activate.ps1")) {
        uv venv | Out-Null
    }

    uv sync
}

function deps {
    if (-not (_Assert-UV)) { return }
    if (-not (_Assert-PyProject)) { return }

    # mostra lista de pacotes instalados no ambiente atual
    # (não mexe em lockfile)
    uv pip list
}

# uv não suporta "minor-only upgrade" nativamente.
# - deps-upgrade <pkg> : upgrade desse pacote
# - deps-upgrade       : upgrade de tudo (major+minor)
function deps-upgrade {
    param([string]$Package)

    if (-not (_Assert-UV)) { return }
    if (-not (_Assert-PyProject)) { return }

    if ($Package) {
        Write-Host "Upgrading package: $Package" -ForegroundColor Yellow
        uv lock --upgrade --upgrade-package $Package
    } else {
        Write-Host "  Upgrading ALL dependencies (minor + major)" -ForegroundColor Red
        Write-Host "Use: deps-upgrade <package> para upgrade pontual." -ForegroundColor DarkYellow
        uv lock --upgrade
    }

    uv sync
}

Set-Alias sync uvsync
