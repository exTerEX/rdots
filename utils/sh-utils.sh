#!/usr/bin/env bash

# Create a directory if it doesn't already exist
make_directory() {
    local path="$1"
    if [ ! -d "$path" ]; then
        mkdir -p "$path"
    fi
}

# Create a symbolic link from path to target
# If path exists and is not a symlink, rename it to <name>.old first
set_softlink() {
    local path="$1"
    local target="$2"

    if [ -e "$path" ] || [ -L "$path" ]; then
        if [ -L "$path" ]; then
            echo -e "\033[34mLinking: $target->$path...\033[0m"
            ln -sf "$target" "$path"
        else
            echo -e "\033[34mOld file renamed to $(basename "$path").old...\033[0m"
            mv "$path" "${path}.old"
            echo -e "\033[34mLinking: $target->$path...\033[0m"
            ln -sf "$target" "$path"
        fi
    else
        echo -e "\033[34mLinking: $target->$path...\033[0m"
        ln -sf "$target" "$path"
    fi
}
