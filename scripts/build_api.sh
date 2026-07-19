#!/bin/bash
# Build Go API server
cd /home/user/api
go build -o server_bin server.go
echo "Go server built: api/server_bin"
