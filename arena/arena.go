// Arena framework: deploy many models, ask one question, collect all answers.
package main

import (
	"fmt"
	"os"
)

func main() {
	prompt := "hello"
	if len(os.Args) > 1 {
		prompt = os.Args[1]
	}

	models := []string{"otter-base"}
	if len(os.Args) > 2 {
		models = os.Args[2:]
	}

	fmt.Printf("Arena running prompt: \"%s\"\n", prompt)
	for _, m := range models {
		fmt.Printf("[%s] Response from %s regarding: %s...\n", m, m, prompt)
	}
}
