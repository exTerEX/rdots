#!/usr/bin/env pwsh

#Requires -Version 5
#Requires -RunAsAdministrator

# User-adjusted variables
[string]$RCONFIG = "$HOME\.config\R"
[version]$RVERSION = "4.2.2"

# Auto-adjusted variables
[string]$RPATH = "$Env:Programfiles\R\R-$RVERSION)"
[string]$USERVERSION = $([System.String]::Concat($RVERSION.Major, ".", $RVERSION.Minor))
[string]$RPROFILEPATH = $(Join-Path -Path "$RCONFIG" -ChildPath ".Rprofile")

# Create related directories
New-Directory -Path "$HOME\.vscode-R" -Hide
New-Directory -Path "$RCONFIG"
New-Directory -Path "$(Join-Path -Path "$RCONFIG\lib" -ChildPath $USERVERSION)"

Write-Host "Configuring System..." -ForegroundColor "Green"

# Import personal helper files for PowerShell
Import-Module -Name "$PSScriptRoot\utils\pwsh-utils\fs-manipulation.ps1" -Verbose

# Install R for windows
winget install Rproject.R --scope machine --architecture x64 --location $RPATH --version $RVERSION # TODO: No install icons

# Install pandoc for RMarkdown support
winget install pandoc

# Set R paths
$RPATH = (Join-Path -Path $RPATH -ChildPath "bin\x64")
$ARRAYPATH = [Environment]::GetEnvironmentVariable("Path", "Machine") -split ";"
[Environment]::SetEnvironmentVariable("Path", ($ARRAYPATH + $RPATH) -join ";", "Machine")

# Create softlink to '.Rprofile'.
Set-Softlink -Path $RPROFILEPATH -Target "$PSScriptRoot\.Rprofile"

# Set environment variables
[System.Environment]::SetEnvironmentVariable("R_PATH", $RPATH, "Machine")
[System.Environment]::SetEnvironmentVariable("R_LIBS_SITE", $(Join-Path -Path "$RPATH" -ChildPath "library"), "Machine")
[System.Environment]::SetEnvironmentVariable("R_PROFILE_USER", $RPROFILEPATH, "User")
[System.Environment]::SetEnvironmentVariable("R_LIBS_USER", $(Join-Path -Path "$RCONFIG\lib" -ChildPath "$USERVERSION"), "User")

# Install standard R packages
Rscript script.R
