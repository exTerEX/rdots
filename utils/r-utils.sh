#!/usr/bin/env bash

# Get the R bin directory path by finding where Rscript is located
get_r_bin_path() {
    if ! command -v Rscript &>/dev/null; then
        echo ""
        return 1
    fi
    dirname "$(command -v Rscript)"
}

# Get the latest installed R version string (e.g. "4.6")
get_r_version() {
    if ! command -v Rscript &>/dev/null; then
        echo ""
        return 1
    fi
    Rscript -e "cat(paste(R.Version()\$major, R.Version()\$minor, sep='.'))" 2>/dev/null
}

# Get the R installation root path (e.g. /usr/lib/R or /Library/Frameworks/R.framework/Resources)
get_r_path() {
    if ! command -v Rscript &>/dev/null; then
        echo ""
        return 1
    fi
    Rscript -e "cat(R.home())" 2>/dev/null
}

# Get the site library path as determined by R itself
get_r_site_lib() {
    if ! command -v Rscript &>/dev/null; then
        echo ""
        return 1
    fi
    local site_lib
    site_lib=$(Rscript -e "if(length(.Library.Site) > 0) cat(.Library.Site[1]) else cat(.Library[2])" 2>/dev/null)
    if [ -z "$site_lib" ]; then
        # Fallback: use a common default
        site_lib="/usr/local/lib/R/site-library"
    fi
    echo "$site_lib"
}
