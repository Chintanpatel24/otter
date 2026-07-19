#!/bin/bash
# Otter Installation Script
# One-liner install: curl -fsSL https://otter.local/scripts/install.sh | bash

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
    sleep 0.08
done
printf "\n"

# Setup directories
echo "  Creating directories ..."
mkdir -p "$OTTER_DIR"
mkdir -p "$CONFIG_DIR"
mkdir -p "$BIN_DIR"

# Write default config
printf '{"version":"%s","theme":"dark","max_tokens":512,"temperature":0.8}\n' "$OTTER_VERSION" > "$CONFIG_DIR/config.json"

# Setup binary: try to use existing binary, build from workspace, or download
if [ -f "/home/user/otter-engine" ]; then
    cp "/home/user/otter-engine" "$OTTER_DIR/otter-engine"
    chmod +x "$OTTER_DIR/otter-engine"
elif [ -f "otter-engine" ]; then
    cp otter-engine "$OTTER_DIR/otter-engine"
    chmod +x "$OTTER_DIR/otter-engine"
elif [ -f "/home/user/Makefile" ]; then
    echo "  Building engine from source ..."
    (cd "/home/user" && make clean 2>/dev/null; make)
    if [ -f "/home/user/otter-engine" ]; then
        cp "/home/user/otter-engine" "$OTTER_DIR/otter-engine"
        chmod +x "$OTTER_DIR/otter-engine"
    fi
fi

# Create symlink in standard paths
if [ -f "$OTTER_DIR/otter-engine" ]; then
    ln -sf "$OTTER_DIR/otter-engine" "$BIN_DIR/otter"
    # Also try system-wide binary location for fish and other shells
    if [ -w "/usr/local/bin" ]; then
        ln -sf "$OTTER_DIR/otter-engine" "/usr/local/bin/otter" 2>/dev/null || true
    fi
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

# Copy logo asset to installed directory for desktop launcher
mkdir -p "$OTTER_DIR/assets"
cp "/home/user/assets/logo.png" "$OTTER_DIR/assets/logo.png" 2>/dev/null || true

# Write desktop entry from workspace packaging
if [ -f "/home/user/packaging/linux/otter.desktop" ]; then
    cp "/home/user/packaging/linux/otter.desktop" "$HOME/.local/share/applications/otter.desktop"
    chmod +x "$HOME/.local/share/applications/otter.desktop" 2>/dev/null || true
fi

echo ""
echo "  Installation complete."
echo "  Run: otter [open from applications menu if installed]"
echo "  Config: $CONFIG_DIR/config.json"
echo ""
