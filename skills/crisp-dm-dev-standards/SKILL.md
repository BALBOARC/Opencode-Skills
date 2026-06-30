---
name: crisp-dm-dev-standards
description: |
  Use when developing data projects to enforce CRISP-DM methodology, PEP 8 / ISO-compliant clean code, zero-residue policy, and international certification standards.
  Activates on: "skill", "crisp-dm", "clean code", "padrão", "metodologia", "certificação", "desenvolvimento", "Código limpo", "boas práticas", "resíduo".
  Scope: all Python data projects, ETL pipelines, APIs, and Streamlit apps.
---

# CRISP-DM Clean Code Standards

Metodologia e padrões de desenvolvimento para projetos de dados, baseados em **CRISP-DM**, **PEP 8/20/257/484**, **ISO/IEC 25010**, **Clean Code** e **certificações internacionais** (AWS, GCP, Databricks, Google).

---

## 1. CRISP-DM — Ciclo de Vida do Projeto

Todo projeto de dados deve seguir as 6 fases do CRISP-DM. Cada fase gera entregáveis obrigatórios antes de avançar.

### 1.1 Business Understanding
**Entregáveis:**
- `docs/business-understanding.md` — problema de negócio, objetivos, critérios de sucesso
- `docs/glossary.md` — glossário de termos de negócio
- Checklist de aprovação do stakeholder antes de avançar

**Template:**
```markdown
# Business Understanding — {Projeto}

## Problema de Negócio
{O que está sendo resolvido?}

## Objetivos
- Objetivo de negócio: {metric}
- Objetivo técnico: {metric}

## Critérios de Sucesso
- {critério mensurável 1}
- {critério mensurável 2}

## Atores Envolvidos
| Ator | Papel | Expectativa |
|---|---|---|
```

### 1.2 Data Understanding
**Entregáveis:**
- `notebooks/01_exploracao.ipynb` — análise exploratória completa
- `docs/data-dictionary.md` — dicionário de dados (nome, tipo, domínio, nulos, origem)
- `docs/data-quality-report.md` — relatório de qualidade (nulos, duplicatas, outliers, inconsistências)

**Regras:**
- Toda coluna deve ter descrição no dicionário
- Valores nulos devem ser quantificados e justificados
- Outliers devem ser documentados (não removidos sem justificativa de negócio)

### 1.3 Data Preparation
**Entregáveis:**
- `pipeline/transform.py` — pipeline de transformação
- `pipeline/preprocessing.py` — funções de limpeza (testadas)
- `database/schema.sql` — schema final do banco

**Regras:**
- Pipeline deve ser reproduzível (seed fixa para aleatoriedade)
- Transformações devem ser funções puras (sem efeito colateral)
- Dados preparados salvos em `data/processed/` com versão

### 1.4 Modeling (Pipeline Design)
**Entregáveis:**
- `docs/architecture.md` — arquitetura do pipeline
- `database/schema.sql` — modelagem dimensional (fato/dimensão)
- `pipeline/` — scripts ETL modulares

**Regras:**
- Pipeline deve ser modular: extract / transform / load separados
- Cada etapa do pipeline deve ser testável isoladamente
- Logging em cada etapa (início, fim, duração, linhas processadas)

### 1.5 Evaluation
**Entregáveis:**
- `docs/evaluation-report.md` — relatório de avaliação
- Métricas de qualidade dos dados pós-pipeline
- Revisão com stakeholder

**Regras:**
- Comparar dados finais com requisitos de negócio (1.1)
- Documentar limitações conhecidas
- Checklist de aceite do stakeholder

### 1.6 Deployment
**Entregáveis:**
- `README.md` — instruções completas
- `docker/docker-compose.yml` — ambiente reproduzível
- `.github/workflows/` — CI/CD automatizado
- Deploy em Streamlit Cloud / GitHub Pages / cloud

**Regras:**
- README deve ter: descrição, stack, instruções de uso, deploy, fontes de dados
- Deploy deve ser gratuito ou justificado
- Documentar variáveis de ambiente necessárias

---

## 2. Clean Code — Padrões de Código

### 2.1 Python — PEP 8 (ISO/IEC 25010 conformidade)

| Regra | Padrão | Exceção |
|---|---|---|
| Indentação | 4 espaços (sem tabs) | Nunca |
| Linhas máximas | 79 caracteres (código), 72 (docstrings) | Strings longas |
| Imports | `import a` / `from a import b` (um por linha) | `from a import (b, c, d)` |
| Linhas em branco | 2 entre funções top-level, 1 entre métodos | - |
| Espaços | `x = 1` (operadores), `f(a, b)` (vírgulas) | Indexação: `lista[0]` |

### 2.2 Naming Conventions

