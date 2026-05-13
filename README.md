# R dotfiles

A cross-platform R environment setup that configures directory structures, environment variables, and installs site-wide packages. Supports Windows (x64/ARM64), Linux, and macOS.

## Prerequisites

R must already be installed before running the setup scripts.

### Windows

- Windows 10/11 (x64 or ARM64)
- [PowerShell 5+](https://github.com/PowerShell/PowerShell/releases)
- Run as Administrator

### Linux / macOS

- Bash
- `Rscript` available in PATH
- `sudo` access (required for writing to the site library)

## What it sets up

### Windows configuration

| Item | Location |
| --- | --- |
| R config directory | `~\.config\R` |
| User package library | `~\.config\R\lib\<major.minor>\` |
| Site package library | `C:\ProgramData\R\library` |
| `.Rprofile` symlink | `~\.config\R\.Rprofile` → `assets\.Rprofile` |
| VS Code R helper directory | `~\.vscode-R\` (hidden) |

Environment variables set at Machine/User scope: `R_PATH`, `R_LIBS_SITE`, `R_PROFILE_USER`, `R_LIBS_USER`

### Linux / macOS configuration

| Item | Location |
| --- | --- |
| R config directory | `~/.config/R` |
| User package library | `~/.config/R/lib/<major.minor>/` |
| Site package library | As reported by R (`.Library.Site`) |
| `.Rprofile` symlink | `~/.config/R/.Rprofile` → `assets/.Rprofile` |
| VS Code R helper directory | `~/.vscode-R/` |

Environment variables written to `~/.Renviron`: `R_LIBS_USER`, `R_LIBS_SITE`, `R_PROFILE_USER`

## Usage

**Windows** — run PowerShell as Administrator:

```powershell
.\setup.ps1
```

To undo:

```powershell
.\uninstall.ps1
```

**Linux / macOS**:

```bash
bash setup.sh
```

To undo:

```bash
bash uninstall.sh
```

## Repository structure

```text
assets/
    .Rprofile           # R startup configuration (shared across platforms)
    site-pkgs.txt       # Site-wide R packages to install (shared across platforms)
utils/
    ps-utils.ps1        # General PowerShell helper functions (Windows)
    r-utils.ps1         # R-specific PowerShell helper functions (Windows)
    sh-utils.sh         # General shell helper functions (Linux/macOS)
    r-utils.sh          # R-specific shell helper functions (Linux/macOS)
    script.R            # R package installation script (shared across platforms)
setup.ps1               # Main setup script (Windows)
setup.sh                # Main setup script (Linux/macOS)
uninstall.ps1           # Cleanup/uninstall script (Windows)
uninstall.sh            # Cleanup/uninstall script (Linux/macOS)
```

## Site packages

Packages listed in `assets/site-pkgs.txt` are installed to the shared site library and are available to all users on the machine. User-level packages should be managed per-project using [renv](https://rstudio.github.io/renv/).
