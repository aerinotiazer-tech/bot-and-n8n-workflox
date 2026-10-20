#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOKEN_FILE="$HOME/.config/blindspot/openchatcut-mcp-token"

if [[ ! -s "$TOKEN_FILE" ]]; then
  echo "Le jeton local n'existe pas encore. Lance d'abord : bash .devcontainer/start-services.sh" >&2
  exit 1
fi
if [[ -z "${GROQ_API_KEY:-}" ]]; then
  echo "GROQ_API_KEY absent : ajoute-le comme secret Codespaces du dépôt, puis recrée/redémarre le Codespace." >&2
  exit 1
fi

export OPENCHATCUT_MCP_TOKEN="$(cat "$TOKEN_FILE")"
cd "$ROOT"
exec opencode
