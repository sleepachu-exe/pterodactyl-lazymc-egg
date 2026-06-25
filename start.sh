#!/bin/bash
# ============================================================
#  Paper + LazyMC Hibernation — Start Script
#  Pterodactyl har baar server start pe yeh run karta hai
# ============================================================

PUBLIC_PORT=${SERVER_PORT:-25565}
MEMORY=${SERVER_MEMORY:-2048}

echo "=================================================="
echo "  LazyMC Hibernation Server"
echo "  Public Port : $PUBLIC_PORT"
echo "  Java Memory : ${MEMORY}MB"
echo "  Sleep after : 3 min (no players)"
echo "=================================================="

# Patch public port in lazymc.toml
sed -i "/\[public\]/,/\[/{s|^address = .*|address = \"0.0.0.0:${PUBLIC_PORT}\"|;}" lazymc.toml

# Patch Java memory in lazymc.toml
sed -i "s|-Xmx[0-9]*M|-Xmx${MEMORY}M|g" lazymc.toml

echo ">>> lazymc.toml patched OK (port=$PUBLIC_PORT, mem=${MEMORY}M)"
echo ">>> Starting LazyMC..."

exec ./lazymc start
