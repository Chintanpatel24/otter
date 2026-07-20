# Otter Installation Script for Windows
# Usage: iwr -useb https://raw.githubusercontent.com/Chintanpatel/otter/main/scripts/install_windows.ps1 | iex

$OtterVersion = "1.0.0"
$OtterDir = "$env:LOCALAPPDATA\Otter"
$ConfigDir = "$env:USERPROFILE\.config\otter"
$BinDir = "$env:LOCALAPPDATA\Otter\bin"

Clear-Host
Write-Host ""
Write-Host "  _   _  __  __  _  __  __  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___"
Write-Host " / \/ \/ \/ / \/ \/ \/ / / \/ \/ \/ / / \/ / / \/ / / \/ / / \/ / / \/ / / \/ / / \/ / / \/ / / \/ / / "
Write-Host "/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  \/  "
Write-Host "/ /\  / /\  / /\  / /\  / /\  / /\  / /\  / /\  / /\  / /\  / /\  / /\  / /\  / /\  / /\  / /\  / /\  / /\  / /\  / /"
Write-Host "/_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/"
Write-Host ""
Write-Host "                   Installing Otter v$OtterVersion ..."
Write-Host ""

$progress = 0
while ($progress -le 100) {
    $bar = ""
    $count = [math]::Round($progress / 3.33)
    for ($i = 0; $i -lt $count; $i++) { $bar += "#" }
    for ($i = $count; $i -lt 30; $i++) { $bar += " " }
    Write-Host -NoNewline "  [$bar] ${progress}%`r"
    $progress += 4
    Start-Sleep -Milliseconds 80
}
Write-Host ""

# Setup directories
Write-Host "  Creating directories ..."
New-Item -ItemType Directory -Force -Path $OtterDir | Out-Null
New-Item -ItemType Directory -Force -Path $ConfigDir | Out-Null
New-Item -ItemType Directory -Force -Path $BinDir | Out-Null

# Write default config
$Config = @{
    version = $OtterVersion
    theme = "dark"
    max_tokens = 512
    temperature = 0.8
    platform = "windows"
} | ConvertTo-Json

$Config | Out-File -FilePath "$ConfigDir\config.json" -Encoding UTF8

# Find where the source code is (local, parent, or cloned from git)
$SrcDir = ""
if (Test-Path -Path "Makefile" -PathType Leaf) {
    $SrcDir = (Get-Item .).FullName
} elseif (Test-Path -Path "..\Makefile" -PathType Leaf) {
    $SrcDir = (Get-Item ..).FullName
} elseif (Test-Path -Path "..\..\Makefile" -PathType Leaf) {
    $SrcDir = (Get-Item ..\..).FullName
} else {
    Write-Host "  Source files not found locally. Cloning/Downloading Otter repository..."
    $TmpDir = [System.IO.Path]::GetTempPath() + "otter_build_" + [System.Guid]::NewGuid().ToString().Substring(0,8)
    New-Item -ItemType Directory -Force -Path $TmpDir | Out-Null

    # Try git clone first
    $CloneSuccess = $false
    try {
        git clone --depth 1 https://github.com/Chintanpatel24/otter.git $TmpDir 2>$null
        if (Test-Path -Path "$TmpDir\Cargo.toml") { $CloneSuccess = $true }
    } catch {}

    if (-not $CloneSuccess) {
        try {
            git clone --depth 1 https://github.com/Chintanpatel/otter.git $TmpDir 2>$null
            if (Test-Path -Path "$TmpDir\Cargo.toml") { $CloneSuccess = $true }
        } catch {}
    }

    # Try downloading zip if git failed
    if (-not $CloneSuccess) {
        Write-Host "  Git clone failed. Downloading zip via Invoke-WebRequest..."
        $ZipPath = "$TmpDir\otter.zip"
        try {
            Invoke-WebRequest -Uri "https://github.com/Chintanpatel24/otter/archive/refs/heads/main.zip" -OutFile $ZipPath -ErrorAction Stop
            Expand-Archive -Path $ZipPath -DestinationPath "$TmpDir\extracted" -Force
            # The zip extracts into a folder named otter-main
            if (Test-Path -Path "$TmpDir\extracted\otter-main") {
                Copy-Item -Path "$TmpDir\extracted\otter-main\*" -Destination $TmpDir -Recurse -Force
                $CloneSuccess = $true
            }
        } catch {
            try {
                Invoke-WebRequest -Uri "https://github.com/Chintanpatel/otter/archive/refs/heads/main.zip" -OutFile $ZipPath -ErrorAction Stop
                Expand-Archive -Path $ZipPath -DestinationPath "$TmpDir\extracted" -Force
                if (Test-Path -Path "$TmpDir\extracted\otter-main") {
                    Copy-Item -Path "$TmpDir\extracted\otter-main\*" -Destination $TmpDir -Recurse -Force
                    $CloneSuccess = $true
                }
            } catch {}
        }
    }

    if ($CloneSuccess) {
        $SrcDir = $TmpDir
    }
}

