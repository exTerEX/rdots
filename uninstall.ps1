#!/usr/bin/env pwsh

#Requires -Version 5
#Requires -RunAsAdministrator

# Import helper functions
. "$PSScriptRoot\utils\r-utils.ps1"

Write-Host "Starting R configuration uninstall..." -ForegroundColor "Green"

[string]$RCONFIG = "$HOME\.config\R"
[string]$SITERLIBPATH = "C:\ProgramData\R\library"
[string]$RPROFILEPATH = Join-Path -Path $RCONFIG -ChildPath ".Rprofile"

# Detect R bin path to remove from system PATH
$detectedRPath = Get-RPath
if ($detectedRPath) {
    $detectedRBinPath = Get-RBinPath $detectedRPath

    Write-Host "Removing R from system PATH..." -ForegroundColor "Cyan"
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $updatedPath = ($currentPath -split ";" | Where-Object { $_ -ne $detectedRBinPath }) -join ";"
    if ($updatedPath -ne $currentPath) {
        [Environment]::SetEnvironmentVariable("Path", $updatedPath, "Machine")
        Write-Host "Removed R from system PATH" -ForegroundColor "Yellow"
    } else {
        Write-Host "R was not found in system PATH" -ForegroundColor "Yellow"
    }
} else {
    Write-Host "Could not detect R installation, skipping PATH cleanup" -ForegroundColor "Yellow"
}

# Remove environment variables
Write-Host "Removing environment variables..." -ForegroundColor "Cyan"
[System.Environment]::SetEnvironmentVariable("R_PATH", $null, "Machine")
[System.Environment]::SetEnvironmentVariable("R_LIBS_SITE", $null, "Machine")
[System.Environment]::SetEnvironmentVariable("R_PROFILE_USER", $null, "User")
[System.Environment]::SetEnvironmentVariable("R_LIBS_USER", $null, "User")
Write-Host "Environment variables removed" -ForegroundColor "Yellow"

# Remove .Rprofile symlink
Write-Host "Removing .Rprofile symlink..." -ForegroundColor "Cyan"
if (Test-Path -Path $RPROFILEPATH) {
    $item = Get-Item -Path $RPROFILEPATH -Force
    if ($item.LinkType -eq "SymbolicLink") {
        Remove-Item -Path $RPROFILEPATH -Force
        Write-Host "Removed .Rprofile symlink" -ForegroundColor "Yellow"
    } else {
        Write-Host "Warning: $RPROFILEPATH exists but is not a symlink, skipping" -ForegroundColor "Yellow"
    }
} else {
    Write-Host ".Rprofile symlink not found, skipping" -ForegroundColor "Yellow"
}

# Remove R config directory
Write-Host "Removing R config directory ($RCONFIG)..." -ForegroundColor "Cyan"
if (Test-Path -Path $RCONFIG) {
    Remove-Item -Path $RCONFIG -Recurse -Force
    Write-Host "Removed R config directory" -ForegroundColor "Yellow"
} else {
    Write-Host "R config directory not found, skipping" -ForegroundColor "Yellow"
}

# Remove site library directory
Write-Host "Removing site library directory ($SITERLIBPATH)..." -ForegroundColor "Cyan"
if (Test-Path -Path $SITERLIBPATH) {
    Remove-Item -Path $SITERLIBPATH -Recurse -Force
    Write-Host "Removed site library directory" -ForegroundColor "Yellow"
} else {
    Write-Host "Site library directory not found, skipping" -ForegroundColor "Yellow"
}

# Remove VS Code R helper directory
Write-Host "Removing VS Code R config directory..." -ForegroundColor "Cyan"
$vsCodeRPath = "$HOME\.vscode-R"
if (Test-Path -Path $vsCodeRPath -ErrorAction SilentlyContinue) {
    Remove-Item -Path $vsCodeRPath -Recurse -Force
    Write-Host "Removed VS Code R config directory" -ForegroundColor "Yellow"
} else {
    Write-Host "VS Code R config directory not found, skipping" -ForegroundColor "Yellow"
}

Write-Host "R configuration uninstall completed successfully!" -ForegroundColor "Green"
