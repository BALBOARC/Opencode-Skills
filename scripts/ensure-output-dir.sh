#!/bin/bash
# ensure-output-dir.sh — Garante que o diretório de saída D:\Opencode\ existe
#
# Uso:
#   ensure-output-dir.sh                    → cria D:\Opencode\Download\
#   ensure-output-dir.sh "meu-projeto"      → cria D:\Opencode\meu-projeto\
#   ensure-output-dir.sh "meu-projeto/docs" → cria D:\Opencode\meu-projeto\docs\

set -e

BASE="/mnt/d/Opencode"
SUBDIR="${1:-Download}"

# Remove barras no início se houver
SUBDIR="${SUBDIR#/}"

TARGET="$BASE/$SUBDIR"

if [ ! -d "$TARGET" ]; then
  mkdir -p "$TARGET"
  echo "✓ Criado: $TARGET"
else
  echo "✓ Já existe: $TARGET"
fi

echo "$TARGET"
