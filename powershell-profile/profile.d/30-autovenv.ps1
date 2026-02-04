# 30-autovenv.ps1  workon/leave + AutoVenv + wrapper Set-Location

if (-not (Get-Variable AutoVenv_ActiveProjectRoot -Scope Global -ErrorAction SilentlyContinue)) {
    $global:AutoVenv_ActiveProjectRoot = $null
}

function _Prioritize-VenvInPath {
    if (-not $env:VIRTUAL_ENV) { return }

    $venvScripts = Join-Path $env:VIRTUAL_ENV "Scripts"
    $parts = $env:Path -split ';' | Where-Object { $_ -and ($_ -ne $venvScripts) }
    $env:Path = ($venvScripts + ';' + ($parts -join ';'))
}

function workon {
    param(
        [string]$Name,
        [switch]$Sync
    )

    # If project name is provided, locate it under roots
    if ($Name) {
        $found = $null

        foreach ($root in $global:ProjectRoots) {
            if (-not (Test-Path $root)) { continue }

            $candidate = Join-Path $root $Name
            if (Test-Path $candidate) { $found = $candidate; break }

            try {
                $match = Get-ChildItem -Path $root -Directory -ErrorAction SilentlyContinue |
                         Where-Object { $_.Name -like "*$Name*" } |
                         Select-Object -First 1
                if ($match) { $found = $match.FullName; break }
            } catch {}
        }

        if (-not $found) {
            Write-Host "Projeto não encontrado em: $($global:ProjectRoots -join ', ')" -ForegroundColor Yellow
            return
        }

        Microsoft.PowerShell.Management\Set-Location $found
    }

    $venvActivate = ".\.venv\Scripts\Activate.ps1"
    if (-not (Test-Path $venvActivate)) {
        Write-Host "Nenhuma .venv encontrada neste diretório" -ForegroundColor Yellow
        return
    }

    . $venvActivate
    _Prioritize-VenvInPath

    $global:AutoVenv_ActiveProjectRoot = (Get-Location).Path

    if (Get-Command Load-DotEnv -ErrorAction SilentlyContinue) {
        Load-DotEnv
    }

    Write-Host "Ambiente virtual ativado (.venv)" -ForegroundColor Green

    if ($Sync) {
        if (Get-Command uvsync -ErrorAction SilentlyContinue) { uvsync }
    }
}

function leave {
    # impede reativação automática durante o leave
    $prev = $global:AutoVenvEnabled
    $global:AutoVenvEnabled = $false

    # captura se estamos em um projeto com .venv (antes de sair)
    $inProjectWithVenv = Test-Path ".\.venv\Scripts\Activate.ps1"

    # tenta desativar via deactivate se existir
    if (Get-Command deactivate -ErrorAction SilentlyContinue) {
        try { deactivate | Out-Null } catch {}
    }

    # limpa variáveis padrão de venv
    Remove-Item Env:VIRTUAL_ENV -ErrorAction SilentlyContinue
    Remove-Item Env:VIRTUAL_ENV_PROMPT -ErrorAction SilentlyContinue
    Remove-Item Env:__PYVENV_LAUNCHER__ -ErrorAction SilentlyContinue
    Remove-Item Env:PYTHONHOME -ErrorAction SilentlyContinue

    # ZERA e reconstrói o PATH da sessão (Machine + User)
    $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath    = [Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path    = ($machinePath, $userPath) -join ";"

    # re-aplica python preferido fora de venv (vem do 10-python.ps1)
    if (Get-Command Ensure-PreferredPython -ErrorAction SilentlyContinue) {
        Ensure-PreferredPython
    }

    # limpa root ativo
    $global:AutoVenv_ActiveProjectRoot = $null

    Write-Host "Ambiente virtual desativado" -ForegroundColor Yellow

    # se estávamos dentro de um projeto com .venv, sai para Home (evita reativação)
    if ($inProjectWithVenv) {
        Microsoft.PowerShell.Management\Set-Location $global:LeaveHome
    }

    # restaura autovenv
    $global:AutoVenvEnabled = $prev
}

Set-Alias wo workon
Set-Alias lv leave

function _AutoVenv_Update {
    if (-not $global:AutoVenvEnabled) { return }

    $cwd = (Get-Location).Path

    # auto-leave if moved outside activated root
    if ($env:VIRTUAL_ENV -and $global:AutoVenv_ActiveProjectRoot) {
        if ($cwd -notlike "$($global:AutoVenv_ActiveProjectRoot)*") {
            leave | Out-Null
        }
    }

    # auto-workon if no venv active and local .venv exists
    if (-not $env:VIRTUAL_ENV) {
        if (Test-Path ".\.venv\Scripts\Activate.ps1") {
            . .\.venv\Scripts\Activate.ps1
            _Prioritize-VenvInPath
            $global:AutoVenv_ActiveProjectRoot = (Get-Location).Path
            if (Get-Command Load-DotEnv -ErrorAction SilentlyContinue) { Load-DotEnv }
        }
    }
}

# Wrapper Set-Location: keep default behavior + auto-venv update
function Set-Location {
    [CmdletBinding(DefaultParameterSetName='Path')]
    param(
        [Parameter(Position=0, ParameterSetName='Path', ValueFromPipelineByPropertyName=$true)]
        [string]$Path,

        [Parameter(ParameterSetName='LiteralPath', ValueFromPipelineByPropertyName=$true)]
        [string]$LiteralPath,

        [switch]$PassThru
    )

    $result = $null
    if ($PSCmdlet.ParameterSetName -eq 'LiteralPath') {
        $result = Microsoft.PowerShell.Management\Set-Location -LiteralPath $LiteralPath -PassThru:$PassThru
    } else {
        $result = Microsoft.PowerShell.Management\Set-Location -Path $Path -PassThru:$PassThru
    }

    _AutoVenv_Update

    if ($PassThru) { return $result }
}
