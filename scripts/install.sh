#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_SRC="$REPO_DIR/skills"
SKILLS_DEST="${OPENCODE_CONFIG:-$HOME/.config/opencode}/skills"

echo "Instalando skills do Opencode..."
echo "  Origem:  $SKILLS_SRC"
echo "  Destino: $SKILLS_DEST"

# Cria diretório de skills se não existir
mkdir -p "$SKILLS_DEST"

# Copia cada skill (exceto _template)
for skill_dir in "$SKILLS_SRC"/*/; do
    skill_name="$(basename "$skill_dir")"

    # Pula o template
    [ "$skill_name" = "_template" ] && continue

    if [ -f "$skill_dir/SKILL.md" ]; then
        echo "  → Instalando skill: $skill_name"
        mkdir -p "$SKILLS_DEST/$skill_name"
        cp "$skill_dir/SKILL.md" "$SKILLS_DEST/$skill_name/SKILL.md"

        # Copia scripts auxiliares (.sh) da skill, se houver
        for script in "$skill_dir"/*.sh; do
            if [ -f "$script" ]; then
                cp "$script" "$SKILLS_DEST/$skill_name/"
                chmod +x "$SKILLS_DEST/$skill_name/$(basename "$script")"
            fi
        done
    fi
done

# Verifica/Cria configuração do Opencode
CONFIG_FILE="${OPENCODE_CONFIG:-$HOME/.config/opencode}/opencode.jsonc"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "  → Criando arquivo de configuração: $CONFIG_FILE"
    cat > "$CONFIG_FILE" << 'JSON'
{
  "$schema": "https://opencode.ai/config.json",
  "model": "opencode/big-pickle",
  "skills": {
    "paths": ["~/.config/opencode/skills"]
  }
}
JSON
fi

echo ""
echo "✓ Instalação concluída!"
echo "  As skills estarão disponíveis na próxima sessão do Opencode."
