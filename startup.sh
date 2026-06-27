#!/bin/bash
# ============================================
# RASHA Super App — Build & Start
#
# Usage:
#   ./startup.sh                  # pre-build bases, then build all & start
#   ./startup.sh --clean          # stop, remove containers, rebuild, start fresh
#   ./startup.sh --no-cache       # full clean rebuild, then start
#   ./startup.sh --bases-only     # rebuild base images only (no start)
#   ./startup.sh --skip-bases     # skip pre-building base images (use cached)
# ============================================
set -eo pipefail

NO_CACHE=""
BASES_ONLY=false
CLEAN=false
SKIP_BASES=false

for arg in "$@"; do
  case $arg in
    --clean)      CLEAN=true ;;
    --no-cache)   NO_CACHE="--no-cache" ;;
    --bases-only) BASES_ONLY=true ;;
    --skip-bases) SKIP_BASES=true ;;
  esac
done

# ── Step 0: Pre-build base images (always, unless --skip-bases or --bases-only) ──
# Base images rarely change, so this is almost always a no-op (cached).
# But it guarantees they exist before services that depend on them are built.
if [ "$BASES_ONLY" = true ]; then
  echo ">> [bases] Rebuilding base images..."
  docker buildx bake bases $NO_CACHE
  echo ">> Base images rebuilt. Run './startup.sh' to start containers."
  exit 0
fi

if [ "$SKIP_BASES" = false ]; then
  echo ">> [1/3] Pre-building base images (cached if unchanged)..."
  docker buildx bake bases $NO_CACHE 2>&1 | tail -5
  echo ""
fi

# ── Clean restart if requested ──
if [ "$CLEAN" = true ]; then
  echo ">> [2/4] Safe clean restart — stopping and removing containers..."
  docker compose stop
  docker compose rm -f
fi

# ── Build all images ──
if [ "$CLEAN" = true ]; then
  echo ">> [3/4] Building all service images..."
else
  echo ">> [2/3] Building all service images..."
fi
docker buildx bake $NO_CACHE

# ── Start containers ──
if [ "$CLEAN" = true ]; then
  echo ">> [4/4] Starting containers..."
else
  echo ">> [3/3] Starting containers..."
fi
docker compose up -d

echo ""
echo ">> Done. Running services:"
docker compose ps
