#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP="$ROOT/apps/openchatcut"
RUNTIME="$ROOT/.runtime"
mkdir -p "$RUNTIME" "$HOME/.config/blindspot"

TOKEN_FILE="$HOME/.config/blindspot/openchatcut-mcp-token"
if [[ ! -s "$TOKEN_FILE" ]]; then
  umask 077
  python3 -c 'import secrets; print(secrets.token_urlsafe(48))' > "$TOKEN_FILE"
  chmod 600 "$TOKEN_FILE"
fi
export OPENCHATCUT_MCP_TOKEN="$(cat "$TOKEN_FILE")"

# Codespaces forwards the editor over HTTPS; tell OpenChatCut which origin to trust.
if [[ -n "${CODESPACE_NAME:-}" && -n "${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-}" ]]; then
  export OPENCHATCUT_EDITOR_URL="https://${CODESPACE_NAME}-5199.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
fi

start_if_down() {
  local name="$1" pidfile="$2" logfile="$3"
  shift 3
  if [[ -s "$pidfile" ]] && kill -0 "$(cat "$pidfile")" 2>/dev/null; then
    echo "$name est déjà démarré (PID $(cat "$pidfile"))."
    return
  fi
  nohup "$@" > "$logfile" 2>&1 < /dev/null &
  echo "$!" > "$pidfile"
  echo "$name démarré (PID $!)."
}

start_if_down "Blender MCP headless" "$RUNTIME/blender-mcp.pid" "$RUNTIME/blender-mcp.log" \
  blender --background --python "$ROOT/scripts/blender_mcp_bootstrap.py"

start_if_down "OpenChatCut" "$RUNTIME/openchatcut.pid" "$RUNTIME/openchatcut.log" \
  bash -lc "cd '$APP' && npm run dev -- --host 0.0.0.0"

for attempt in $(seq 1 60); do
  if curl --silent --fail http://127.0.0.1:5199/ >/dev/null; then
    echo "OpenChatCut répond sur le port 5199. Codespaces ouvrira l'interface dans le navigateur."
    break
  fi
  sleep 2
done
if ! curl --silent --fail http://127.0.0.1:5199/ >/dev/null; then
  echo "OpenChatCut ne répond pas encore. Consulte $RUNTIME/openchatcut.log" >&2
fi

if [[ -z "${GROQ_API_KEY:-}" ]]; then
  echo "Attention : GROQ_API_KEY n'est pas présent dans l'environnement de ce Codespace." >&2
else
  echo "Le secret GROQ_API_KEY est détecté (sa valeur n'est pas affichée)."
fi
