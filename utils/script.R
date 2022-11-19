fp_site <- file.path("site-pkgs.txt")

repo <- "https://cloud.r-project.org"

pkgs_site <- scan(fp_site, character(), sep = "\n")

install.packages(pkgs_site, lib = .Library.Site, repos=repo, quiet=T)

fp_user <- file.path("user-pkgs.txt")

pkgs_user <- scan(fp_user, character(), sep = "\n")

install.packages(pkgs_user, lib = .Library, repos=repo, quiet=T)
