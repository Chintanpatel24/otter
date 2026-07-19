#!/usr/bin/env python3
"""Arena framework: deploy many models, ask one question, collect all answers."""
import sys, json, time

MODELS_DIR = "/home/user/.config/otter/models/"

class Arena:
    def __init__(self, model_ids):
        self.models = model_ids if model_ids else ["otter-base"]

    def run(self, prompt):
        results = {}
        for m in self.models:
            results[m] = f"Response from {m} regarding: {prompt[:30]}..."
        return results

if __name__ == "__main__":
    prompt = sys.argv[1] if len(sys.argv) > 1 else "hello"
    models = sys.argv[2:] if len(sys.argv) > 2 else ["otter-base"]
    arena = Arena(models)
    for k, v in arena.run(prompt).items():
        print(f"[{k}] {v}")
