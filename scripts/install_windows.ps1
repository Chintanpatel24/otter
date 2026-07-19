# Otter Installation Script for Windows
# Usage: iwr -useb https://otter.local/scripts/install_windows.ps1 | iex

$OtterVersion = "1.0.0"
$OtterDir = "$env:LOCALAPPDATA\Otter"
$ConfigDir = "$env:LOCALAPPDATA\Otter\config"

Clear-Host
Write-Host ""
Write-Host "  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___"
Write-Host " / \  / \  / \  / \  / \  / \  / \  / \  / \  / \  / \  / \  / \  / \  / \  / \  / \  / \  / \  / \  / \  / \  / \  / \  / \"
Write-Host "/___\/___\/___\/___\/___\/___\/___\/___\/___\/___\/___\/___\/___\/___\/___\/___\/___\/___\/___\/___\/___\/___\/___\/___\/___\/___\/___\/___\"
Write-Host ""
Write-Host "                         Otter v$OtterVersion - Windows Installation"
Write-Host ""

$progress = 0
while ($progress -le 100) {
    $bar = ""
    $count = [math]::Round($progress / 4)
    for ($i = 0; $i -lt $count; $i++) { $bar += "#" }
    for ($i = $count; $i -lt 25; $i++) { $bar += " " }
    Write-Host -NoNewline "  [$bar] ${progress}%`r"
    $progress += 4
    Start-Sleep -Milliseconds 80
}
Write-Host ""

New-Item -ItemType Directory -Force -Path $OtterDir | Out-Null
New-Item -ItemType Directory -Force -Path $ConfigDir | Out-Null

$Config = @{
    version = $OtterVersion
    theme = "dark"
    max_tokens = 512
    temperature = 0.8
    platform = "windows"
} | ConvertTo-Json

$Config | Out-File -FilePath "$ConfigDir\config.json" -Encoding UTF8

Write-Host "  Installation complete."
Write-Host "  Config: $ConfigDir\config.json"
Write-Host ""
