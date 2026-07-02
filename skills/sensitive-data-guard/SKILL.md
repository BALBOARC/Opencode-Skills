---
name: sensitive-data-guard
description: >
  ACTIVATES ON EVERY PROJECT FILE READ. Encrypts sensitive data (passwords, tokens, API keys, PII, connection strings, SSH keys, recovery codes) with AES-256-CBC before the model sees them. System credential files are BLOCKED entirely by opencode permission system. The project on disk is NEVER modified. Activates on "dados sensíveis", "proteção de dados", "sensitive data", "secrets", "credentials", "PII", "LGPD", "segurança", "vazar", "leak", "criptografar", "encrypt", "big-pickle".
---

# Sensitive Data Guard

Protege seus dados sensíveis contra exposição ao modelo de IA.
A proteção é **automática** — zero esforço do usuário.

Válido para qualquer modelo configurado no opencode.

## Permission rules (aplicadas automaticamente pelo opencode)

Configure no `~/.config/opencode/opencode.jsonc`:

```jsonc
{
  "read": {
    "*": "allow",
    "~/.ssh/*": "deny",
    "~/.config/gh/*": "deny",
    "~/.aws/*": "deny",
    "~/.azure/*": "deny",
    "~/.netrc": "deny",
    "~/.git-credentials": "deny",
    "~/Downloads/recovery-codes*": "deny",
    "~/*.pem": "deny",
    "~/*.key": "deny"
  },
  "bash": {
    "*": "ask",
    "cat ~/.ssh/*": "deny",
    "cat ~/.config/gh/*": "deny",
    "cat ~/.aws/*": "deny",
    "cat ~/.netrc": "deny",
    "cat ~/.git-credentials": "deny",
    "cat ~/Downloads/recovery-codes*": "deny",
    "cat ~/*.pem": "deny",
    "cat ~/*.key": "deny",
    "git *": "allow",
    "grep *": "allow",
    "ls *": "allow",
    "find *": "allow",
    "npm *": "allow",
    "node *": "allow",
    "perl *": "allow",
    "openssl *": "allow",
    "which *": "allow",
    "mkdir *": "allow",
    "chmod *": "allow",
    "rm *": "allow",
    "head *": "allow",
    "tail *": "allow",
    "cat *": "allow",
    "echo *": "ask",
    "printf *": "ask"
  },
  "external_directory": {
    "*": "ask",
    "~/.ssh/**": "deny",
    "~/.config/gh/**": "deny",
    "~/.aws/**": "deny",
    "~/.azure/**": "deny",
    "~/.netrc": "deny",
    "~/.git-credentials": "deny",
    "~/Downloads/recovery-codes*": "deny",
    "~/*.pem": "deny",
    "~/*.key": "deny",
    "~/.config/opencode/skills/sensitive-data-guard/key/**": "deny",
    "/mnt/c/Users/roger/Source/**": "allow",
    "/mnt/c/Users/roger/Documents/**": "allow"
  },
  "skill": {
    "*": "ask",
    "sensitive-data-guard": "allow"
  }
}
```

## Camada 2 — Criptografia em arquivos do projeto

Quando o agente ler arquivos do projeto, deve SEMPRE usar:

```bash
bash ~/.config/opencode/skills/sensitive-data-guard/encrypt.sh <arquivo>
```

Isso criptografa valores como `DB_PASSWORD=minhaSenha` → `DB_PASSWORD=[ENC:AES256-CBC:...]`
e imprime no stdout. **O arquivo original no disco nunca é alterado.**

## Padrões criptografados

| Categoria | Exemplos |
|---|---|
| Senhas e secrets | `password=`, `secret=`, `token=`, `api_key=`, `credentials=` |
| Bearer tokens | `Bearer eyJ...` |
| JWT | `eyJ...` três partes |
| GitHub tokens | `ghp_`, `ghs_`, `ghu_`, `gho_` |
| API keys | OpenAI `sk-...`, Google `AIza...`, Stripe |
| Connection strings | URLs com `user:pass@` |
| Chaves privadas | Blocos `-----BEGIN * PRIVATE KEY-----` |
| Recovery codes | Códigos alfanuméricos agrupados |

## Ver valor original (no terminal, nunca no modelo)

```bash
bash ~/.config/opencode/skills/sensitive-data-guard/decrypt.sh <arquivo>
```

## Exceções

- `test/`, `spec/`, `__tests__/`, `fixtures/`, `mock*/`
- `allowlist.txt` — valores mock configuráveis

## Emergency Override

Digite `OVERRIDE SENSITIVE DATA GUARD` para liberar UM acesso específico.