# Setup binary: look for any built binaries or build from source
Write-Host "  Setting up binaries ..."
$SourceExe = ""
if (Test-Path -Path "$PSScriptRoot\..\target\release\otter.exe") {
    $SourceExe = "$PSScriptRoot\..\target\release\otter.exe"
} elseif (Test-Path -Path "target\release\otter.exe") {
    $SourceExe = "target\release\otter.exe"
} elseif (Test-Path -Path "otter.exe") {
    $SourceExe = "otter.exe"
}

if ($SourceExe -ne "") {
    Copy-Item -Path $SourceExe -Destination "$BinDir\otter.exe" -Force
} elseif ($SrcDir -ne "") {
    # Ensure cargo is present or download/prompt
    $HasCargo = $false
    if (Get-Command cargo -ErrorAction SilentlyContinue) {
        $HasCargo = $true
    }

    if ($HasCargo) {
        Write-Host "  Building Rust GUI from source (this might take a few minutes)..."
        Push-Location $SrcDir
        try {
            cargo build --release
            Pop-Location
            if (Test-Path -Path "$SrcDir\target\release\otter.exe") {
                Copy-Item -Path "$SrcDir\target\release\otter.exe" -Destination "$BinDir\otter.exe" -Force
                Write-Host "  Built and copied otter.exe successfully."
            } else {
                Write-Host "  Error: Built binary not found after cargo build." -ForegroundColor Red
                exit 1
            }
        } catch {
            Pop-Location
            Write-Host "  Error: Build failed." -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "  Error: Rust/Cargo is not installed. Unable to compile source." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "  Error: Source directory could not be resolved." -ForegroundColor Red
    exit 1
}

# Copy logo and scripts
Write-Host "  Copying assets and scripts ..."
$AssetsDir = "$OtterDir\assets"
$ScriptsDir = "$OtterDir\scripts"
New-Item -ItemType Directory -Force -Path $AssetsDir | Out-Null
New-Item -ItemType Directory -Force -Path $ScriptsDir | Out-Null

if ($SrcDir -ne "") {
    if (Test-Path -Path "$SrcDir\assets\logo.png") {
        Copy-Item -Path "$SrcDir\assets\logo.png" -Destination "$AssetsDir\logo.png" -Force
    }
    if (Test-Path -Path "$SrcDir\scripts\fetch.ps1") {
        Copy-Item -Path "$SrcDir\scripts\fetch.ps1" -Destination "$ScriptsDir\fetch.ps1" -Force
    }
}

# Ensure binary is in Path
Write-Host "  Configuring system environment PATH ..."
$UserPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
if ($UserPath -notlike "*$BinDir*") {
    [System.Environment]::SetEnvironmentVariable("Path", "$UserPath;$BinDir", "User")
    $env:PATH = "$env:PATH;$BinDir"
}

Write-Host ""
Write-Host "  Installation complete."
Write-Host "  Run: otter"
Write-Host "  Config: $ConfigDir\config.json"
Write-Host ""
