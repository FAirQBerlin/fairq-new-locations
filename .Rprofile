# When starting a new R session, a specific directory is added to the libPath.
# It's called lib. As it is on the first libPath position,
# packages are installed into this directory by default. This enables working in
# a sandbox.

.First <- function() {
  .libPaths(new = c(paste(getwd(), "lib/", sep = "/"), .libPaths()))
}

