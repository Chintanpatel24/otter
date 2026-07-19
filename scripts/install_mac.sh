#!/bin/bash
# macOS Installation Script for Otter
# Usage: curl -fsSL https://raw.githubusercontent.com/Chintanpatel/otter/main/scripts/install_mac.sh | bash

set -euo pipefail

OTTER_VERSION="1.0.0"
OTTER_DIR="$HOME/.local/share/otter"
CONFIG_DIR="$HOME/.config/otter"

clear
echo ""
echo "  ___  _  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___"
echo " / \  \/ \/ \/ \/ \  \/ \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \"
echo "/   \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/   \\"
echo "/    \/_ \/_ \/_/ \/_/ \/_/ \/_/ \/_/ \/_/ \/_/ \/_/ \/_/ \/_/ \/_/ \/_/ \/_/ \/_/ \/_/ \/_/ \/_/ \/_/    \\"
echo ""
echo "                     Otter v${OTTER_VERSION} - macOS Installation"
echo ""

for i in $(seq 1 25); do
    printf "\r  ["
    for j in $(seq 1 $i); do printf "="; done
    for k in $(seq $i 25); do printf " "; done
    printf "] %d%%" $((i * 100 / 25))
    sleep 0.1
done
printf "\n"

mkdir -p "$OTTER_DIR"
mkdir -p "$CONFIG_DIR"

echo '{"version":"'"${OTTER_VERSION}"'","theme":"dark","max_tokens":512,"temperature":0.8,"platform":"macos"}' > "$CONFIG_DIR/config.json"

echo "  Mac installation complete. Config saved to $CONFIG_DIR/config.json"
echo ""
