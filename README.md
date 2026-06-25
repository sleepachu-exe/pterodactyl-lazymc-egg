# pterodactyl-lazymc-egg

PaperMC server with LazyMC hibernation for Pterodactyl.

## How it works
- Server **sleeps** when no players are online
- Server **auto-starts** when someone connects
- After **3 minutes** of 0 players → goes back to sleep

## Files
| File | Purpose |
|---|---|
| `install.sh` | Runs once during server installation |
| `start.sh` | Runs every time server starts |
| `lazymc.toml` | LazyMC hibernation configuration |
| `egg-paper-hibernation.json` | Import this in Pterodactyl |

## Setup

### Step 1 — Update your GitHub username

In **`install.sh`** change line 13:
```bash
GITHUB_RAW="https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/pterodactyl-lazymc-egg/main"
```

In **`egg-paper-hibernation.json`** change:
```
YOUR_GITHUB_USERNAME
```

### Step 2 — Import egg in Pterodactyl
- Admin Panel → Nests → Import Egg → upload `egg-paper-hibernation.json`

### Step 3 — Create server
- Create new server using this egg → Reinstall → Start

## Port diagram
```
Player → your_ip:SERVER_PORT → LazyMC (always listening)
                                      ↓ wakes up server
                               127.0.0.1:25500 → Minecraft (Paper)
```
