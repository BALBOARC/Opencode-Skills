#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_SRC="$REPO_DIR/skills"
SKILLS_DEST="${OPENCODE_CONFIG:-$HOME/.config/opencode}/skills"
CONFIG_DEST="${OPENCODE_CONFIG:-$HOME/.config/opencode}"

echo "Instalando skills do Opencode..."
echo "  Origem:  $SKILLS_SRC"
echo "  Destino: $SKILLS_DEST"

mkdir -p "$SKILLS_DEST"

for skill_dir in "$SKILLS_SRC"/*/; do
    skill_name="$(basename "$skill_dir")"
    [ "$skill_name" = "_template" ] && continue

    if [ -f "$skill_dir/SKILL.md" ]; then
        echo "  → Instalando skill: $skill_name"
        mkdir -p "$SKILLS_DEST/$skill_name"

        # Copia SKILL.md
        cp "$skill_dir/SKILL.md" "$SKILLS_DEST/$skill_name/SKILL.md"

        # Copia scripts auxiliares (encrypt.sh, decrypt.sh, etc.)
        for script in "$skill_dir"/*.sh; do
            if [ -f "$script" ]; then
                cp "$script" "$SKILLS_DEST/$skill_name/"
                chmod +x "$SKILLS_DEST/$skill_name/$(basename "$script")"
            fi
        done

        # Copia allowlist se existir
        if [ -f "$skill_dir/allowlist.txt" ]; then
            cp "$skill_dir/allowlist.txt" "$SKILLS_DEST/$skill_name/"
        fi
    fi
done

# Copia configuração se existir no repositório
if [ -f "$REPO_DIR/config/opencode.jsonc" ]; then
    echo "  → Copiando configuração"
    cp "$REPO_DIR/config/opencode.jsonc" "$CONFIG_DEST/opencode.jsonc"
fi

# Gera chave AES-256 para sensitive-data-guard (se não existir)
KEY_FILE="$SKILLS_DEST/sensitive-data-guard/key/.key"
if [ -d "$SKILLS_DEST/sensitive-data-guard" ] && [ ! -f "$KEY_FILE" ]; then
    echo "  → Gerando chave AES-256 para sensitive-data-guard"
    mkdir -p "$(dirname "$KEY_FILE")"
    openssl rand -hex 32 > "$KEY_FILE"
    chmod 600 "$KEY_FILE"
fi

echo ""
echo "✓ Instalação concluída!"
echo "  As skills estarão disponíveis na próxima sessão do Opencode."
