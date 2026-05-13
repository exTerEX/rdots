#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Import helper functions
source "$SCRIPT_DIR/utils/sh-utils.sh"
source "$SCRIPT_DIR/utils/r-utils.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}Starting R configuration setup...${NC}"

# Detect platform
OS="$(uname -s)"
case "$OS" in
    Linux)  echo -e "${YELLOW}Platform: Linux${NC}" ;;
    Darwin) echo -e "${YELLOW}Platform: macOS${NC}" ;;
    *)      echo -e "${RED}Error: Unsupported platform '$OS'. Only Linux and macOS are supported by this script.${NC}"; exit 1 ;;
esac

RCONFIG="$HOME/.config/R"
RPROFILEPATH="$RCONFIG/.Rprofile"

# Create R config directory
echo -e "${CYAN}Creating R config directory...${NC}"
make_directory "$RCONFIG"

# Detect R installation
echo -e "${CYAN}Detecting R installation...${NC}"
if ! command -v Rscript &>/dev/null; then
    echo -e "${RED}Error: Rscript not found in PATH. Please ensure R is installed and in your PATH.${NC}"
    exit 1
fi

R_VERSION="$(get_r_version)"
if [ -z "$R_VERSION" ]; then
    echo -e "${RED}Error: Could not determine R version.${NC}"
    exit 1
fi
echo -e "${YELLOW}Detected R version: $R_VERSION${NC}"

R_PATH="$(get_r_path)"
if [ -z "$R_PATH" ]; then
    echo -e "${RED}Error: Could not determine R installation path.${NC}"
    exit 1
fi
echo -e "${YELLOW}Detected R installation path: $R_PATH${NC}"

R_BIN_PATH="$(get_r_bin_path)"
if [ -z "$R_BIN_PATH" ]; then
    echo -e "${RED}Error: Could not determine R bin path.${NC}"
    exit 1
fi
echo -e "${YELLOW}Detected R bin path: $R_BIN_PATH${NC}"
R_SITE_LIB="$(get_r_site_lib)"
if [ -z "$R_SITE_LIB" ]; then
    echo -e "${RED}Error: Could not determine R site library path.${NC}"
    exit 1
fi
echo -e "${YELLOW}Detected R site library: $R_SITE_LIB${NC}"

# Major.minor version for user library (e.g. "4.6")
USER_VERSION="${R_VERSION%.*}"

# Create directories
echo -e "${CYAN}Creating VS Code R config directory...${NC}"
make_directory "$HOME/.vscode-R"

echo -e "${CYAN}Creating R user library directory...${NC}"
make_directory "$RCONFIG/lib/$USER_VERSION"

# Create .Rprofile symlink
echo -e "${CYAN}Creating symlink to .Rprofile...${NC}"
RPROFILE_SOURCE="$SCRIPT_DIR/assets/.Rprofile"
if [ ! -f "$RPROFILE_SOURCE" ]; then
    echo -e "${YELLOW}Warning: .Rprofile not found at $RPROFILE_SOURCE, skipping symlink${NC}"
else
    set_softlink "$RPROFILEPATH" "$RPROFILE_SOURCE"
fi

# Write R environment variables to ~/.Renviron (idempotent)
echo -e "${CYAN}Setting R environment variables in ~/.Renviron...${NC}"
RENVIRON="$HOME/.Renviron"
touch "$RENVIRON"

set_renviron_var() {
    local key="$1"
    local value="$2"
    if grep -q "^${key}=" "$RENVIRON" 2>/dev/null; then
        # Replace existing entry
        sed -i.bak "s|^${key}=.*|${key}=${value}|" "$RENVIRON" && rm -f "${RENVIRON}.bak"
    else
        echo "${key}=${value}" >> "$RENVIRON"
    fi
}

set_renviron_var "R_LIBS_USER"    "$RCONFIG/lib/$USER_VERSION"
set_renviron_var "R_LIBS_SITE"    "$R_SITE_LIB"
set_renviron_var "R_PROFILE_USER" "$RPROFILEPATH"

echo -e "${YELLOW}R environment variables written to $RENVIRON${NC}"

# Validate R installation
echo -e "${CYAN}Validating R installation...${NC}"
R_VERSION_STRING="$(Rscript -e "cat(R.version.string)" 2>&1)"
if [ $? -eq 0 ]; then
    echo -e "${YELLOW}R validation successful: $R_VERSION_STRING${NC}"
else
    echo -e "${YELLOW}Warning: R validation returned a non-zero exit code${NC}"
fi

# Install site-wide R packages
echo -e "${CYAN}Installing site-wide R packages...${NC}"
RSCRIPT_BIN="$R_BIN_PATH/Rscript"
if [ ! -f "$RSCRIPT_BIN" ]; then
    echo -e "${RED}Error: Rscript not found at $RSCRIPT_BIN${NC}"
    exit 1
fi

export R_LIBS_SITE="$R_SITE_LIB"
export R_LIBS_USER="$RCONFIG/lib/$USER_VERSION"

if sudo "$RSCRIPT_BIN" "$SCRIPT_DIR/utils/script.R" "$SCRIPT_DIR/assets"; then
    echo -e "${YELLOW}R packages installed successfully${NC}"
else
    echo -e "${YELLOW}Warning: R package installation completed with errors (exit code: $?)${NC}"
fi

echo -e "${GREEN}R configuration completed successfully!${NC}"
