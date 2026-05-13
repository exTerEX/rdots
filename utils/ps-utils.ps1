#!/usr/bin/env pwsh

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


