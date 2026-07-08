---
name: git-branch-push
description: >
  Use when the user wants to commit and push to GitHub, creating a new branch instead of pushing directly to main. Automatically extracts the last commit message to name the branch as feature/{description}. Activates on "subir", "push", "commit", "enviar para git", "github", "enviar pro github", "subir pro github".
---

# Git Branch Push

Nunca faz push direto na `main`. Sempre cria uma branch `feature/{descricao}` a partir da mensagem do último commit.

## Regras

- **NUNCA** faça push para `main` ou `master`
- **SEMPRE** crie uma branch nova com prefixo `feature/`
- O nome da branch é extraído da **mensagem do último commit**
- Após o push, informe o usuário com o nome da branch e o comando para abrir PR

## Fluxo

```bash
# 1. Verificar mudanças não commitadas
git status

# 2. Se houver mudanças, perguntar se quer stage+commit
git add -A
git commit -m "<mensagem do usuário>"

# 3. Extrair mensagem do último commit
MSG=$(git log -1 --pretty=%s)

# 4. Sanitizar para nome de branch
BRANCH="feature/$(echo "$MSG" \
  | tr '[:upper:]' '[:lower:]' \
  | sed 's/[^a-z0-9 -]//g' \
  | sed 's/ /-/g' \
  | sed 's/--*/-/g' \
  | sed 's/^-//;s/-$//' \
  | head -c 60)"

# 5. Criar e fazer push da branch
git checkout -b "$BRANCH"
git push -u origin "$BRANCH"

# 6. Informar o usuário
echo "✓ Branch criada: $BRANCH"
echo "✓ Push realizado para origin/$BRANCH"
echo ""
echo "Para abrir um PR no GitHub:"
echo "  gh pr create --fill"
```

## Exemplo

```
$ git commit -m "Adiciona versionamento automático nas skills de análise"
→ branch: feature/adiciona-versionamento-automatico-nas-skills-de-analise
```

## Restrições

- Se já estiver em uma branch que não seja `main`/`master`, avisar e confirmar antes de criar outra
- Se o repositório não tiver remote `origin`, configurar antes do push
- Após o push, voltar para a branch original (`main` ou anterior) se solicitado
