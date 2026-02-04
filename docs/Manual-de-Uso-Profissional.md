# 📘 Manual de Uso Profissional

## PowerShell 7 • Python 3.11/3.12 • uv • VS Code

### Sistema de Trabalho para Data Science & Data Engineering

---

## 📌 Sobre este ebook

Este ebook documenta um **sistema de trabalho profissional** baseado em:

- PowerShell 7

- Python 3.11 / 3.12

- uv (gerenciamento moderno de dependências)

- VS Code

O foco não é ensinar Python ou PowerShell do zero.  
O foco é **reduzir erro operacional**, **padronizar decisões** e **aumentar produtividade** no dia a dia de profissionais **Pleno → Sênior** em Data Science e Data Engineering.

Este material serve simultaneamente como:

- **Manual Pessoal Premium**

- **Guia de Onboarding de Time (30–60 minutos)**

---

## 🧭 Sumário

1. Filosofia do Ambiente

2. Arquitetura Mental do Setup

3. Rotina Diária Ideal (DS / DE)

4. Criando um Projeto do Zero

5. Governança Técnica Pessoal

6. Diagnóstico e Autocorreção

7. Onboarding de Time (30–60 min)

8. Checklists Operacionais

---

## 1. Filosofia do Ambiente

> **Ambiente também é código.**

Este setup existe para resolver problemas reais:

- Python errado no PATH

- venv esquecida ou vazando entre projetos

- dependências quebrando

- onboarding confuso

- perda de tempo com “ambiente estranho”

A premissa central é simples:

> **Menos mágica, mais previsibilidade.**

### O que este ambiente faz

- Torna explícito **qual Python está ativo**

- Automatiza apenas o que é **seguro**

- Facilita diagnóstico rápido

- Reduz erro humano

### O que este ambiente NÃO faz (de propósito)

- ❌ Não instala ferramentas automaticamente

- ❌ Não esconde decisões

- ❌ Não mistura ambiente com projeto

- ❌ Não ativa `.venv` sem contexto

---

## 2. Arquitetura Mental do Setup

Cada camada tem uma responsabilidade clara:

| Camada             | Responsabilidade            |
| ------------------ | --------------------------- |
| PowerShell Profile | Comportamento do terminal   |
| Projeto Python     | Código e dependências       |
| uv                 | Reprodutibilidade           |
| `.venv`            | Isolamento                  |
| VS Code            | Ambiente de desenvolvimento |

### Regra de ouro

> Se algo parece confuso, provavelmente as responsabilidades estão misturadas.

---

## 3. Rotina Diária Ideal (DS / DE)

### 🌅 Início do dia

```powershell
pwsh
cd D:\_DS-Projects\meu-projeto
workon
python --version
```

✔ Python correto  
✔ `.venv` ativa  
✔ Ambiente previsível

---

### 🛠️ Durante o trabalho

Sincronizar dependências (quando necessário):

```powershell
uv sync
```

Qualidade de código:

```powershell
python -m ruff check .
python -m ruff format .
```

Versionamento consciente:

```powershell
git status
git commit -m "mensagem clara"
```

---

### 🌙 Encerramento do dia (obrigatório)

```powershell
leave
```

✔ Ambiente limpo  
✔ Sem vazamento de contexto

---

## 4. Criando um Projeto do Zero (Passo a Passo)

### 4.1 Escolha do diretório

- DS → `D:\_DS-Projects\`

- DE → `D:\_DE-Projects\`

```powershell
mkdir D:\_DS-Projects\credit-score
cd D:\_DS-Projects\credit-score
```

---

### 4.2 Inicializar projeto com uv

```powershell
git init
uv init
uv venv --python 3.11
workon
```

---

### 4.3 Instalar dependências base

```powershell
uv pip install pandas numpy scikit-learn ipykernel matplotlib
```

---

### 4.4 Estrutura padrão

```powershell
mkdir src tests notebooks docs artifacts data
mkdir data\raw data\processed
```

---

### ⚠️ Erros comuns evitados por este fluxo

- Instalar pacotes globalmente

- Esquecer lockfile

- Misturar dependências entre projetos

- Criar estrutura “no improviso”

---

## 5. Governança Técnica Pessoal

Este sistema assume disciplina técnica como padrão.

### Regras não negociáveis

- Um projeto = uma `.venv`

- `uv.lock` sempre commitado

- Nunca editar lockfile manualmente

- `.venv`, `data/`, `artifacts/` fora do Git

### Por quê?

Porque:

- reduz retrabalho

- facilita onboarding

- permite reprodução exata do ambiente

- demonstra maturidade técnica

---

## 6. Diagnóstico e Autocorreção

Ao menor sinal de problema:

```powershell
doctor
```

### O que verificar

- Python ativo

- PATH

- uv disponível

- `.venv` ativa

### Antes de pedir ajuda

1. Rode `doctor`

2. Verifique `where.exe python`

3. Confirme se está dentro da `.venv`

> **Diagnóstico antes de correção. Sempre.**

---

## 7. Onboarding de Time (30–60 minutos)

### Checklist rápido

```powershell
git clone <repo>
cd <repo>
uv sync
workon
python -m src.main
doctor
```

### Como trabalhamos aqui

- Um projeto = uma `.venv`

- Nunca instalar fora do ambiente

- Sempre commit com lockfile

- Sempre encerrar com `leave`

Isso reduz:

- perguntas repetidas

- erro operacional

- dependência excessiva do sênior

---

## 8. Checklists Operacionais

### ✅ Checklist de início do dia

- Estou no diretório correto

- `.venv` ativa

- Python correto

### ✅ Checklist de fim do dia

- Commit feito

- `leave` executado

- Ambiente limpo

### ✅ Checklist de ambiente saudável

- `uv sync` funciona

- Projeto roda do zero

- `doctor` sem alertas críticos

---

## 🧠 Encerramento

Este ebook não documenta scripts.  
Ele documenta **uma forma profissional de trabalhar**.

Se você:

- reduz erro humano

- facilita onboarding

- garante previsibilidade

Então você não está apenas escrevendo código —  
você está **projetando sistemas de trabalho**.

---

## 📎 Dica para gerar PDF

Com **Pandoc**:

```bash
pandoc ebook.md -o ebook.pdf --toc --pdf-engine=xelatex
```

Ou usando:

- Typora

- VS Code + Markdown PDF

- Obsidian

---

Se quiser, no próximo passo posso:

- criar **capa em Markdown**

- adaptar para **GitHub README**

- gerar **versão resumida (one-pager)**

- ou ajustar linguagem para publicação pública

Mas agora você já tem o **ebook completo, editável e versionável**.
