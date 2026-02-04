# 60-readme.ps1  README templates (robusto / sem parser traps)

function _Write-README-Generic {
    param(
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][ValidateSet("de","ds")][string]$Kind,
        [Parameter(Mandatory=$true)][string]$Python
    )

    $kindLabel = if ($Kind -eq "de") { "Data Engineering" } else { "Data Science" }

    # IMPORTANT: use only single-quoted strings here (no ${} expansion, no backticks)
    $lines = @(
        ('# ' + $Name),
        '',
        '> **Status:** padrão ouro de reprodutibilidade',
        ('> **Tipo:** ' + $kindLabel),
        '> **Shell recomendado:** PowerShell 7',
        ('> **Python:** ' + $Python),
        '> **Gerenciador:** uv',
        '> **Qualidade:** ruff + pre-commit',
        '',
        '---',
        '',
        '##  Visão Geral',
        'Este repositório segue um padrão profissional para projetos Python, com foco em:',
        '- reprodutibilidade total do ambiente',
        '- controle explícito de dependências (lockfile)',
        '- padronização de código (lint/format)',
        '- onboarding rápido para novos colaboradores',
        '',
        '---',
        '',
        '##  Stack Técnica',
        ('- Python ' + $Python),
        '- uv (deps + lock)',
        '- .venv (venv local do projeto)',
        '- ruff (lint/format)',
        '- pre-commit (governança de commit)',
        '- VS Code Tasks (execução assistida)',
        '',
        '---',
        '',
        '##  Estrutura do Projeto',
        '```text',
        '.',
        ' src/',
        ' tests/',
        ' notebooks/',
        ' docs/',
        ' data/',
        '    raw/',
        '    processed/',
        ' artifacts/',
        ' .vscode/',
        ' pyproject.toml',
        ' uv.lock',
        ' ruff.toml',
        ' .pre-commit-config.yaml',
        ' .env.example',
        ' .gitattributes',
        ' README.md',
        '```',
        '',
        '---',
        '',
        '##  Como rodar (setup padrão ouro)',
        '',
        '### 1) Pré-requisitos',
        '- PowerShell 7',
        ('- Python ' + $Python + ' (ou compatível)'),
        '- uv instalado e no PATH',
        '',
        '### 2) Criar e sincronizar ambiente',
        'No diretório do projeto:',
        '```powershell',
        'uv venv',
        'uv sync',
        '```',
        '',
        '### 3) Ativar ambiente (opcional)',
        '```powershell',
        '.\.venv\Scripts\Activate.ps1',
        '```',
        '',
        '### 4) Qualidade de código',
        '```powershell',
        'python -m ruff check src tests',
        'python -m ruff format src tests',
        '```',
        '',
        '### 5) Hooks de commit (pre-commit)',
        '```powershell',
        'pre-commit install',
        'pre-commit run --all-files',
        '```',
        '',
        '---',
        '',
        '##  Reprodutibilidade',
        '- O arquivo uv.lock fixa as versões resolvidas.',
        '- Use uv sync para reproduzir o ambiente em outra máquina.',
        '- Para upgrades controlados:',
        '```powershell',
        'deps-upgrade pandas',
        '```',
        ''
    )

    $lines | Set-Content -Encoding UTF8 "README.md"
}

function _Write-README-DE {
    param([string]$Name, [string]$Python)
    _Write-README-Generic -Name ($Name + " (Data Engineering)") -Kind "de" -Python $Python
}

function _Write-README-DS {
    param([string]$Name, [string]$Python)
    _Write-README-Generic -Name ($Name + " (Data Science)") -Kind "ds" -Python $Python
}
