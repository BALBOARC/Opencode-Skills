# sensitive-data-guard

Protege dados sensíveis do projeto contra exposição ao modelo de IA.

Criptografa automaticamente senhas, tokens, API keys, chaves SSH e PII com
AES-256-CBC antes que o modelo veja o conteúdo. O arquivo original nunca é
modificado.

## Instalação

```bash
bash ~/Opencode-Skills/scripts/install.sh
```

## Funcionamento

1. Bloqueia leitura de credenciais do sistema (`~/.ssh/`, `~/.config/gh/`, etc.)
2. Criptografa valores sensíveis em arquivos do projeto com `encrypt.sh`
3. Decifra no terminal local com `decrypt.sh` (nunca no modelo)

## Dependências

- OpenSSL 3.x
- Perl
- xxd, base64, od (utilitários padrão Linux)
