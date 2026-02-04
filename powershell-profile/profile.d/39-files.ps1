# 40-files.ps1 — writers de arquivos base (ruff / pre-commit / git)

function _Write-RuffToml {
    param([string]$Python = "3.11")

    if (Test-Path ".\ruff.toml") { return }

    # target-version baseado no Python informado (ex: 3.11 -> py311)
    $pyTag = "py" + ($Python -replace '\.', '')

@"
target-version = "$pyTag"
line-length = 100

exclude = [
  ".venv",
  "__pycache__",
  ".git",
  ".vscode",
  "data",
  "artifacts",
  "marimo-dashboard-demo",
]

[lint]
select = ["E", "F", "I", "B", "UP", "SIM", "PL"]
ignore = ["E501", "PLR0913", "PLR2004"]

[format]
quote-style = "double"
indent-style = "space"
line-ending = "auto"
"@ | Set-Content -Encoding UTF8 ".\ruff.toml"
}

function _Write-PreCommitConfig {
    if (Test-Path ".\.pre-commit-config.yaml") { return }

@"
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.6.9
    hooks:
      - id: ruff
        args: ["--fix"]
      - id: ruff-format
"@ | Set-Content -Encoding UTF8 ".\.pre-commit-config.yaml"
}

function _Write-GitIgnore {
    if (Test-Path ".\.gitignore") { return }

@"
__pycache__/
.py[cod]
.ipynb_checkpoints/
.venv/
.env
.vscode/

data/raw/
data/processed/
artifacts/
*.log
"@ | Set-Content -Encoding UTF8 ".\.gitignore"
}

function _Write-EnvExample {
    if (Test-Path ".\.env.example") { return }

@"
# Copie para .env e preencha (NUNCA commitar .env)
DB_PATH=...
AWS_PROFILE=default
DATABRICKS_HOST=...
DATABRICKS_TOKEN=...
"@ | Set-Content -Encoding UTF8 ".\.env.example"
}

function _Write-GitAttributes {
    if (Test-Path ".\.gitattributes") { return }

@"
text=auto eol=lf
*.ps1 text eol=crlf
"@ | Set-Content -Encoding UTF8 ".\.gitattributes"
}
