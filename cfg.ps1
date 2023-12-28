#!/usr/bin/env pwsh

#Requires -Version 5
#Requires -RunAsAdministrator

##### While unable to load module

# Hide the path file
function Hide-File {
    param([Parameter(Mandatory)][string]$Path)

    if (!(((Get-Item -Path $Path -Force).Attributes.ToString() -Split ", ") -Contains "Hidden")) {
        (Get-Item -Path $Path -Force).Attributes += "Hidden"
    }
}

# Create a new directory in path directory
function New-Directory {
    param ([Parameter(Mandatory)][string]$Path, [switch]$Hide)

    PROCESS {
        If (!(test-path $Path)) {
            New-Item -Path $Path -ItemType "directory" | Out-Null
        }

        if ($Hide) { Hide-File($Path) }
    }
}

# Create a softlink from path to target
function Set-Softlink {
    param ([Parameter(Mandatory)][string]$Path, [Parameter(Mandatory)][string]$Target, [switch]$Hide)

    PROCESS {
        if (Test-Path -Path $Path) {
            if (!(Get-Item $Path -Force).LinkType -eq "SymbolicLink") {
                Write-Host "Old file renamed to $((Get-Item -Path $Path).Name).old..." -ForegroundColor Blue
                Rename-Item -Path $Path -NewName "$((Get-Item -Path $Path).Name).old"

                Write-Host "Linking: $Target->$Path..." -ForegroundColor Blue
                New-Item -ItemType SymbolicLink -Path $Path -Target $Target -Force | Out-Null
            }
        }
        else {
            Write-Host "Linking: $Target->$Path..." -ForegroundColor Blue
            New-Item -ItemType SymbolicLink -Path $Path -Target $Target -Force | Out-Null
        }

        if ($Hide) { Hide-File($Path) }
    }
}

#####

# Import personal helper files for PowerShell
#Import-Module -Name "$PSScriptRoot\utils\pwsh-utils\fs-manipulation.ps1" -Verbose

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
