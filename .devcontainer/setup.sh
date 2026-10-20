#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP="$ROOT/apps/openchatcut"
BLENDER_PYTHON="$BLENDER_HOME/4.5/python/bin/python3.11"

if [[ ! -d "$APP/.git" && ! -f "$APP/.git" ]]; then
  git -C "$ROOT" submodule update --init --depth 1 apps/openchatcut
fi

if [[ "$(node -p 'Number(process.versions.node.split(".")[0])')" -ne 24 ]]; then
  echo "OpenChatCut exige Node.js 24.x. Version trouvée : $(node -v)" >&2
  exit 1
fi

printf '\n== Correctif sécurité npm ciblé OpenChatCut ==\n'
cd "$APP"
# The pinned upstream lockfile currently resolves proxy-addr < 2.0.8 (critical
# GHSA-jqcg-44mw-7w3h). Keep the upstream source untouched, but pin its patched
# transitive dependency in this Codespace install and regenerate the local lock.
npm pkg set 'overrides.proxy-addr=2.0.8'
npm install --package-lock-only --ignore-scripts --no-audit

printf '\n== Installation OpenChatCut (CPU, sans paquet CUDA optionnel) ==\n'
ONNXRUNTIME_NODE_INSTALL=skip npm ci

printf '\n== Installation DCC-MCP Blender dans son Python embarqué ==\n'
if [[ ! -x "$BLENDER_PYTHON" ]]; then
  echo "Python Blender introuvable : $BLENDER_PYTHON" >&2
  exit 1
fi
"$BLENDER_PYTHON" -m ensurepip --upgrade
"$BLENDER_PYTHON" -m pip install --upgrade pip
"$BLENDER_PYTHON" -m pip install 'dcc-mcp-blender==0.2.22'

printf '\n== Vérification des binaires ==\n'
blender --version | head -n 1
ffmpeg -version | head -n 1
"$BLENDER_PYTHON" -c 'import dcc_mcp_blender, dcc_mcp_core; print("DCC-MCP Blender imports OK")'
opencode --version

mkdir -p "$ROOT/projects" "$ROOT/.runtime"
echo "Installation terminée. Les médias et exports de production restent hors Git."