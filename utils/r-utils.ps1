#!/usr/bin/env pwsh

# Get the architecture-specific R bin path
function Get-RBinPath {
    param([Parameter(Mandatory)][string]$RootPath)

    $arch = (Get-CimInstance -ClassName Win32_Processor).Architecture
    # 12 = ARM64, 9 = x64
    $binSubdir = if ($arch -eq 12) { "bin\arm64" } else { "bin\x64" }
    return Join-Path -Path $RootPath -ChildPath $binSubdir
}

# Get the latest installed R version from Program Files
function Get-RVersion {
    $RInstalls = Get-ChildItem -Path "$Env:ProgramFiles\R" -ErrorAction SilentlyContinue | 
        Where-Object { $_.Name -match '^R-\d+\.\d+\.\d+' } |
        Sort-Object { [version]($_.Name -replace '^R-') } -Descending
    
    if ($RInstalls) {
        return $RInstalls[0].Name -replace '^R-'
    }
    return $null
}

# Get the latest installed R installation path from Program Files
function Get-RPath {
    $RInstalls = Get-ChildItem -Path "$Env:ProgramFiles\R" -ErrorAction SilentlyContinue | 
        Where-Object { $_.Name -match '^R-\d+\.\d+\.\d+' } |
        Sort-Object { [version]($_.Name -replace '^R-') } -Descending
    
    if ($RInstalls) {
        return $RInstalls[0].FullName
    }
    return $null
}
