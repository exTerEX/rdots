#  ------------------------------------------------------------------------
#
# Title : .Rprofile - Andreas Sagen
#    By : Andreas Sagen
#  Date : 2022-11-18
#
#  ------------------------------------------------------------------------

# Ensure Library is set:
#.libPaths("~/.config/R/lib/4.2")

# Set Default Options:
options(
  repos = c(CRAN = "https://cran.rstudio.com"),
  editor = "notepad",
  pager = "internal",
  useFancyQuotes = FALSE,
  tab.width = 2,
  browserNLdisabled = TRUE,
  max.print = 200,
  shiny.launch.browser = TRUE,
  Ncpus = parallel::detectCores(),
  scipen = 999,
  languageserver.snippet_support = FALSE,
  vsc.use_httpgd = TRUE,
  languageserver.server_capabilities = list(documentHighlightProvider = FALSE),
  remotes.install.args = "--no-multiarch",
  devtools.install.args = "--no-multiarch",
  usethis.full_name = "Andreas Sagen",
  usethis.protocol = "ssh",
  usethis.description = list(
    `Authors@R` = 'person("Andreas", "Sagen",
                         email = "andreassag@hotmail.no",
                         role = c("aut", "cre"),
                         comment = c(ORCID = "0000-0003-1193-8304"))',
    License = "MIT",
    Language = "en-US"
  ),
  orcid = "0000-0003-1193-8304"
)

# turn on completion of installed package names
utils::rc.settings(ipck = TRUE)

# clear env
rm(list = ls())
