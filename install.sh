#!/bin/bash
# ============================================================
#  Paper + LazyMC Hibernation — Install Script
#  Repo: https://github.com/YOUR_GITHUB_USERNAME/pterodactyl-lazymc-egg
#
#  SIRF YEH EK LINE BADLO apna GitHub username daal ke:
#  YOUR_GITHUB_USERNAME
# ============================================================
set -e

apt-get update -y
apt-get install -y curl jq file

cd /mnt/server

GITHUB_RAW="https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/pterodactyl-lazymc-egg/main"

## ── PaperMC ──────────────────────────────────────────────────────────
if [ -z "${MINECRAFT_VERSION}" ] || [ "${MINECRAFT_VERSION}" = "latest" ]; then
    MINECRAFT_VERSION=$(curl -sSL https://api.papermc.io/v2/projects/paper | jq -r '.versions[-1]')
fi

if [ -z "${BUILD_NUMBER}" ] || [ "${BUILD_NUMBER}" = "latest" ]; then
    BUILD_NUMBER=$(curl -sSL "https://api.papermc.io/v2/projects/paper/versions/${MINECRAFT_VERSION}" | jq -r '.builds[-1]')
fi

echo ">>> Downloading Paper ${MINECRAFT_VERSION} build ${BUILD_NUMBER}..."
curl -sSL -o "${SERVER_JARFILE}" \
    "https://api.papermc.io/v2/projects/paper/versions/${MINECRAFT_VERSION}/builds/${BUILD_NUMBER}/downloads/paper-${MINECRAFT_VERSION}-${BUILD_NUMBER}.jar"
echo ">>> Paper downloaded OK."

## ── LazyMC ───────────────────────────────────────────────────────────
echo ">>> Fetching LazyMC latest release info..."
GH_JSON=$(curl -sSL "https://api.github.com/repos/timvisee/lazymc/releases/latest")
LAZYMC_URL=$(echo "$GH_JSON" | grep "browser_download_url" | grep "x86_64-unknown-linux" | cut -d'"' -f4 | head -1)

if [ -z "$LAZYMC_URL" ]; then
    LAZYMC_URL=$(echo "$GH_JSON" | grep "browser_download_url" | grep "linux" | cut -d'"' -f4 | head -1)
fi

if [ -z "$LAZYMC_URL" ]; then
    echo "ERROR: LazyMC download URL nahi mila!"
    echo "$GH_JSON"
    exit 1
fi

echo ">>> Downloading LazyMC from: $LAZYMC_URL"
curl -sSL -o lazymc "$LAZYMC_URL"

if ! file lazymc | grep -q "ELF"; then
    echo "ERROR: lazymc valid binary nahi hai!"
    head -5 lazymc
    exit 1
fi
chmod +x lazymc
echo ">>> LazyMC downloaded and verified OK."

## ── EULA ─────────────────────────────────────────────────────────────
echo 'eula=true' > eula.txt

## ── server.properties ────────────────────────────────────────────────
cat > server.properties << 'EOF'
server-port=25500
server-ip=127.0.0.1
enable-rcon=true
rcon.port=25575
rcon.password=lazymc_rcon_pass
online-mode=true
EOF

## ── GitHub se baaki files download karo ─────────────────────────────
echo ">>> Downloading lazymc.toml..."
curl -sSL -o lazymc.toml "${GITHUB_RAW}/lazymc.toml"
echo ">>> lazymc.toml OK."

echo ">>> Downloading start.sh..."
curl -sSL -o start.sh "${GITHUB_RAW}/start.sh"
chmod +x start.sh
echo ">>> start.sh OK."

echo ""
echo "=================================================="
echo "  Installation complete!"
echo "=================================================="
