# Otter

[![License](https://img.shields.io/github/license/otter/otter?label=MIT)](LICENSE) [![Version](https://img.shields.io/github/v/release/otter/otter?label=v1.0.0)](https://github.com/otter/otter/releases)

**Otter** is a custom-built local hosting service for large language models. It runs a pure C inference engine with optional CUDA acceleration, streams model weights directly from disk (low memory footprint), and provides a native desktop interface with clean dark (`#121212`) and light (`#ffffff`) themes. No external model libraries are used. No decorative elements. No emojis.

## Quick Install

```bash
curl -fsSL https://otter.local/scripts/install.sh | bash
```

macOS: `curl -fsSL https://otter.local/scripts/install_mac.sh | bash`

Windows PowerShell: `iwr -useb https://otter.local/scripts/install_windows.ps1 | iex`

The install scripts run terminal ASCII animations showing the otter mascot drawing line-by-line.

## What Otter Does

- **Custom C Engine**: Reads `.gguf` files via chunked stream loader. Applies quantization dequantization (`Q4_K`, `Q5_K` simplified). Runs scaled dot-product attention through float tensor operations. Produces token predictions via greedy sampling.
- **CUDA Layer**: Optional GPU matrix multiply kernel (`cuda/kernels.cu`) accelerates the projection step.
- **Native Desktop GUI**: Rust `eframe` application with sidebar model management, chat interface, settings overlay, and theme toggle.
- **Config Persistence**: User settings saved to `~/.config/otter/config.json` (version, theme, max tokens, temperature).
- **Plugin System** (optional framework): The `plugins/` directory supports `.py` scripts or compiled libraries that extend model handling.
- **Multi-Model Index**: The engine maintains a loaded model index. Users can switch between models from the sidebar without full restarts.
- **Auto-Update Check**: Built-in version endpoint check (`src/update.rs`).
- **Packaging**: Professional installers for Linux (`packaging/linux/otter.desktop` + `.xml`), macOS (`packaging/mac/Info.plist`), and Windows (`packaging/windows/otter_setup.iss`).
- **Terminal Animation**: All three installation scripts (`scripts/install.sh`, `scripts/install_mac.sh`, `scripts/install_windows.ps1`) include ASCII art animations.

## Build

```bash
make
cargo run --release
```

The `Makefile` builds `otter-engine` linking `engine/` sources with `-lm`. The `build.rs` links the C engine as a static library for the Rust GUI.

## Structure

```
assets/          Logo (black geometric design on white)
cuda/            CUDA .cu kernels + headers
engine/          Custom C core (tensor, stream, quant, attention, tokenizer, bridge)
docs/            Diagrams: architecture.md, system.md, installation.md, features.md, plugins.md, multi_model.md, index.md
packaging/       mac/.plist, windows/.iss, linux/.desktop + .xml
scripts/          Terminal install scripts (ASCII animation)
config_example/  Example user config
src/             Rust native GUI + bindings + config + update
setup.iss        Root Inno Setup installer
```

## Themes

- **Dark**: Background `#121212`, surface `#1a1a1a`, borders `#2a2a2a`, text `#f0f0f0`
- **Light**: Background `#ffffff`, surface `#f8f8f8`, borders `#e5e5e5`, text `#1a1a1a`

Theme saved to user config. No decorative icons. Clean borders only.

## Config

`~/.config/otter/config.json` stores version, theme selection, max token limit, temperature, and platform identifier.

## Plugin Framework

Plugins are discovered at startup from the `plugins/` directory. The engine scans for `.py` scripts or compiled `.so` / `.dylib` / `.dll` modules and registers them as model handlers or preprocessing extensions. The example script (`plugins/example_plugin.py`) demonstrates the version and description format expected by the registry.

## Documentation Diagrams

All Mermaid diagrams are separated in `docs/`:

- `docs/architecture.md` — data flow from user input through tokenizer, stream loader, quantization, tensor math, attention, projection, and GUI response
- `docs/system.md` — desktop layer, engine layer, persistence layer connections
- `docs/installation.md` — sequence diagram of terminal installation process
- `docs/features.md` — mindmap of engine, interface, plugins, multi-model, config, install, packaging, update
- `docs/plugins.md` — plugin registry flow
- `docs/multi_model.md` — state diagram for model switching
- `docs/index.md` — quick reference

## Packaging Details

| Platform | Config File | Type |
|---|---|---|
| Linux | `packaging/linux/otter.desktop` | Freedesktop entry |
| Linux | `packaging/linux/otter.xml` | AppStream metadata |
| macOS | `packaging/mac/Info.plist` | Bundle identifier |
| Windows | `packaging/windows/otter_setup.iss` | Inno Setup installer |

The `scripts/` folder contains executable installation scripts with progressive ASCII animation that builds the otter mascot as progress advances.

## Performance Notes

The stream loader reads weights in chunks rather than loading the entire model into RAM. CUDA accelerates the projection layer. The engine uses a simplified single-layer demonstration architecture; scaling to deep multi-layer networks requires extending `engine/inference.c` with layer loops and larger weight streams.

## API Server
Run `python3 api/server.py` to start the local server. Endpoints:
- `GET /v1/models` — list available models
- `GET /v1/health` — health check
- `POST /v1/chat/completions` — chat with token rate tracking (`token_rate_per_second` in response)
- `POST /v1/completions` — text generation with live rate

All endpoints return `token_rate_per_second` showing live generation speed.

## Arena Mode
Deploy up to 5 `.gguf` models simultaneously using the mesh framework (`mesh/mesh.py`). The GUI Mesh View shows connected hardware nodes with load bars and running model status. Ask one question; all selected models process it in parallel. Results display side-by-side in columns.

## Drag and Drop
Drag any `.gguf` file into the sidebar drop zone. The model is saved to `~/.config/otter/models/` and tracked in the registry.

## License

MIT
