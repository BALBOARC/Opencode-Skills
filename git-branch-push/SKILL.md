---
name: git-branch-push
description: >
  Use when the user wants to commit and push to GitHub, creating a new branch instead of pushing directly to main. Parses conventional commit messages (feat:, fix:, chore:, docs:, refactor:, test:, perf:) to determine the branch prefix. Defaults to feature/ when no prefix is detected. Activates on "subir", "push", "commit", "enviar para git", "github", "enviar pro github", "subir pro github".
---

# Git Branch Push

Nunca faz push direto na `main`. Sempre cria uma branch a partir da mensagem do último commit, seguindo **Conventional Commits** e boas práticas de Git.

## Regras

- **NUNCA** faça push para `main` ou `master`
- **SEMPRE** crie uma branch nova
- O commit **DEVE** seguir o formato Conventional Commits: `tipo: descrição`
- O prefixo da branch é extraído do `tipo` do commit
- O nome da branch usa **apenas as 3-4 primeiras palavras** da `descrição` (após o `:`)
- Acentos são convertidos (á→a, ç→c, é→e)
- Branch em **minúsculas**, palavras separadas por hífen

### Mapeamento tipo → prefixo da branch

| Commit | Prefixo da branch |
|---|---|
| `feat:` | `feature/` |
| `fix:` | `fix/` |
| `chore:` | `chore/` |
| `docs:` | `docs/` |
| `refactor:` | `refactor/` |
| `test:` | `test/` |
| `perf:` | `perf/` |
| `style:` | `style/` |
| `ci:` | `ci/` |
| Outros / sem tipo | `feature/` |

## Fluxo

```bash
# 1. Verificar se há mudanças não commitadas
git status

# 2. Stages as alterações (sem commit ainda)
git add -A

# 3. Extrair tipo e descrição da mensagem fornecida pelo usuário
#    O usuário informa: "<tipo>: <descrição>"
#    Exemplo: "feat: adiciona login com Google"
# O agente deve construir a mensagem no formato:
# "<tipo>: <descrição curta>"
# Exemplo: "feat: adiciona login com Google"
MSG="<tipo>: <descrição>"  # substituir pelos valores reais

# Extrai tipo e descrição
if echo "$MSG" | grep -qE '^(feat|fix|chore|docs|refactor|test|perf|style|ci)(\(.+\))?: '; then
  TIPO=$(echo "$MSG" | sed -nE 's/^([a-z]+).*: .*/\1/p')
  DESCRICAO=$(echo "$MSG" | sed -nE 's/^[a-z]+(\(.+\))?: //p')
else
  TIPO="feature"
  DESCRICAO="$MSG"
fi

# Mapeia tipo para prefixo da branch
case "$TIPO" in
  feat)     PREFIXO="feature" ;;
  fix)      PREFIXO="fix" ;;
  chore)    PREFIXO="chore" ;;
  docs)     PREFIXO="docs" ;;
  refactor) PREFIXO="refactor" ;;
  test)     PREFIXO="test" ;;
  perf)     PREFIXO="perf" ;;
  style)    PREFIXO="style" ;;
  ci)       PREFIXO="ci" ;;
  *)        PREFIXO="feature" ;;
esac

# Pega as 4 primeiras palavras da descrição para o nome da branch
SHORT=$(echo "$DESCRICAO" | awk '{for(i=1;i<=NF&&i<=4;i++) printf "%s%s", (i>1?FS:""), $i; print ""}')

# Sanitiza para nome de branch
NOME=$(echo "$SHORT" \
  | tr '[:upper:]' '[:lower:]' \
  | sed 's/á/a/g; s/à/a/g; s/â/a/g; s/ã/a/g' \
  | sed 's/é/e/g; s/ê/e/g' \
  | sed 's/í/i/g' \
  | sed 's/ó/o/g; s/ô/o/g; s/õ/o/g' \
  | sed 's/ú/u/g; s/ü/u/g' \
  | sed 's/ç/c/g' \
  | sed 's/[^a-z0-9 -]//g' \
  | sed 's/ /-/g; s/--*/-/g; s/^-//; s/-$//' \
  | head -c 60)

BRANCH="${PREFIXO}/${NOME}"

# 4. Verificar se a branch já existe
if git ls-remote --exit-code origin "$BRANCH" > /dev/null 2>&1; then
  echo "✗ Branch '$BRANCH' já existe no remote."
  echo "  Escolha um nome diferente ou faça o commit em outra branch."
  exit 1
fi

# 5. Atualizar main e criar branch a partir dela
git switch main
git pull origin main --rebase

# 6. Criar branch e fazer o commit nela
git switch -c "$BRANCH"
git commit -m "$MSG"
git push -u origin "$BRANCH"

# 7. Voltar para main
git switch main

# 8. Informar o usuário
echo "✓ Commit : $MSG"
echo "✓ Branch : $BRANCH"
echo "✓ Push   : origin/$BRANCH"
echo ""
echo "Para abrir PR:"
echo "  gh pr create --fill"
```

## Exemplos

```
$ git commit -m "feat: adiciona login com Google OAuth"
→ branch: feature/adiciona-login-com-google

$ git commit -m "fix: corrige validação de CPF duplicado"
→ branch: fix/corrige-validacao-de-cpf

$ git commit -m "refactor: extrai camada de serviço de usuário"
→ branch: refactor/extrai-camada-de-servico

$ git commit -m "docs: atualiza README com instruções de setup"
→ branch: docs/atualiza-readme-com-instrucoes

$ git commit -m "chore: atualiza dependências do projeto"
→ branch: chore/atualiza-dependencias-do-projeto
```

## Restrições

- Se a branch já existir no remote, abortar e sugerir nome alternativo
- Se o repositório não tiver remote `origin`, configurar antes do push
- Sempre usa `git switch` (moderno) em vez de `git checkout`
- Sempre faz `pull --rebase` para evitar merge commits desnecessários
- Nunca usa `--force` ou `--force-with-lease` — branch é sempre nova
- Volta para `main` após o push
