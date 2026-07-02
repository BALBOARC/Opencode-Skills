#!/bin/bash
# decrypt.sh — Decifra blocos [ENC:AES256-CBC:...] em um arquivo.
# Exibe o conteúdo com os valores originais restaurados APENAS no terminal.
# Nada é enviado ao modelo.
#
# Uso: ./decrypt.sh <caminho-do-arquivo>
#       ./decrypt.sh <string-com-bloco-enc>

set -e

KEY_FILE="$HOME/.config/opencode/skills/sensitive-data-guard/key/.key"

if [ ! -f "$KEY_FILE" ]; then
  echo "Chave não encontrada: $KEY_FILE" >&2
  echo "Execute encrypt.sh primeiro para gerar a chave." >&2
  exit 1
fi

KEY=$(cat "$KEY_FILE")

if [ -z "$1" ]; then
  echo "Usage: $0 <file-or-string>" >&2
  exit 1
fi

INPUT="$1"

if [ -f "$INPUT" ]; then
  CONTENT=$(cat "$INPUT")
else
  CONTENT="$INPUT"
fi

# Extrai e decifra cada bloco [ENC:AES256-CBC:iv:ciphertext]
result=$(echo "$CONTENT" | perl -e '
use strict;
use warnings;

my $key = $ARGV[0];
my $content = do { local $/; <STDIN> };

sub decrypt {
    my ($iv_hex, $enc_b64) = @_;
    my $dec = `echo -n "$enc_b64" | openssl enc -aes-256-cbc -d -K $key -iv $iv_hex -base64 -A 2>/dev/null`;
    chomp $dec;
    return $dec;
}

$content =~ s/\[ENC:AES256-CBC:([a-f0-9]{32}):([A-Za-z0-9+\/=]+)\]/ decrypt($1, $2) /ge;
print $content;
' "$KEY")

echo "$result"
