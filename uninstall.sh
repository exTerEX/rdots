#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Import helper functions
source "$SCRIPT_DIR/utils/r-utils.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}Starting R configuration uninstall...${NC}"

RCONFIG="$HOME/.config/R"
RPROFILEPATH="$RCONFIG/.Rprofile"
RENVIRON="$HOME/.Renviron"

# Remove .Rprofile symlink
echo -e "${CYAN}Removing .Rprofile symlink...${NC}"
if [ -L "$RPROFILEPATH" ]; then
    rm "$RPROFILEPATH"
    echo -e "${YELLOW}Removed .Rprofile symlink${NC}"
elif [ -e "$RPROFILEPATH" ]; then
    echo -e "${YELLOW}Warning: $RPROFILEPATH exists but is not a symlink, skipping${NC}"
else
    echo -e "${YELLOW}.Rprofile symlink not found, skipping${NC}"
fi

# Remove R config directory
echo -e "${CYAN}Removing R config directory ($RCONFIG)...${NC}"
if [ -d "$RCONFIG" ]; then
    rm -rf "$RCONFIG"
    echo -e "${YELLOW}Removed R config directory${NC}"
else
    echo -e "${YELLOW}R config directory not found, skipping${NC}"
fi

# Remove VS Code R helper directory
echo -e "${CYAN}Removing VS Code R config directory...${NC}"
VSCODE_R_PATH="$HOME/.vscode-R"
if [ -d "$VSCODE_R_PATH" ]; then
    rm -rf "$VSCODE_R_PATH"
    echo -e "${YELLOW}Removed VS Code R config directory${NC}"
else
    echo -e "${YELLOW}VS Code R config directory not found, skipping${NC}"
fi

# Remove R environment variables from ~/.Renviron
echo -e "${CYAN}Removing R environment variables from ~/.Renviron...${NC}"
if [ -f "$RENVIRON" ]; then
    sed -i.bak '/^R_LIBS_USER=/d; /^R_LIBS_SITE=/d; /^R_PROFILE_USER=/d' "$RENVIRON" && rm -f "${RENVIRON}.bak"
    echo -e "${YELLOW}Removed R environment variables from $RENVIRON${NC}"
else
    echo -e "${YELLOW}~/.Renviron not found, skipping${NC}"
fi

echo -e "${GREEN}R configuration uninstall completed successfully!${NC}"
