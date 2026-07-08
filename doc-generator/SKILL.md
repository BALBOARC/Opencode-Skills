---
name: doc-generator
description: Use when generating HTML and PDF documentation from structured JSON reports (scanner-output.json, business-rules.json, lgpd-report.json). Activates on "gerar PDF", "gerar documentação", "generate PDF", "gerar relatório". Use ONLY for the final documentation generation step; do NOT use for scanning or extraction.
---

# Documentation Generator

Generate professional HTML and PDF documentation from analysis JSON files. Requires `scanner-output.json`, `business-rules.json`, and `lgpd-report.json` in the project's output directory.

## Output directory

All files under **`/mnt/d/Opencode/{project-name}/`** with automatic versioning.

Cada execução gera um diretório versionado com todos os documentos — execuções anteriores nunca são sobrescritas.

## Input

Read from `/mnt/d/Opencode/{project-name}/`:
- `scanner-output.json` — project structure
- `business-rules.json` — business rules
- `lgpd-report.json` — compliance report

## Output structure

```
/mnt/d/Opencode/{project-name}/{YYYY-MM-DD}_v{N}/
└── docs/
    ├── business-rules-{project}.html
    ├── business-rules-{project}.pdf
    ├── technical-docs-{project}.html
    ├── technical-docs-{project}.pdf
    └── resumo-analise-{project}.md
```

## Workflow

1. Extract project name from target path: `basename "$1"`
2. Create versioned output directory:
   ```bash
   ENSURE_SCRIPT=~/.config/opencode/skills/opencode-output-path/ensure.sh
   if [ -f "$ENSURE_SCRIPT" ]; then
       OUTPUT_DIR=$(bash "$ENSURE_SCRIPT" "{project-name}" --v)
   else
       OUTPUT_DIR="/mnt/d/Opencode/{project-name}"
   fi
   mkdir -p "$OUTPUT_DIR/docs"
   ```
3. Load `/mnt/d/Opencode/{project-name}/scanner-output.json`, `business-rules.json`, `lgpd-report.json`
4. Generate `business-rules-{project}.html` using Business CSS Theme with data from `business-rules.json`
5. Generate `technical-docs-{project}.html` using Technical CSS Theme with data from `scanner-output.json` and `lgpd-report.json`
6. Convert HTML to PDF: `weasyprint input.html output.pdf`
7. Generate `resumo-analise-{project}.md` with project name, domains count, rules count, key risks, generated files list
8. Save all files to `"$OUTPUT_DIR/docs/"`

## Business CSS Theme

Apply professional styling: A4 page, cover page with gradient background, table-based rule layout, monospace code blocks.

## Technical CSS Theme

Apply dark-themed styling: A4 page, dark cover with accent color, `.note` and `.warning` callout boxes, ASCII diagram containers.
