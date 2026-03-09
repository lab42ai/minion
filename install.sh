#!/usr/bin/env bash
#
# minion installer
# Usage: curl -sSL https://raw.githubusercontent.com/lab42ai/minion/main/install.sh | bash
#
# Downloads the latest release wheel from GitHub and installs it.
# User config (~/.minion/minion.json, .env, workspace/) is never overwritten.
#
set -euo pipefail


# ── Config ────────────────────────────────────────────────────────────
GITHUB_REPO="lab42ai/minion"  # TODO: update with real owner/repo
INSTALL_DIR="$HOME/.minion"
BIN_DIR="$HOME/.local/bin"
VENV_DIR="$INSTALL_DIR/venv"
VERSION_FILE="$INSTALL_DIR/.installed_version"
MIN_PYTHON="3.11"


# GitHub API URL for latest release
API_URL="https://api.github.com/repos/$GITHUB_REPO/releases/latest"


# ── Colors ────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'


info()  { echo -e "${BLUE}==>${NC} ${BOLD}$1${NC}"; }
ok()    { echo -e "${GREEN}  ✓${NC} $1"; }
warn()  { echo -e "${YELLOW}  ⚠${NC} $1"; }
fail()  { echo -e "${RED}  ✗ $1${NC}" >&2; exit 1; }


# ── Banner ────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}🦾 minion installer${NC}"
echo "─────────────────────────────────"
echo ""


# ── OS Detection ──────────────────────────────────────────────────────
OS="$(uname -s)"
ARCH="$(uname -m)"
info "Detected: $OS $ARCH"


case "$OS" in
   Linux|Darwin) ;;
   MINGW*|MSYS*|CYGWIN*)
       warn "Windows detected — use WSL for best results"
       ;;
   *)
       fail "Unsupported OS: $OS"
       ;;
esac


# ── Python Check ──────────────────────────────────────────────────────
info "Checking Python..."


find_python() {
   for cmd in python3.12 python3.11 python3 python; do
       if command -v "$cmd" &>/dev/null; then
           major=$("$cmd" -c "import sys; print(sys.version_info.major)" 2>/dev/null)
           minor=$("$cmd" -c "import sys; print(sys.version_info.minor)" 2>/dev/null)
           if [ "$major" -ge 3 ] && [ "$minor" -ge 11 ]; then
               echo "$cmd"
               return 0
           fi
       fi
   done
   return 1
}


PYTHON=$(find_python) || fail "Python >= $MIN_PYTHON required. Install from https://python.org"
PYTHON_VERSION=$($PYTHON -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}')")
ok "Python $PYTHON_VERSION ($PYTHON)"


# ── curl Check ───────────────────────────────────────────────────────
command -v curl &>/dev/null || fail "curl is required."


# ── uv Check (optional, preferred) ───────────────────────────────────
USE_UV=false
if command -v uv &>/dev/null; then
   USE_UV=true
   ok "uv $(uv --version 2>/dev/null | awk '{print $2}')"
else
   warn "uv not found — using pip (install uv for faster installs: curl -LsSf https://astral.sh/uv/install.sh | sh)"
fi


# ── Fetch Latest Release ─────────────────────────────────────────────
info "Fetching latest release..."


RELEASE_JSON=$(curl -sSL "$API_URL" 2>/dev/null) || fail "Failed to fetch release info from GitHub."


# Parse version tag
LATEST_VERSION=$(echo "$RELEASE_JSON" | $PYTHON -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('tag_name', ''))
" 2>/dev/null) || fail "Failed to parse release info."


if [ -z "$LATEST_VERSION" ]; then
   fail "No releases found at $API_URL"
fi


# Check if already installed at this version
CURRENT_VERSION=""
if [ -f "$VERSION_FILE" ]; then
   CURRENT_VERSION=$(cat "$VERSION_FILE")
fi


if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
   ok "Already at latest version ($LATEST_VERSION)"
   echo ""
   echo "  Run with FORCE=1 to reinstall:"
   echo "  curl -sSL ... | FORCE=1 bash"
   echo ""
   if [ "${FORCE:-}" != "1" ]; then
       exit 0
   fi
   warn "Force reinstall requested"
fi


ok "Latest release: $LATEST_VERSION"
if [ -n "$CURRENT_VERSION" ]; then
   echo -e "  Upgrading from $CURRENT_VERSION"
fi


