package main

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
)

type Registry struct {
	Models map[string]map[string]string `json:"models"`
	Count  int                         `json:"count"`
}

func getRegistryPath() string {
	home, _ := os.UserHomeDir()
	return filepath.Join(home, ".config", "otter", "models_registry.json")
}

func loadRegistry() Registry {
	path := getRegistryPath()
	var reg Registry
	reg.Models = make(map[string]map[string]string)

	file, err := os.ReadFile(path)
	if err == nil {
		json.Unmarshal(file, &reg)
	}
	return reg
}

func saveRegistry(reg Registry) {
	path := getRegistryPath()
	os.MkdirAll(filepath.Dir(path), 0755)
	data, _ := json.MarshalIndent(reg, "", "  ")
	os.WriteFile(path, data, 0644)
}

func registerModel(fileName string) string {
	reg := loadRegistry()
	home, _ := os.UserHomeDir()
	modelsDir := filepath.Join(home, ".config", "otter", "models")

	reg.Models[fileName] = map[string]string{
		"status": "loaded",
		"path":   filepath.Join(modelsDir, fileName),
	}
	reg.Count = len(reg.Models)
	saveRegistry(reg)
	return fmt.Sprintf("Registered: %s", fileName)
}

func main() {
	if len(os.Args) > 1 {
		fmt.Println(registerModel(os.Args[1]))
	} else {
		fmt.Println("Usage: logic <model_file_name>")
	}
}
