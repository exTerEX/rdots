#!/usr/bin/env pwsh

#Requires -Version 5
#Requires -RunAsAdministrator

# Import helper functions
. "$PSScriptRoot\utils\ps-utils.ps1"
. "$PSScriptRoot\utils\r-utils.ps1"

Write-Host "Starting R configuration setup..." -ForegroundColor "Green"

# User-adjusted variables
[string]$RCONFIG = "$HOME\.config\R"

# Create config directory
Write-Host "Creating R config directory..." -ForegroundColor "Cyan"
New-Directory -Path "$RCONFIG"

# Detect R version and exit if not found
Write-Host "Detecting R installation..." -ForegroundColor "Cyan"
$detectedVersion = Get-RVersion
if (-not $detectedVersion) {
    Write-Host "Error: Could not detect R version. Please ensure R is installed." -ForegroundColor Red
    exit 1
}
Write-Host "Detected R version: $detectedVersion" -ForegroundColor "Yellow"

# Auto-adjusted variables
$detectedRPath = Get-RPath
if (-not $detectedRPath) {
    Write-Host "Error: Could not detect R installation path. Please ensure R is installed." -ForegroundColor Red
    exit 1
}
Write-Host "Detected R installation path: $detectedRPath" -ForegroundColor "Yellow"
[string]$USERVERSION = $([System.String]::Concat($detectedVersion.Major, ".", $detectedVersion.Minor))
[string]$RPROFILEPATH = $(Join-Path -Path "$RCONFIG" -ChildPath ".Rprofile")

# Create vscode-R config directory
Write-Host "Creating VS Code R config directory..." -ForegroundColor "Cyan"
New-Directory -Path "$HOME\.vscode-R" -Hide

# Create R config library directory
Write-Host "Creating R library directory..." -ForegroundColor "Cyan"
New-Directory -Path "$(Join-Path -Path "$RCONFIG\lib" -ChildPath $USERVERSION)"

# Create writable site library directory in ProgramData
Write-Host "Creating site library directory..." -ForegroundColor "Cyan"
[string]$SITERIBLIBPATH = "C:\ProgramData\R\library"
New-Directory -Path $SITERIBLIBPATH

# Display configuration summary
Write-Host "Configuring System..." -ForegroundColor "Green"

# Set R paths
Write-Host "Setting R environment paths..." -ForegroundColor "Cyan"
$detectedRBinPath = Get-RBinPath $detectedRPath

# Check if PATH already contains the R bin directory to prevent duplication
$currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($currentPath -notlike "*$detectedRBinPath*") {
    $ARRAYPATH = $currentPath -split ";"
    [Environment]::SetEnvironmentVariable("Path", ($ARRAYPATH + $detectedRBinPath) -join ";", "Machine")
    Write-Host "Added R to system PATH" -ForegroundColor "Yellow"
} else {
    Write-Host "R is already in system PATH" -ForegroundColor "Yellow"
}

# Validate .Rprofile exists before creating softlink
Write-Host "Creating softlink to .Rprofile..." -ForegroundColor "Cyan"
$rprofileSource = "$PSScriptRoot\assets\.Rprofile"
if (-not (Test-Path -Path $rprofileSource)) {
    Write-Host "Warning: .Rprofile not found at $rprofileSource" -ForegroundColor "Yellow"
} else {
    Set-Softlink -Path $RPROFILEPATH -Target $rprofileSource
}

# Set environment variables using the writable site library path
Write-Host "Setting environment variables..." -ForegroundColor "Cyan"
[System.Environment]::SetEnvironmentVariable("R_PATH", $detectedRBinPath, "Machine")
[System.Environment]::SetEnvironmentVariable("R_LIBS_SITE", $SITERIBLIBPATH, "Machine")
[System.Environment]::SetEnvironmentVariable("R_PROFILE_USER", $RPROFILEPATH, "User")
[System.Environment]::SetEnvironmentVariable("R_LIBS_USER", $(Join-Path -Path "$RCONFIG\lib" -ChildPath "$USERVERSION"), "User")

# Validate R installation
Write-Host "Validating R installation..." -ForegroundColor "Cyan"
$rExePath = Join-Path -Path $detectedRBinPath -ChildPath "Rscript.exe"
if (Test-Path -Path $rExePath) {
    $rVersionOutput = & $rExePath -e "cat(R.version.string)" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "R validation successful: $rVersionOutput" -ForegroundColor "Yellow"
    } else {
        Write-Host "Warning: R validation returned non-zero exit code" -ForegroundColor "Yellow"
    }
} else {
    Write-Host "Warning: Rscript.exe not found at $rExePath" -ForegroundColor "Yellow"
}

# Install standard R packages with error handling
Write-Host "Installing standard R packages..." -ForegroundColor "Cyan"
$rscriptPath = Join-Path -Path $detectedRBinPath -ChildPath "Rscript.exe"
if (Test-Path -Path $rscriptPath) {
    # Set session-level env vars so Rscript inherits the correct paths immediately
    $env:R_LIBS_SITE = $SITERIBLIBPATH
    $env:R_LIBS_USER = (Join-Path -Path "$RCONFIG\lib" -ChildPath "$USERVERSION")
    & $rscriptPath "$PSScriptRoot\utils\script.R" "$PSScriptRoot\assets"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Warning: R package installation completed with errors (exit code: $LASTEXITCODE)" -ForegroundColor "Yellow"
    } else {
        Write-Host "R packages installed successfully" -ForegroundColor "Yellow"
    }
} else {
    Write-Host "Error: Rscript.exe not found at $rscriptPath" -ForegroundColor "Red"
    exit 1
}

Write-Host "R configuration completed successfully!" -ForegroundColor "Green"
