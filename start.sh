#!/bin/bash
# ============================================================
#  Paper + LazyMC Hibernation — Start Script
#  Downloaded fresh from GitHub on every server start.
#  Repo: https://github.com/sleepachu-exe/pterodactyl-lazymc-egg
# ============================================================
set -euo pipefail

GITHUB_RAW="https://raw.githubusercontent.com/sleepachu-exe/pterodactyl-lazymc-egg/main"

# Read Pterodactyl environment variables (with safe defaults)
PUBLIC_PORT="${SERVER_PORT:-25565}"
MEMORY="${SERVER_MEMORY:-2048}"
JARFILE="${SERVER_JARFILE:-server.jar}"

echo ""
echo "==========================================="
echo "  LazyMC Hibernation Server"
echo "  Public Port : ${PUBLIC_PORT}"
echo "  Java Memory : ${MEMORY}MB"
echo "  Server Jar  : ${JARFILE}"
echo "  Sleep After : 3 min idle"
echo "==========================================="
echo ""

## ── Sanity checks ────────────────────────────────────────
if [ ! -f "./lazymc" ]; then
    echo "ERROR: lazymc binary not found!"
    echo "       Please reinstall the server."
    exit 1
fi

if [ ! -f "${JARFILE}" ]; then
    echo "ERROR: ${JARFILE} not found!"
    echo "       Please reinstall or check SERVER_JARFILE variable."
    exit 1
fi

## ── Ensure lazymc.toml exists ────────────────────────────
if [ ! -f lazymc.toml ]; then
    echo ">>> lazymc.toml missing — downloading from GitHub..."
    curl -sSL -o lazymc.toml "${GITHUB_RAW}/lazymc.toml"
fi

## ── Patch lazymc.toml with runtime values ────────────────

# 1. Public listen address (Pterodactyl's allocated port)
sed -i "/^\[public\]/,/^\[/{s|^address = .*|address = \"0.0.0.0:${PUBLIC_PORT}\"|;}" lazymc.toml

# 2. Java heap memory
sed -i "s|-Xms[0-9]*[Mm]|-Xms128M|g" lazymc.toml
sed -i "s|-Xmx[0-9]*[Mm]|-Xmx${MEMORY}M|g" lazymc.toml

# 3. Server jar filename
sed -i "s|-jar [^ ]*\.jar|-jar ${JARFILE}|g" lazymc.toml

echo ">>> lazymc.toml patched:"
echo "    port=${PUBLIC_PORT} | memory=${MEMORY}MB | jar=${JARFILE}"

## ── Launch LazyMC ────────────────────────────────────────
echo ">>> Starting LazyMC..."
echo ""
exec ./lazymc start
