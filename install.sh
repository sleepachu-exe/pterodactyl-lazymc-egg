#!/bin/bash
# ============================================================
#  Paper + LazyMC Hibernation — Install Script
#  Repo: https://github.com/sleepachu-exe/pterodactyl-lazymc-egg
#  Runs ONCE when server is installed via Pterodactyl panel.
# ============================================================
set -euo pipefail

GITHUB_RAW="https://raw.githubusercontent.com/sleepachu-exe/pterodactyl-lazymc-egg/main"

echo ""
echo "=================================================="
echo "  Paper + LazyMC Install Script"
echo "  Repo: sleepachu-exe/pterodactyl-lazymc-egg"
echo "=================================================="
echo ""

## ── Dependencies ─────────────────────────────────────────
apt-get update -y -q
apt-get install -y -q curl jq file

## ── Setup working directory ──────────────────────────────
mkdir -p /mnt/server
cd /mnt/server

## ── Defaults ─────────────────────────────────────────────
SERVER_JARFILE="${SERVER_JARFILE:-server.jar}"
MINECRAFT_VERSION="${MINECRAFT_VERSION:-latest}"
BUILD_NUMBER="${BUILD_NUMBER:-latest}"

## ── PaperMC ──────────────────────────────────────────────
echo ">>> Resolving PaperMC version..."
if [ "${MINECRAFT_VERSION}" = "latest" ]; then
    MINECRAFT_VERSION=$(curl -sSL https://api.papermc.io/v2/projects/paper | jq -r '.versions[-1]')
fi

if [ "${BUILD_NUMBER}" = "latest" ]; then
    BUILD_NUMBER=$(curl -sSL "https://api.papermc.io/v2/projects/paper/versions/${MINECRAFT_VERSION}" | jq -r '.builds[-1]')
fi

echo ">>> Downloading Paper ${MINECRAFT_VERSION} build ${BUILD_NUMBER}..."
curl -sSL -o "${SERVER_JARFILE}" \
    "https://api.papermc.io/v2/projects/paper/versions/${MINECRAFT_VERSION}/builds/${BUILD_NUMBER}/downloads/paper-${MINECRAFT_VERSION}-${BUILD_NUMBER}.jar"
echo ">>> Paper downloaded: ${SERVER_JARFILE} ✓"

## ── LazyMC Binary ────────────────────────────────────────
echo ">>> Fetching latest LazyMC release..."
GH_JSON=$(curl -sSL "https://api.github.com/repos/timvisee/lazymc/releases/latest")

# Try x86_64 linux first, fallback to any linux build
LAZYMC_URL=$(echo "$GH_JSON" | grep "browser_download_url" | grep "x86_64-unknown-linux-musl" | cut -d'"' -f4 | head -1)

if [ -z "$LAZYMC_URL" ]; then
    LAZYMC_URL=$(echo "$GH_JSON" | grep "browser_download_url" | grep "x86_64-unknown-linux" | cut -d'"' -f4 | head -1)
fi

if [ -z "$LAZYMC_URL" ]; then
    LAZYMC_URL=$(echo "$GH_JSON" | grep "browser_download_url" | grep "linux" | cut -d'"' -f4 | head -1)
fi

if [ -z "$LAZYMC_URL" ]; then
    echo "ERROR: Could not find LazyMC download URL!"
    echo "$GH_JSON" | head -20
    exit 1
fi

echo ">>> Downloading LazyMC from: $LAZYMC_URL"
curl -sSL -L -o lazymc "$LAZYMC_URL"

# Verify it's a real ELF binary
if ! file lazymc | grep -q "ELF"; then
    echo "ERROR: Downloaded lazymc is not a valid binary!"
    head -5 lazymc
    exit 1
fi
chmod +x lazymc
echo ">>> LazyMC binary OK ✓"

## ── EULA ─────────────────────────────────────────────────
echo "eula=true" > eula.txt
echo ">>> eula.txt created ✓"

## ── server.properties ────────────────────────────────────
# Internal port 25500 — LazyMC listens on PUBLIC port, forwards to this
cat > server.properties << 'EOF'
server-port=25500
server-ip=127.0.0.1
enable-rcon=true
rcon.port=25575
rcon.password=lazymc_rcon_pass
online-mode=true
EOF
echo ">>> server.properties created ✓"

## ── lazymc.toml (from GitHub) ────────────────────────────
echo ">>> Downloading lazymc.toml from GitHub..."
curl -sSL -o lazymc.toml "${GITHUB_RAW}/lazymc.toml"
echo ">>> lazymc.toml downloaded ✓"

## ── Done ─────────────────────────────────────────────────
echo ""
echo "=================================================="
echo "  Installation Complete!"
echo "  MC Version : ${MINECRAFT_VERSION}"
echo "  Paper Build: ${BUILD_NUMBER}"
echo "  Jar File   : ${SERVER_JARFILE}"
echo ""
echo "  start.sh is downloaded from GitHub on every"
echo "  server start automatically."
echo "=================================================="
echo ""
