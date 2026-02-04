# 10-python.ps1  Python preference (fora de venv) + helpers

function whichpy { where.exe python }
function whichuv { where.exe uv }

function Ensure-PreferredPython {
    # Nunca sobrescreve um ambiente virtual ativo
    if ($env:VIRTUAL_ENV) { return }

    $preferredPython        = "D:\Python\Python311"
    $preferredPythonScripts = "D:\Python\Python311\Scripts"

    if (Test-Path $preferredPython) {
        if (($env:Path -split ';') -notcontains $preferredPython) {
            $env:Path = "$preferredPython;$env:Path"
        }
    }

    if (Test-Path $preferredPythonScripts) {
        if (($env:Path -split ';') -notcontains $preferredPythonScripts) {
            $env:Path = "$preferredPythonScripts;$env:Path"
        }
    }

    # Remove alias store
    if (Test-Path Alias:python) {
        Remove-Item Alias:python -ErrorAction SilentlyContinue
    }
}

Ensure-PreferredPython
