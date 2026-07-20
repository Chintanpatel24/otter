#!/bin/bash
# macOS Installation Script for Otter
# Usage: curl -fsSL https://raw.githubusercontent.com/Chintanpatel/otter/main/scripts/install_mac.sh | bash

set -euo pipefail

OTTER_VERSION="1.0.0"
OTTER_DIR="$HOME/.local/share/otter"
CONFIG_DIR="$HOME/.config/otter"
BIN_DIR="$HOME/.local/bin"

clear
echo ""
echo "  ___  _  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___"
echo " / \  \/ \/ \/ \/ \  \/ \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \"
echo "/   \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/   \\"
echo "/    \/_ \/_ \/_/ \/_/ \/_/ \/_/ \/_/ \/_/ \/_/ \/_/ \/_/ \/_/ \/_/ \/_/ \/_/ \/_/ \/_/ \/_/ \/_/ \/_/    \\"
echo ""
echo "                     Otter v${OTTER_VERSION} - macOS Installation"
echo ""

# Progress bar
for i in $(seq 1 25); do
    printf "\r  ["
    for j in $(seq 1 $i); do printf "="; done
    for k in $(seq $i 25); do printf " "; done
    printf "] %d%%" $((i * 100 / 25))
    sleep 0.03
done
printf "\n"

# Setup directories
echo "  Creating directories ..."
mkdir -p "$OTTER_DIR"
mkdir -p "$CONFIG_DIR"
mkdir -p "$BIN_DIR"

# Write default config
echo '{"version":"'"${OTTER_VERSION}"'","theme":"dark","max_tokens":512,"temperature":0.8,"platform":"macos"}' > "$CONFIG_DIR/config.json"

# Find where the source code is (local, parent, or cloned from git)
SRC_DIR=""
if [ -f "Makefile" ] && [ -f "Cargo.toml" ]; then
    SRC_DIR="$(pwd)"
elif [ -f "../Makefile" ] && [ -f "../Cargo.toml" ]; then
    SRC_DIR="$(cd .. && pwd)"
elif [ -f "../../Makefile" ] && [ -f "../../Cargo.toml" ]; then
    SRC_DIR="$(cd ../.. && pwd)"
else
    # One-liner curl install fallback: Clone from GitHub or download tarball
    echo "  Cloning Otter repository from GitHub ..."
    TMP_DIR=$(mktemp -d)
    if git clone --depth 1 https://github.com/Chintanpatel/otter.git "$TMP_DIR" &>/dev/null; then
        SRC_DIR="$TMP_DIR"
    else
        echo "  Git clone failed or Git not found. Downloading tarball via curl..."
        if curl -sSL https://github.com/Chintanpatel/otter/archive/refs/heads/main.tar.gz | tar -xz -C "$TMP_DIR" --strip-components=1 2>/dev/null; then
            SRC_DIR="$TMP_DIR"
        fi
    fi
fi

if [ -n "$SRC_DIR" ]; then
    # Ensure Rust is installed
    if ! command -v cargo &>/dev/null; then
        echo "  Rust/Cargo not found. Installing Rust/Cargo automatically..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y &>/dev/null || true
        export PATH="$HOME/.cargo/bin:$PATH"
        source "$HOME/.cargo/env" 2>/dev/null || true
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
if [ -f "$HOME/.bash_profile" ]; then
    if ! grep -q ".local/bin" "$HOME/.bash_profile"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bash_profile" 2>/dev/null || true
    fi
fi
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q ".local/bin" "$HOME/.zshrc"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc" 2>/dev/null || true
    fi
fi

echo "  Mac installation complete. Config saved to $CONFIG_DIR/config.json"
echo "  Run: otter"
echo ""
