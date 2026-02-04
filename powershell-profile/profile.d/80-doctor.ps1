# 80-doctor.ps1 — Doctor / Project Health

function doctor {
    Write-Host "======================" -ForegroundColor DarkGray
    Write-Host "Doctor — Project Health" -ForegroundColor Cyan
    Write-Host "======================" -ForegroundColor DarkGray

    Write-Host "`n[1] Local" -ForegroundColor Yellow
    Write-Host ("PWD:  {0}" -f (Get-Location).Path) -ForegroundColor Gray

    Write-Host "`n[2] Python resolution" -ForegroundColor Yellow
    try {
        $py = (Get-Command python -ErrorAction Stop).Source
        Write-Host "python: $py" -ForegroundColor Gray
        python -c "import sys; print('sys.executable:', sys.executable); print('version:', sys.version.split()[0])"
    } catch {
        Write-Host "python não encontrado." -ForegroundColor Red
    }

    Write-Host "`n[3] Venv" -ForegroundColor Yellow
    if ($env:VIRTUAL_ENV) { Write-Host "VIRTUAL_ENV: $env:VIRTUAL_ENV" -ForegroundColor Green }
    else { Write-Host "VIRTUAL_ENV: (none)" -ForegroundColor Yellow }

    Write-Host "`n[4] Repo" -ForegroundColor Yellow
    if (Test-Path ".git") { Write-Host "git: OK" -ForegroundColor Green }
    else { Write-Host "git: não é repo (.git ausente)" -ForegroundColor Yellow }

    Write-Host "`n[5] Repro files" -ForegroundColor Yellow
    foreach ($f in @("pyproject.toml","uv.lock","ruff.toml",".pre-commit-config.yaml")) {
        if (Test-Path $f) { Write-Host ("{0}: OK" -f $f) -ForegroundColor Green }
        else              { Write-Host ("{0}: MISSING" -f $f) -ForegroundColor Red }
    }

    Write-Host "`n[6] Tools" -ForegroundColor Yellow
    foreach ($cmd in @("uv","pre-commit")) {
        if (Get-Command $cmd -ErrorAction SilentlyContinue) {
            $v = & $cmd --version 2>$null
            Write-Host ("{0}: {1}" -f $cmd, $v) -ForegroundColor Green
        } else {
            Write-Host ("{0}: not found" -f $cmd) -ForegroundColor Red
        }
    }

    Write-Host "`n[7] Quick checks (src/tests)" -ForegroundColor Yellow
    if (Test-Path "ruff.toml") {
        try { python -m ruff check src tests | Out-Host }
        catch { Write-Host "ruff check falhou" -ForegroundColor Red }
    } else {
        Write-Host "ruff.toml ausente — pulando ruff check" -ForegroundColor Yellow
    }

    Write-Host "`nDone." -ForegroundColor Cyan
}
