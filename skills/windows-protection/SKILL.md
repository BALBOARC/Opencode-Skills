---
name: windows-protection
description: Use ONLY when working with Windows system files (under /mnt/c/, especially /mnt/c/Windows/, /mnt/c/Program Files/, /mnt/c/Program Files (x86)/, System32, or any system-protected paths). Activates safety guardrails to prevent corrupting the Windows OS through WSL. Must NOT be used for normal project code outside these paths.
---

# Windows Protection Skill

When this skill is active, the following safety rules MUST be enforced before every operation targeting Windows files:

## Permission rules (applied automatically)

- `bash`: `{ "rm *": "deny", "del *": "deny", "rmdir *": "deny", "chmod *": "ask", "chown *": "deny", "mkfs *": "deny", "dd *": "deny", "*": "ask" }`
- `edit`: `"ask"` — every file modification must be confirmed
- `write`: `"ask"` — every new file creation must be confirmed
- `external_directory`: `{ "/mnt/c/Windows/**": "deny", "/mnt/c/Program Files/**": "deny", "/mnt/c/Program Files (x86)/**": "deny", "/mnt/c/Users/*/AppData/**": "ask", "*": "allow" }`

## Mandatory safety checks before any Bash command

Before running ANY shell command that touches `/mnt/c/`, the tool must verify:

1. **Dry-run first** — simulate the command with `--dry-run` or equivalent when available
2. **Never pipe to `sudo`** — using `sudo` to force-write Windows files from WSL can corrupt the NTFS volume
3. **No recursive force-delete** — `rm -rf`, `del /f /s`, `rmdir /s /q` are strictly forbidden on any path under `/mnt/c/`
4. **WSL + Windows path awareness** — Windows paths use backslashes; WSL exposes them under `/mnt/<drive>/`. Always use the WSL path form. Never use `C:\` directly in shell commands.

## File editing safeguards

1. **Always read the file first** — confirm the user's intent before editing Windows config files
2. **Backup before edit** — before modifying any file under `/mnt/c/`, create a `.backup` copy:
   ```bash
   cp "/mnt/c/path/to/file" "/mnt/c/path/to/file.backup.$(date +%Y%m%d%H%M%S)"
   ```
3. **Prefer non-destructive tools** — prefer `reg query` over `reg delete`, `copy` over `move`, append-only changes over rewrites
4. **Never edit locked/system files** — if a file is in use by Windows, do not force-overwrite it

## Registry (reg.exe) safety

1. **Export before editing** — always run `reg export` before `reg add` or `reg delete`
2. **Use `reg add` with `/f` only after confirmation** — force flags bypass safety checks in Windows
3. **Prefer HKCU over HKLM** — Current User hive is safer than Local Machine

## Rollback procedure

If something goes wrong:
1. Stop all WSL operations touching Windows files immediately
2. Restore from backup: `cp "/mnt/c/path/to/file.backup.*" "/mnt/c/path/to/file"`
3. If registry was modified, import the exported `.reg` file
4. Run `sfc /scannow` from a Windows Command Prompt (not WSL) to repair system files

## Risk explanations (always cite when asking permission)

When the user needs to approve an action, briefly state the risk in 1 sentence.

| Category | Example | Risk |
|----------|---------|------|
| `Dism.exe /StartComponentCleanup` | Limpeza de componentes do Windows | Seguro via ferramenta oficial, mas impede desinstalação de updates recentes (últimos ~30 dias) |
| `cleanmgr` | Limpeza de disco do Windows | Seguro via ferramenta oficial — remove apenas arquivos temporários e obsoletos |
| `reg.exe add/delete` | Modificação no registro do Windows | Pode quebrar configurações ou apps se o registro for alterado incorretamente |
| `rm/del` em `/mnt/c/` | Apagar arquivos manualmente | Pode corromper o NTFS ou deixar o sistema instável se remover arquivo protegido |
| `chmod` em `/mnt/c/` | Alterar permissões no NTFS | Permissões Unix não se aplicam corretamente ao NTFS — pode corromper metadados |
| `> /dev/sda` ou `dd` | Escrita direta em disco | Corrompe a tabela de partições — torna o Windows não inicializável |
| Editar arquivos do Windows | Alterar configs do sistema | Pode quebrar funcionalidades (boot, serviços, drivers) |

If the action is safe (read-only analysis, relatório, consulta), just say it's read-only — no need for risk explanation.

## Emergency override

The user can explicitly type `OVERRIDE WINDOWS PROTECTION` to bypass these guards for a single operation. This should be followed by a confirmation question before executing.
