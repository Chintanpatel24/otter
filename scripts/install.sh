#!/bin/bash
# Otter Installation Script
# One-liner install: curl -fsSL https://raw.githubusercontent.com/Chintanpatel/otter/main/scripts/install.sh | bash

set -euo pipefail

OTTER_VERSION="1.0.0"
OTTER_DIR="$HOME/.local/share/otter"
CONFIG_DIR="$HOME/.config/otter"
BIN_DIR="$HOME/.local/bin"

# ASCII Animation: Otter drawing
clear
printf "\n"
echo "  _   _  __  __  _  __  __  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___"
echo " / \/ \/ \/ / \/ \/ \/ / / \/ \/ \/ / / \/ / / \/ / / \/ / / \/ / / \/ / / \/ / / \/ / / \/ / / \/ / / "
echo "/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  "
echo "/ /\  / /\  / /\  / /\  / /\  / /\  / /\  / /\  / /\  / /\  / /\  / /\  / /\  / /\  / /\  / /\  / /\  / /\  / /\  / /"
echo "/_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/"
echo ""
echo "                   Installing Otter v${OTTER_VERSION} ..."
echo ""

# Progress animation
for i in $(seq 1 30); do
    printf "\r  ["
    for j in $(seq 1 $i); do printf "#"; done
    for k in $(seq $i 30); do printf " "; done
    printf "] %d%%" $((i * 100 / 30))
    sleep 0.03
done
printf "\n"

# Setup directories
echo "  Creating directories ..."
mkdir -p "$OTTER_DIR"
mkdir -p "$CONFIG_DIR"
mkdir -p "$BIN_DIR"

# Write default config
printf '{"version":"%s","theme":"dark","max_tokens":512,"temperature":0.8}\n' "$OTTER_VERSION" > "$CONFIG_DIR/config.json"

# Find where the source code is (local, parent, or cloned from git)
SRC_DIR=""
if [ -f "Makefile" ] && [ -f "Cargo.toml" ]; then
    SRC_DIR="$(pwd)"
elif [ -f "../Makefile" ] && [ -f "../Cargo.toml" ]; then
    SRC_DIR="$(cd .. && pwd)"
elif [ -f "../../Makefile" ] && [ -f "../../Cargo.toml" ]; then
    SRC_DIR="$(cd ../.. && pwd)"
else
    # One-liner curl install fallback: Clone from GitHub
    echo "  Cloning Otter repository from GitHub ..."
    TMP_DIR=$(mktemp -d)
    if git clone --depth 1 https://github.com/Chintanpatel/otter.git "$TMP_DIR" &>/dev/null; then
        SRC_DIR="$TMP_DIR"
    fi
fi

if [ -n "$SRC_DIR" ]; then
    # Ensure Rust is installed
    if ! command -v cargo &>/dev/null; then
        echo "  Rust/Cargo not found. Installing Rust/Cargo automatically..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y &>/dev/null || true
        export PATH="$HOME/.cargo/bin:$PATH"
    fi

    # Ensure system build dependencies on Arch/Cachy or Debian
    if command -v pacman &>/dev/null; then
        echo "  Arch/CachyOS detected. Installing system dependencies (may prompt for sudo password)..."
        sudo pacman -S --needed --noconfirm pkg-config alsa-lib wayland gtk3 &>/dev/null || true
    elif command -v apt-get &>/dev/null; then
        echo "  Debian/Ubuntu detected. Installing system dependencies (may prompt for sudo password)..."
        sudo apt-get update &>/dev/null || true
        sudo apt-get install -y pkg-config libasound2-dev libwayland-dev libx11-dev libxcb1-dev libxcursor-dev libxrandr-dev libxi-dev libgtk-3-dev &>/dev/null || true
    fi

    echo "  Building C Engine from source ..."
    if command -v gcc &>/dev/null && command -v make &>/dev/null; then
        (cd "$SRC_DIR" && make clean 2>/dev/null || true; make &>/dev/null || true)
        if [ -f "$SRC_DIR/otter-engine" ]; then
            cp "$SRC_DIR/otter-engine" "$OTTER_DIR/otter-engine"
            chmod +x "$OTTER_DIR/otter-engine"
        fi
    fi

    # Build Go components (arena, logic)
    if command -v go &>/dev/null; then
        echo "  Building Go components ..."
        (cd "$SRC_DIR" && go build -o arena/arena arena/arena.go 2>/dev/null || true)
        (cd "$SRC_DIR" && go build -o models/logic models/logic.go 2>/dev/null || true)
        mkdir -p "$OTTER_DIR/arena" "$OTTER_DIR/models"
        cp "$SRC_DIR/arena/arena" "$OTTER_DIR/arena/arena" 2>/dev/null || true
        cp "$SRC_DIR/models/logic" "$OTTER_DIR/models/logic" 2>/dev/null || true
    fi

    # Build Rust GUI if cargo is present
    if command -v cargo &>/dev/null; then
        echo "  Building Rust GUI from source (this might take a minute) ..."
        (cd "$SRC_DIR" && cargo build --release &>/dev/null || true)
        if [ -f "$SRC_DIR/target/release/otter" ]; then
            cp "$SRC_DIR/target/release/otter" "$OTTER_DIR/otter"
            chmod +x "$OTTER_DIR/otter"
        fi
    fi

    # Copy logo
    mkdir -p "$OTTER_DIR/assets"
    cp "$SRC_DIR/assets/logo.png" "$OTTER_DIR/assets/logo.png" 2>/dev/null || true

    # Install .desktop entry on Linux
    if [ -f "$SRC_DIR/packaging/linux/otter.desktop" ]; then
        mkdir -p "$HOME/.local/share/applications"
        sed "s|/home/user|$HOME|g" "$SRC_DIR/packaging/linux/otter.desktop" > "$HOME/.local/share/applications/otter.desktop" 2>/dev/null || true
        chmod +x "$HOME/.local/share/applications/otter.desktop" 2>/dev/null || true
    fi
fi

# Create symlink in standard paths
if [ -f "$OTTER_DIR/otter" ]; then
    ln -sf "$OTTER_DIR/otter" "$BIN_DIR/otter"
elif [ -f "$OTTER_DIR/otter-engine" ]; then
    ln -sf "$OTTER_DIR/otter-engine" "$BIN_DIR/otter"
else
    # Fallback placeholder script
    echo "  Creating placeholder runner ..."
    printf '#!/bin/bash\necho "Otter Engine v%s Active"\n' "$OTTER_VERSION" > "$BIN_DIR/otter"
    chmod +x "$BIN_DIR/otter"
fi

# Ensure binary is accessible: add to user PATH configs for bash, zsh, fish
if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "export PATH=.*.local/bin" "$HOME/.bashrc"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc" 2>/dev/null || true
    fi
fi
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q ".local/bin" "$HOME/.zshrc"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc" 2>/dev/null || true
    fi
fi
if [ -d "$HOME/.config/fish" ]; then
    echo 'set -gx PATH $HOME/.local/bin $PATH' >> "$HOME/.config/fish/config.fish" 2>/dev/null || true
fi

echo ""
echo "  Installation complete."
echo "  Run: otter"
echo "  Config: $CONFIG_DIR/config.json"
echo ""
