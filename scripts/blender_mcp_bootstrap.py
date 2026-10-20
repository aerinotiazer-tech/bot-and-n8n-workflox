"""Démarre l'API MCP de DCC-MCP Blender sur loopback pour Codespaces.

Le serveur est construit avec les API publiques de dcc-mcp-blender. Le port
9765 n'est pas forwardé publiquement; OpenCode y accède depuis le même
Codespace. Blender tourne en mode --background, sans session graphique.
"""
from __future__ import annotations

import tempfile
from pathlib import Path

from dcc_mcp_blender.host import BlenderHost
from dcc_mcp_blender.server import BlenderMcpServer
from dcc_mcp_core.host import BlockingDispatcher

PORT = 9765
REGISTRY = Path(tempfile.mkdtemp(prefix="blindspot-dcc-registry-"))

dispatcher = BlockingDispatcher()
server = BlenderMcpServer(
    port=PORT,
    gateway_port=0,
    gateway_remote_port=0,
    registry_dir=str(REGISTRY),
    enable_gateway_failover=False,
    dispatcher=dispatcher,
)
server.start()
server.discover_skills()
print(f"BLINDSPOT_BLENDER_MCP_URL={server.mcp_url}", flush=True)
try:
    BlenderHost(dispatcher).run_headless()
finally:
    server.stop()
