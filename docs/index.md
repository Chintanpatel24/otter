# Otter Documentation

## Architecture

- `engine/`: Custom C core
- `cuda/`: GPU acceleration
- `src/`: Native desktop GUI
- `packaging/`: Platform installers
- `scripts/`: Terminal installation scripts with ASCII animation

## Installation

### One Liner (Linux / macOS)
`curl -fsSL https://otter.local/scripts/install.sh | bash`

### One Liner (Windows PowerShell)
`iwr -useb https://otter.local/scripts/install_windows.ps1 | iex`

## Configuration

Settings stored in `~/.config/otter/config.json`.

## Plugins

Place `.so` or `.py` plugin files in `plugins/` directory.
