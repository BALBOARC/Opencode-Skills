---
name: business-rules
description: Use when extracting business rules from code, documenting business logic in IF/THEN format, or generating structured business rule documentation. Activates on "extrair regras", "regras de negócio", "business rules", "documentar regras". Expects scanner-output.json as input. Use ONLY for business rule extraction; do NOT use for technical documentation or compliance.
---

# Business Rules Extractor

Extract business rules from the scanned project. Requires `scanner-output.json` in the output directory.

## Output directory

All files under **`/mnt/d/Opencode/{project-name}/`** with automatic versioning.

```
/mnt/d/Opencode/{project-name}/
└── {YYYY-MM-DD}_v{N}_business-rules.json
```

Cada execução gera um novo arquivo versionado — execuções anteriores nunca são sobrescritas.

## Input

Read `/mnt/d/Opencode/{project-name}/scanner-output.json` for project structure context.

## Output

```json
{
  "projectName": "...",
  "rules": [
    {
      "id": "BR-001",
      "domain": "...",
      "name": "...",
      "description": "...",
      "trigger": "...",
      "logic": "IF ... THEN ...",
      "sourceFile": "path/to/file:line",
      "actors": ["..."],
      "preconditions": ["..."],
      "postconditions": ["..."],
      "relatedRules": ["BR-002"]
    }
  ],
  "negativeRules": [
    {
      "id": "NR-001",
      "description": "What should NOT happen",
      "logic": "IF ... THEN ERROR ..."
    }
  ]
}
```

## Workflow

1. Extract project name from target path: `basename "$1"`
2. Create output directory with versioning:
   ```bash
   ENSURE_SCRIPT=~/.config/opencode/skills/opencode-output-path/ensure.sh
   if [ -f "$ENSURE_SCRIPT" ]; then
       OUTPUT_PATH=$(bash "$ENSURE_SCRIPT" "{project-name}" --v "business-rules.json")
   else
       mkdir -p "/mnt/d/Opencode/{project-name}"
       OUTPUT_PATH="/mnt/d/Opencode/{project-name}/business-rules.json"
   fi
   ```
3. Load `/mnt/d/Opencode/{project-name}/scanner-output.json`
4. For each module, read entity, service, and controller files from the original project
5. Extract business rules with complete fields (ID, domain, name, description, trigger, logic in IF/THEN format, source file:line, actors, constraints)
6. Also capture negative rules (what should NOT happen)
7. Use decision tables for complex conditional logic
8. Save to `$OUTPUT_PATH`
