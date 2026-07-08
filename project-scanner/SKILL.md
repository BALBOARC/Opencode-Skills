---
name: project-scanner
description: Use when you need to discover a project's structure, identify languages, frameworks, build systems, architectural patterns, modules, entities, services, controllers, and data models. Activates on "scan project", "descobrir estrutura", "mapear projeto", "project discovery". Use ONLY for the discovery/mapping phase; do NOT use for extracting business rules or compliance analysis.
---

# Project Scanner

Scan the target project directory and produce a structured mapping.

## Output

All files saved under **`/mnt/d/Opencode/{project-name}/`** with automatic versioning.

```
/mnt/d/Opencode/{project-name}/
└── {YYYY-MM-DD}_v{N}_scanner-output.json
```

Cada execução gera um novo arquivo versionado — execuções anteriores nunca são sobrescritas.

## Output format — `scanner-output.json`

```json
{
  "projectName": "...",
  "rootDir": "/path/to/project",
  "language": "...",
  "framework": "...",
  "buildSystem": "...",
  "architecturalPattern": "MVC | DDD | Clean Architecture | Hexagonal | ...",
  "modules": [
    {
      "name": "...",
      "path": "...",
      "type": "domain | application | infrastructure | presentation",
      "entities": ["EntityName", "..."],
      "services": ["ServiceName", "..."],
      "controllers": ["ControllerName", "..."],
      "repositories": ["RepositoryName", "..."]
    }
  ],
  "configFiles": ["package.json", "..."],
  "testFramework": "...",
  "dataModel": {
    "entities": [{"name": "...", "fields": ["..."]}],
    "relationships": ["Entity1 -> Entity2"]
  },
  "apiEndpoints": [
    {"method": "GET", "path": "/api/...", "controller": "..."}
  ]
}
```

## Workflow

1. Extract project name from target path: `basename "$1"`
2. Create output directory with versioning:
   ```bash
   ENSURE_SCRIPT=~/.config/opencode/skills/opencode-output-path/ensure.sh
   if [ -f "$ENSURE_SCRIPT" ]; then
       OUTPUT_PATH=$(bash "$ENSURE_SCRIPT" "{project-name}" --v "scanner-output.json")
   else
       mkdir -p "/mnt/d/Opencode/{project-name}"
       OUTPUT_PATH="/mnt/d/Opencode/{project-name}/scanner-output.json"
   fi
   ```
3. List root directory structure
4. Identify language(s), framework(s), build system from config files (`package.json`, `pom.xml`, `Cargo.toml`, `go.mod`, `Gemfile`, `setup.py`, `composer.json`, `Makefile`)
5. Detect architectural pattern from package structure
6. For each major module: list entities, services, controllers, repositories
7. Identify test framework and test locations
8. Map API endpoints if applicable
9. Save output to `$OUTPUT_PATH`
