#!/bin/bash
# ensure.sh — Garante o diretório de saída e gera nome versionado.
#
# Uso:
#   ensure.sh "projeto"              → /mnt/d/Opencode/projeto        (cria diretório)
#   ensure.sh "projeto" --v          → /mnt/d/Opencode/projeto/2026-07-08_v1  (cria dir versionado)
#   ensure.sh "projeto" --v "doc.pdf"→ /mnt/d/Opencode/projeto/2026-07-08_v1_doc.pdf
#   ensure.sh                        → /mnt/d/Opencode/Download

BASE="/mnt/d/Opencode"
SUBDIR="${1:-Download}"
SUBDIR="${SUBDIR#/}"
DIR="$BASE/$SUBDIR"
mkdir -p "$DIR"

if [ "${2:-}" != "--v" ]; then
  echo "$DIR"
  exit 0
fi

# ── Versionamento: data + contador incremental ─────────────────────
DATE=$(date +%Y-%m-%d)

MAX_VER=0
for entry in "$DIR/${DATE}_v"*; do
  [ -e "$entry" ] || continue
  n="$(basename "$entry" | grep -oP "${DATE}_v\K[0-9]+")"
  [ -n "$n" ] && [ "$n" -gt "$MAX_VER" ] && MAX_VER=$n
done

VER=$((MAX_VER + 1))
PREFIX="${DATE}_v${VER}"

if [ -n "${3:-}" ]; then
  echo "$DIR/${PREFIX}_${3}"
else
  mkdir -p "$DIR/$PREFIX"
  echo "$DIR/$PREFIX"
fi
