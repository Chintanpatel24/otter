"""Model logic - manages loaded models, registry, and multi-model switching."""
import os, json

MODELS_DIR = os.path.expanduser("~/.config/otter/models/")

def load_registry():
    registry_path = os.path.join(os.path.dirname(MODELS_DIR), "models_registry.json")
    if os.path.exists(registry_path):
        with open(registry_path) as f:
            return json.load(f)
    return {"models": {}, "count": 0}

def save_registry(registry):
    registry_path = os.path.join(os.path.dirname(MODELS_DIR), "models_registry.json")
    with open(registry_path, "w") as f:
        json.dump(registry, f, indent=2)

def register_model(file_name):
    registry = load_registry()
    registry["models"][file_name] = {"status": "loaded", "path": f"{MODELS_DIR}{file_name}"}
    registry["count"] = len(registry["models"])
    save_registry(registry)
    return f"Registered: {file_name}"
