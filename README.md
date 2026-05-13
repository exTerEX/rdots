# R dotfiles

A Windows-specific R environment setup script that installs and configures R, sets up directory structures, environment variables, and installs site-wide packages.

## Prerequisites

- Windows 10/11 (x64 or ARM64)
- [PowerShell 5+](https://github.com/PowerShell/PowerShell/releases)
- [winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/) (comes with Windows 10/11)
- R must already be installed (the script detects the installed version automatically)

## What it sets up

| Item | Location |
|------|----------|
| R config directory | `~\.config\R` |
| User package library | `~\.config\R\lib\<major.minor>\` |
| Site package library | `C:\ProgramData\R\library` |
| `.Rprofile` symlink | `~\.config\R\.Rprofile` → `assets\.Rprofile` |
| VS Code R helper directory | `~\.vscode-R\` (hidden) |

**Environment variables set:**

| Variable | Scope | Value |
|----------|-------|-------|
| `R_PATH` | Machine | Path to R bin directory |
| `R_LIBS_SITE` | Machine | `C:\ProgramData\R\library` |
| `R_PROFILE_USER` | User | Path to `.Rprofile` symlink |
| `R_LIBS_USER` | User | Path to user package library |

## Usage

Run PowerShell as **Administrator**, then:

```powershell
.\setup.ps1
```

To undo all changes made by setup:

```powershell
.\uninstall.ps1
```

## Repository structure

```
assets/
    .Rprofile       # R startup configuration
    site-pkgs.txt   # Site-wide R packages to install
utils/
    ps-utils.ps1    # General PowerShell helper functions
    r-utils.ps1     # R-specific PowerShell helper functions
    script.R        # R package installation script
setup.ps1           # Main setup script
uninstall.ps1       # Cleanup/uninstall script
```

## Site packages

Packages listed in `assets/site-pkgs.txt` are installed to the shared site library (`C:\ProgramData\R\library`) and are available to all users on the machine.

User-level packages should be managed per-project using [renv](https://rstudio.github.io/renv/).
