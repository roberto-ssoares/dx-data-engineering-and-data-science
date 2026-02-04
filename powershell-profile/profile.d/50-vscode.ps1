# 50-vscode.ps1 — gera .vscode/settings.json e .vscode/tasks.json (robusto)

function _Write-VSCode-Files {
    param([Parameter(Mandatory=$true)][ValidateSet("de","ds")][string]$Kind)

    if (-not (Test-Path ".vscode")) {
        New-Item -ItemType Directory -Path ".vscode" -Force | Out-Null
    }

    # settings.json
    $settings = [ordered]@{
        "python.defaultInterpreterPath"              = '${workspaceFolder}\.venv\Scripts\python.exe'
        "terminal.integrated.defaultProfile.windows" = "PowerShell"
        "terminal.integrated.cwd"                    = '${workspaceFolder}'
        "python.terminal.activateEnvironment"        = $true
    }
    $settings | ConvertTo-Json -Depth 10 | Set-Content -Encoding UTF8 ".vscode\settings.json"

    # tasks.json
    $tasks = New-Object System.Collections.Generic.List[object]
    $tasks.Add(@{ label="uv: sync"; type="shell"; command="uv sync"; problemMatcher=@() })
    $tasks.Add(@{ label="uv: lock"; type="shell"; command="uv lock"; problemMatcher=@() })

    $tasks.Add(@{ label="ruff: lint (src/tests)"; type="shell"; command=".\.venv\Scripts\python.exe -m ruff check src tests"; problemMatcher=@() })
    $tasks.Add(@{ label="ruff: format (src/tests)"; type="shell"; command=".\.venv\Scripts\python.exe -m ruff format src tests"; problemMatcher=@() })

    $tasks.Add(@{ label="python: run main"; type="shell"; command=".\.venv\Scripts\python.exe -m src.main"; problemMatcher=@() })
    $tasks.Add(@{ label="python: run tests (pytest)"; type="shell"; command=".\.venv\Scripts\python.exe -m pytest -q"; problemMatcher=@() })

    if ($Kind -eq "ds") {
        $tasks.Add(@{ label="python: run train"; type="shell"; command=".\.venv\Scripts\python.exe -m src.train"; problemMatcher=@() })
    }

    $tasksJson = [ordered]@{ version = "2.0.0"; tasks = $tasks }
    $tasksJson | ConvertTo-Json -Depth 10 | Set-Content -Encoding UTF8 ".vscode\tasks.json"

    # scaffolds (src/main.py e src/train.py)
    if (-not (Test-Path "src")) { New-Item -ItemType Directory -Path "src" -Force | Out-Null }

    if (-not (Test-Path "src\main.py")) {
        $mainPy = @(
            'def main():',
            '    print("Project ready ✅")',
            '',
            'if __name__ == "__main__":',
            '    main()',
            ''
        )
        $mainPy | Set-Content -Encoding UTF8 "src\main.py"
    }

    if ($Kind -eq "ds" -and -not (Test-Path "src\train.py")) {
        $trainPy = @(
            'def train():',
            '    print("Training scaffold ✅")',
            '',
            'if __name__ == "__main__":',
            '    train()',
            ''
        )
        $trainPy | Set-Content -Encoding UTF8 "src\train.py"
    }
}