| Elemento | Padrão | Exemplo |
|---|---|---|
| Pacotes | `snake_case` curto | `pipeline`, `api` |
| Módulos | `snake_case` | `extract.py`, `transform.py` |
| Classes | `PascalCase` | `APACClient`, `RainPipeline` |
| Funções | `snake_case` verbo | `get_precipitacao()`, `transform_data()` |
| Variáveis | `snake_case` substantivo | `precipitacao_mm`, `total_ocorrencias` |
| Constantes | `UPPER_SNAKE_CASE` | `MAX_RETRIES`, `API_BASE_URL` |
| Atributos privados | `_snake_case` | `_api_key` (indicar保护的mas não enforce) |

### 2.3 Tipo de Dados — PEP 484 (Type Hints)

**Obrigatório em:** funções públicas, classes, parâmetros de API, retorno de pipelines

```python
# Correto
def get_precipitacao(
    estacao: str,
    data_inicio: date,
    data_fim: date,
) -> list[dict[str, float]]:
    ...

# Incorreto (sem type hints)
def get_precipitacao(estacao, data_inicio, data_fim):
    ...
```

**Uso de `Optional`, `Union`, `Any`:**
- `Optional[str]` para parâmetros que podem ser None
- `dict[str, Any]` apenas quando o tipo interno é dinâmico (ex: JSON genérico)
- Evitar `Union` — preferir `|` (Python 3.10+): `str | None`

### 2.4 Docstrings — PEP 257 (Google Style)

**Toda função pública deve ter docstring.**

```python
def calcular_kpi(
    dados: pd.DataFrame,
    periodo: str = "mensal",
) -> dict[str, float]:
    """Calcula KPIs de chuva e impacto por período.

    Args:
        dados: DataFrame com colunas data, precipitacao_mm, ocorrencias.
        periodo: Agregação temporal ('diario', 'mensal', 'anual').

    Returns:
        Dict com KPIs calculados: {
            'total_chuva_mm': float,
            'media_chuva_mm': float,
            'total_ocorrencias': int,
            'dias_com_alerta': int,
        }

    Raises:
        ValueError: Se período não for reconhecido.
    """
```

### 2.5 Estrutura de Arquivos

**Ordem dentro de cada arquivo:**
1. `"""Docstring do módulo"""` (obrigatório)
2. `from __future__ import annotations` (se aplicável)
3. Imports da biblioteca padrão
4. Imports de terceiros
5. Imports locais
6. Constantes (UPPER_CASE)
7. Funções auxiliares privadas (`_`)
8. Funções/Classes públicas

```python
"""Clientes para APIs meteorológicas."""

from __future__ import annotations

import os
from datetime import date, datetime
from typing import Any

import pandas as pd
import requests
from dotenv import load_dotenv

from pipeline.utils import setup_logger

logger = setup_logger(__name__)
API_BASE_URL = "https://api.apac.pe.gov.br"
MAX_RETRIES = 3


def _parse_date(raw: str) -> date:
    ...


class APACClient:
    ...
```

---

## 3. Zero Residue Policy

**Não é permitido no código final:**

### 3.1 Proibido
| Item | Exemplo | Ação |
|---|---|---|
| Código comentado | `# print(x)` | Remover |
| Debug prints | `print("aqui", x)` | Substituir por logger |
| TODO/FIXME sem issue | `# TODO: refatorar` | Criar issue ou remover |
| Imports não usados | `import os` (não usado) | Lint automático (ruff) |
| Variáveis não usadas | `x = func()` (x não usado) | Remover ou usar `_` |
| Arquivos temporários | `temp.ipynb`, `backup.py` | Gitignore + limpeza |
| Células vazias no notebook | Notebook com células em branco | Remover |
| Secrets hardcoded | `API_KEY = "123"` no código | .env + .env.example |
| Diretórios vazios | `data/old/` sem arquivos | Remover |

### 3.2 Ferramentas de garantia
```bash
# Antes de cada commit
ruff check .                          # Linter (substitui flake8)
ruff format --check .                  # Formatação (substitui black)
mypy .                                 # Type checking
pytest --cov                           # Testes com cobertura

# No CI/CD (GitHub Actions)
ruff check . && ruff format --check . && mypy . && pytest
```

### 3.3 Regras de commit
```bash
# Convencional Commits (ISO/IEC 25010 conformidade)
<tipo>(<escopo>): <descrição>

# Tipos: feat, fix, refactor, test, docs, style, chore, perf
# Exemplos:
feat(pipeline): add APAC precipitation ingestion
fix(api): handle null values in KPI response
refactor(transform): extract validation into separate module
docs(readme): add deploy instructions
test(pipeline): cover extract with 95%+ coverage
```

---

## 4. Estrutura de Projeto Padrão

