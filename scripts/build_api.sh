#!/bin/bash
# Build Go API server
cd "$(dirname "$0")/../api"
go build -o server_bin server.go
echo "Go server built: api/server_bin"
