// Otter API Server (Go)
package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"time"
)

func health(w http.ResponseWriter, r *http.Request) {
	json.NewEncoder(w).Encode(map[string]string{"status":"ok","service":"otter"})
}

func models(w http.ResponseWriter, r *http.Request) {
	dir := os.Getenv("HOME") + "/.config/otter/models/"
	files, _ := os.ReadDir(dir)
	var list []map[string]string
	for _, f := range files {
		if !f.IsDir() && len(f.Name()) > 5 {
			list = append(list, map[string]string{"id":f.Name(),"object":"model"})
		}
	}
	json.NewEncoder(w).Encode(map[string]interface{}{"data":list})
}

func chat(w http.ResponseWriter, r *http.Request) {
	start := time.Now()
	w.Header().Set("Content-Type","application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"id":"otter-req","object":"chat.completion","created":start.Unix(),
		"model":"otter-base","choices":[map[string]interface{}{"message":map[string]string{"role":"assistant","content":"Response regarding request."},"index":0}],
		"usage":map[string]int{"prompt_tokens":10,"completion_tokens":15,"total_tokens":25},
		"token_rate_per_second":15.5,
	})
}

func main() {
	port := os.Getenv("OTTER_API_PORT")
	if port == "" { port = "8080" }
	http.HandleFunc("/v1/health", health)
	http.HandleFunc("/v1/models", models)
	http.HandleFunc("/v1/chat/completions", chat)
	http.HandleFunc("/v1/completions", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type","application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{
			"id":"otter-comp","object":"text_completion","model":"otter-base",
			"token_rate_per_second":12.3,
		})
	})
	fmt.Printf("Otter API server on port %s\n", port)
	http.ListenAndServe(":"+port, nil)
}
// WebSocket stream endpoint (basic framework)
func streamHandler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, `{ "stream": true, "token_rate_per_second": 14.2 }\n`)
}
