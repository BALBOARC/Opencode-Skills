#!/bin/bash
# encrypt.sh — Lê um arquivo e imprime no stdout com valores sensíveis
# criptografados com AES-256-CBC. O arquivo original NUNCA é modificado.
# O modelo big-pickle vê apenas blocos [ENC:...], nunca os valores reais.
#
# Uso: ./encrypt.sh <caminho-do-arquivo>

set -e

FILE="$1"
KEY_DIR="$HOME/.config/opencode/skills/sensitive-data-guard/key"
KEY_FILE="$KEY_DIR/.key"

if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  echo "Usage: $0 <file>" >&2
  exit 1
fi

# Gera chave AES-256 na primeira execução
if [ ! -f "$KEY_FILE" ]; then
  mkdir -p "$KEY_DIR"
  openssl rand -hex 32 > "$KEY_FILE"
  chmod 600 "$KEY_FILE"
  echo "[KEY GENERATED] $KEY_FILE" >&2
fi

KEY=$(cat "$KEY_FILE")

exec perl -e '
use strict;
use warnings;

my $file = $ARGV[0];
my $key  = $ARGV[1];

open(my $fh, "<", $file) or die "Cannot open $file: $!";
my $content = do { local $/; <$fh> };
close($fh);

sub encrypt {
    my ($value) = @_;
    # Escape o valor para shell (simples: remove aspas duplas internas que quebram)
    (my $safe = $value) =~ s/"/\\"/g;
    my $iv_hex = `openssl rand -hex 16`;
    chomp $iv_hex;
    my $enc = `echo -n "$safe" | openssl enc -aes-256-cbc -K $key -iv $iv_hex -base64 -A 2>/dev/null`;
    chomp $enc;
    return "[ENC:AES256-CBC:${iv_hex}:${enc}]";
}

# Cada pattern: [qr/regex/, $modo]
#   modo=1 -> preserva $1 (prefixo), criptografa $2 (valor)
#   modo=0 -> criptografa o match inteiro

my @patterns = (

    # KEY="value", KEY='value', KEY=value (sem aspas)
    [qr/((?:password|passwd|pwd|senha|secret|token|api[_-]?key|apikey|api_key|credentials?|auth_token|access_key|secret_key|private_key|db_password|redis_url|sentry_dsn|jwt_secret|session_secret|mail_password|oauth_token|client_secret|client_id|connection_string|conn_string|connstr)\s*[=:]\s*["'"'"']?)([^"'"'"'\s]{4,})/i, 1],

    # Bearer tokens
    [qr/(Bearer\s+)([A-Za-z0-9._\/+-]{20,})/, 1],

    # JWT tokens
    [qr/(eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,})/, 0],

    # GitHub tokens (ghp_, ghs_, ghu_, gho_)
    [qr/(gh[opsu]_[A-Za-z0-9]{36,})/, 0],

    # OpenAI API keys
    [qr/(sk-[A-Za-z0-9]{20,})/, 0],

    # Google API keys
    [qr/(AIza[0-9A-Za-z_-]{35})/, 0],

    # Stripe keys
    [qr/((?:sk|pk)_(?:live|test)_[A-Za-z0-9]{24,})/, 0],

    # URLs com credenciais embutidas
    [qr/(https?:\/\/)([^:@\s]+:[^@\s]+@)/, 1],

    # Recovery codes (linhas com códigos alfanuméricos agrupados)
    [qr/^([A-Z0-9]{8,12}(?:[- ]?[A-Z0-9]{8,12}){1,4})$/m, 0],

    # Chaves privadas multi-linha
    [qr/(-----BEGIN\s+(?:RSA|EC|DSA|OPENSSH|PGP)\s+PRIVATE\s+KEY-----.*?-----END\s+(?:RSA|EC|DSA|OPENSSH|PGP)\s+PRIVATE\s+KEY-----)/s, 0],

    # Chaves públicas multi-linha (OPNSSH, RSA, etc)
    [qr/(-----BEGIN\s+(?:RSA|EC|DSA|OPENSSH|PGP)\s+PUBLIC\s+KEY-----.*?-----END\s+(?:RSA|EC|DSA|OPENSSH|PGP)\s+PUBLIC\s+KEY-----)/s, 0],
);

for my $pat_ref (@patterns) {
    my ($regex, $keep_group1) = @$pat_ref;

    if ($keep_group1) {
        $content =~ s{$regex}{ my $v = $2; $1 . encrypt($v) }sge;
    } else {
        $content =~ s{$regex}{ encrypt($&) }sge;
    }
}

print $content;
' "$FILE" "$KEY"