```
{projeto}/
├── docs/                        # Documentação do projeto
│   ├── business-understanding.md
│   ├── data-dictionary.md
│   ├── architecture.md
│   └── glossary.md
├── data/
│   ├── raw/                     # Dados brutos (imutáveis)
│   ├── processed/               # Dados transformados
│   └── external/                # Dados de fontes externas
├── notebooks/
│   ├── 01_exploracao.ipynb      # Análise exploratória
│   └── 02_validacao.ipynb       # Validação de resultados
├── pipeline/                    # Código principal
│   ├── __init__.py
│   ├── extract.py               # Ingestão de dados
│   ├── transform.py             # Limpeza e transformação
│   ├── load.py                  # Carga no banco
│   └── utils.py                 # Utilitários
├── api/ ou web/                 # Interface (FastAPI / Streamlit)
│   ├── __init__.py
│   ├── main.py
│   └── routers/                 # (se FastAPI)
├── database/
│   ├── schema.sql               # Schema do banco
│   └── migrations/              # Migrações incrementais
├── tests/
│   ├── test_extract.py
│   ├── test_transform.py
│   └── conftest.py              # Fixtures compartilhadas
├── docker/
│   └── Dockerfile
├── .github/
│   └── workflows/
│       └── ci.yml               # CI/CD pipeline
├── .env.example                 # Variáveis de ambiente (sem secrets)
├── .gitignore
├── requirements.txt
├── Makefile                     # Comandos padronizados
└── README.md
```

---

## 5. Makefile Padrão para Projetos

```makefile
.PHONY: install lint format typecheck test clean run deploy

install:
	pip install -r requirements.txt

lint:
	ruff check .

format:
	ruff format .

typecheck:
	mypy .

test:
	pytest --cov --cov-report=term-missing

clean:
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	rm -rf .pytest_cache .ruff_cache .mypy_cache

run-web:
	streamlit run web/app.py

run-pipeline:
	python pipeline/run.py
```

---

## 6. Testes — Padrão AAA (Arrange-Act-Assert)

### 6.1 Estrutura de cada teste

```python
def test_calcular_kpi_com_dados_validos():
    # Arrange
    dados = pd.DataFrame({
        "data": ["2024-01-01", "2024-01-02"],
        "precipitacao_mm": [50.0, 80.0],
        "ocorrencias": [2, 5],
    })

    # Act
    resultado = calcular_kpi(dados, periodo="diario")

    # Assert
    assert resultado["total_chuva_mm"] == 130.0
    assert resultado["total_ocorrencias"] == 7
    assert resultado["dias_com_alerta"] == 1
```

### 6.2 Cobertura mínima
| Módulo | Cobertura |
|---|---|
| Pipeline (transform) | ≥ 90% |
| Utils | ≥ 80% |
| API (validações) | ≥ 80% |
| Testes de integração | ≥ 1 por fluxo principal |

---

## 7. Logging Padrão

```python
# pipeline/utils.py
import logging
from typing import Optional

def setup_logger(name: str, level: Optional[str] = None) -> logging.Logger:
    """Configura logger padronizado para o projeto."""
    level = level or os.getenv("LOG_LEVEL", "INFO")
    logger = logging.getLogger(name)
    handler = logging.StreamHandler()
    handler.setFormatter(
        logging.Formatter(
            "%(asctime)s | %(name)s | %(levelname)s | %(message)s"
        )
    )
    logger.addHandler(handler)
    logger.setLevel(getattr(logging, level.upper(), logging.INFO))
    return logger
```

**Níveis e uso:**
| Nível | Uso |
|---|---|
| `DEBUG` | Dados detalhados de depuração (não em produção) |
| `INFO` | Início/fim de pipeline, linhas processadas, duração |
| `WARNING` | Dados ausentes, fallbacks ativados |
| `ERROR` | Falha de etapa, API offline, dados inválidos |
| `CRITICAL` | Pipeline não pode continuar |

---

## 8. Tratamento de Erros

```python
# Ruim — except genérico silencia erros
try:
    dados = api.get_precipitacao()
except:
    pass

# Bom — específico, logado, com fallback
try:
    dados = api.get_precipitacao()
except requests.exceptions.Timeout:
    logger.warning("API timed out, trying fallback...")
    dados = _load_cached_data()
except requests.exceptions.RequestException as e:
    logger.error(f"API request failed: {e}")
    raise
except ValueError as e:
    logger.error(f"Invalid data format: {e}")
    raise
```

---

## 9. Checklist de Revisão (Pré-commit)

- [ ] Código segue PEP 8 (ruff check)
- [ ] Type hints em todas as funções públicas
- [ ] Docstrings em todas as funções públicas
- [ ] Zero código comentado
- [ ] Zero debug prints
- [ ] Zero imports não usados
- [ ] Logging implementado (não print)
- [ ] Testes passam (pytest)
- [ ] Cobertura mínima ≥ 80%
- [ ] README atualizado
- [ ] .env.example atualizado (sem secrets)
- [ ] Schema SQL versionado
- [ ] Commits seguem Conventional Commits
- [ ] Variáveis de ambiente documentadas

---

## 10. Referências

| Padrão | Aplicação |
|---|---|
| CRISP-DM 1.0 | Metodologia de projeto |
| PEP 8 | Estilo de código Python |
| PEP 257 | Docstrings (Google Style) |
| PEP 484 | Type hints |
| PEP 20 (Zen of Python) | Filosofia de design |
| ISO/IEC 25010 | Qualidade de software |
| Conventional Commits 1.0 | Mensagens de commit |
| AAA Pattern | Estrutura de testes |
| SOLID | Design de classes |
