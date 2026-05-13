args <- commandArgs(trailingOnly = TRUE)
assets_path <- if (length(args) > 0) args[1] else getwd()

fp_site <- file.path(assets_path, "site-pkgs.txt")

repo <- "https://cloud.r-project.org"

pkgs_site <- scan(fp_site, character(), sep = "\n")

# Get site library path from environment or use default
site_lib <- Sys.getenv("R_LIBS_SITE")
if (site_lib == "") {
  site_lib <- file.path(R.home(), "library")
}

install.packages(pkgs_site, lib = site_lib, repos=repo, quiet=T)
