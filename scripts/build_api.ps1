# build_api.ps1 - Build Go API server (Windows PowerShell)

Set-Location -Path "$PSScriptRoot\..\api"
go build -o server_bin.exe server.go
Write-Host "Go server built: api/server_bin.exe"