# Find the wheel asset (.whl)
WHEEL_URL=$(echo "$RELEASE_JSON" | $PYTHON -c "
import sys, json
data = json.load(sys.stdin)
for asset in data.get('assets', []):
   name = asset.get('name', '')
   if name.endswith('.whl'):
       print(asset['browser_download_url'])
       sys.exit(0)
# Fallback: try tarball
for asset in data.get('assets', []):
   name = asset.get('name', '')
   if name.endswith('.tar.gz'):
       print(asset['browser_download_url'])
       sys.exit(0)
# Last resort: source tarball from GitHub
print(data.get('tarball_url', ''))
" 2>/dev/null)


if [ -z "$WHEEL_URL" ]; then
   fail "No installable asset found in release $LATEST_VERSION"
fi


# Download the asset
DOWNLOAD_DIR=$(mktemp -d)
ASSET_FILE="$DOWNLOAD_DIR/$(basename "$WHEEL_URL")"


info "Downloading $LATEST_VERSION..."
curl -sSL -o "$ASSET_FILE" "$WHEEL_URL" || fail "Download failed: $WHEEL_URL"
ok "Downloaded $(basename "$ASSET_FILE")"


# ── Virtual Environment ──────────────────────────────────────────────
info "Setting up virtual environment..."


mkdir -p "$INSTALL_DIR"


if [ "$USE_UV" = true ]; then
   if [ ! -d "$VENV_DIR" ]; then
       uv venv "$VENV_DIR" --python "$PYTHON" --quiet
   fi
else
   if [ ! -d "$VENV_DIR" ]; then
       $PYTHON -m venv "$VENV_DIR"
   fi
fi
ok "Virtual environment ready"


# ── Install Package ──────────────────────────────────────────────────
info "Installing minion..."


VENV_PIP="$VENV_DIR/bin/pip"
VENV_PYTHON="$VENV_DIR/bin/python"


if [ "$USE_UV" = true ]; then
   uv pip install --python "$VENV_PYTHON" "$ASSET_FILE" --quiet --force-reinstall 2>&1 | tail -1 || true
   ok "Installed (uv)"
else
   "$VENV_PIP" install --upgrade pip --quiet 2>/dev/null
   "$VENV_PIP" install "$ASSET_FILE" --force-reinstall --quiet 2>&1 | tail -1 || true
   ok "Installed (pip)"
fi


# ── Install Optional Dependencies ────────────────────────────────────
info "Installing optional packages..."


OPTIONAL_PKGS="pdfplumber python-docx python-pptx pandas rank-bm25 mcp"
if [ "$USE_UV" = true ]; then
   uv pip install --python "$VENV_PYTHON" $OPTIONAL_PKGS --quiet 2>/dev/null || warn "Some optional packages failed (non-critical)"
else
   "$VENV_PIP" install $OPTIONAL_PKGS --quiet 2>/dev/null || warn "Some optional packages failed (non-critical)"
fi
ok "Optional packages installed"


# Clean up download
rm -rf "$DOWNLOAD_DIR"


# ── Save Version ─────────────────────────────────────────────────────
echo "$LATEST_VERSION" > "$VERSION_FILE"


# ── Create CLI Wrapper ───────────────────────────────────────────────
info "Installing CLI..."


mkdir -p "$BIN_DIR"


cat > "$BIN_DIR/minion" << 'WRAPPER'
#!/usr/bin/env bash
exec "$HOME/.minion/venv/bin/minion" "$@"
WRAPPER
chmod +x "$BIN_DIR/minion"
ok "CLI installed to $BIN_DIR/minion"


# ── Workspace Setup ──────────────────────────────────────────────────
info "Setting up workspace..."


WORKSPACE="$INSTALL_DIR/workspace"
mkdir -p "$WORKSPACE/memory"
mkdir -p "$WORKSPACE/exports"
mkdir -p "$INSTALL_DIR/sessions"
mkdir -p "$INSTALL_DIR/logs"


# Create default config if it doesn't exist
if [ ! -f "$INSTALL_DIR/minion.json" ]; then
   cat > "$INSTALL_DIR/minion.json" << 'CONFIG'
{
 "models": {
   "providers": {}
 },
 "agents": {
   "defaults": {
     "workspace": "~/.minion/workspace",
     "model": {
       "primary": "anthropic/claude-sonnet-4-5"
     },
     "maxToolIterations": 20,
     "maxTokens": 8192,
     "temperature": 0.7
   }
 },
 "channels": {
   "telegram": {
     "enabled": false
   }
 },
 "tools": {
   "web": {
     "search": {
       "maxResults": 5
     }
   }
 },
 "security": {
   "enabled": true,
   "inputGuardEnabled": true,
   "outputGuardEnabled": true,
   "mlPromptInjectionEnabled": false
 }
}
CONFIG
   ok "Default config created"
else
   ok "Config already exists"
fi


# Create .env template if it doesn't exist
if [ ! -f "$INSTALL_DIR/.env" ]; then
   cat > "$INSTALL_DIR/.env" << 'ENVFILE'
# minion API keys — uncomment and fill in as needed
# ANTHROPIC_API_KEY=sk-ant-...
# OPENAI_API_KEY=sk-...
# TELEGRAM_BOT_TOKEN=...
# BRAVE_API_KEY=...
# TAVILY_API_KEY=...
ENVFILE
   ok "API key template created"
else
   ok ".env already exists"
fi


# Create default workspace files if missing
for file in AGENTS.md SOUL.md TOOLS.md USER.md HEARTBEAT.md; do
   if [ ! -f "$WORKSPACE/$file" ]; then
       touch "$WORKSPACE/$file"
   fi
done
ok "Workspace ready"


# ── PATH Check ───────────────────────────────────────────────────────
info "Checking PATH..."


if echo "$PATH" | tr ':' '\n' | grep -q "^$BIN_DIR$"; then
   ok "$BIN_DIR is in PATH"
else
   warn "$BIN_DIR is not in PATH"
   echo ""
   echo "  Add this to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
   echo ""
   echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
   echo ""
fi


# ── Done ─────────────────────────────────────────────────────────────
echo ""
echo "─────────────────────────────────"
echo -e "${GREEN}${BOLD}🦾 minion $LATEST_VERSION installed!${NC}"
echo ""
echo "  Next steps:"
echo ""
echo "  1. Add your API keys:"
echo "     nano ~/.minion/.env"
echo ""
echo "  2. Run setup wizard:"
echo "     minion setup"
echo ""
echo "  3. Start the gateway:"
echo "     minion arise"
echo ""
echo "  4. Or chat directly:"
echo "     minion agent -m \"Hello!\""
echo ""
echo "  Update anytime: minion update"
echo ""
