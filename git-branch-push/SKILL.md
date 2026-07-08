---
name: git-branch-push
description: >
  Use when the user wants to commit and push to GitHub, creating a new branch instead of pushing directly to main. Extracts a short branch name from the first words of the commit message, prefixing with feature/. Activates on "subir", "push", "commit", "enviar para git", "github", "enviar pro github", "subir pro github".
---

# Git Branch Push

Nunca faz push direto na `main`. Sempre cria uma branch `feature/{descricao}` curta extraída do início da mensagem do último commit. O texto completo fica no commit, não no nome da branch.

## Regras

- **NUNCA** faça push para `main` ou `master`
- **SEMPRE** crie uma branch nova com prefixo `feature/`
- O nome da branch usa **apenas as primeiras 3-4 palavras** da mensagem do commit
- Acentos são convertidos para vogais sem acento (á→a, ç→c, é→e, etc.)
- Após o push, informe o usuário com o nome da branch e o comando para abrir PR

## Fluxo

```bash
# 1. Verificar mudanças não commitadas
git status

# 2. Se houver mudanças, perguntar se quer stage+commit
git add -A
git commit -m "<mensagem do usuário>"

# 3. Extrair as primeiras 4 palavras do último commit
MSG=$(git log -1 --pretty=%s)
SHORT=$(echo "$MSG" | awk '{for(i=1;i<=NF&&i<=4;i++) printf "%s%s", (i>1?FS:""), $i; print ""}')

# 4. Sanitizar para nome de branch
BRANCH="feature/$(echo "$SHORT" \
  | tr '[:upper:]' '[:lower:]' \
  | sed 's/á/a/g; s/à/a/g; s/â/a/g; s/ã/a/g' \
  | sed 's/é/e/g; s/ê/e/g' \
  | sed 's/í/i/g' \
  | sed 's/ó/o/g; s/ô/o/g; s/õ/o/g' \
  | sed 's/ú/u/g; s/ü/u/g' \
  | sed 's/ç/c/g' \
  | sed 's/[^a-z0-9 -]//g' \
  | sed 's/ /-/g; s/--*/-/g; s/^-//; s/-$//' \
  | head -c 60)"

# 5. Garantir que está na main e atualizar antes de criar branch
git checkout main
git pull origin main

# 6. Criar e fazer push da branch
git checkout -b "$BRANCH"
git push -u origin "$BRANCH"

# 7. Voltar para main
git checkout main

# 8. Informar o usuário
echo "✓ Branch criada: $BRANCH"
echo "✓ Push realizado para origin/$BRANCH"
echo ""
echo "Para abrir um PR no GitHub:"
echo "  gh pr create --fill"
```

## Exemplo

```
$ git commit -m "Adiciona versionamento automático nas skills de análise"
→ branch: feature/adiciona-versionamento-automatico-nas

$ git commit -m "Corrige bug na validação de CPF do formulário"
→ branch: feature/corrige-bug-na-validacao
```

## Restrições

- Se a branch `feature/...` já existir no remote, abortar e avisar o usuário
- Se o repositório não tiver remote `origin`, configurar antes do push
- Sempre volta para `main` após o push
