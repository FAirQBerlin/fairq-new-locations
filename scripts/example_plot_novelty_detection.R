# This code creates an example plot to explain the principle of novelty detection.
# It was used in a presentation for the SenUMVK.

library(rdist)
library(viridisLite)

# Generate data ----

set.seed(546325)
ms_dat <- data.frame(x = c(0.1, 0.3, 1.0),
                     y = c(0.2, 0.6, 0.0))
grid_dat <- data.frame(x = runif(60),
                       y = runif(60))


# Compute distances between measuring stations and other grid cells ----

dist <- apply(cdist(ms_dat, grid_dat), 2, min)
cols <- viridis(length(dist))

grid_dat$dist <- dist
perm <- order(grid_dat$dist)
grid_dat <- grid_dat[perm,]

# Plot ----

p <- par()

plot(
  ms_dat$y,
  ms_dat$x,
  xlim = 0:1,
  ylim = 0:1,
  ylab = "b",
  xlab = "a",
  col = "steelblue",
  pch = 19,
  cex = 3
)

points(grid_dat$y, grid_dat$x, pch = 19, col = cols)

par(new = T,  mar = c(0, 0, 0, 0))

plot(
  NA,
  xlab = "",
  ylab = "",
  xlim = c(0, 1),
  ylim = c(0, 1),
  mar = c(0, 0, 0, 0),
  bty = "n"
)

legend(
  "topright",
  pch = 19,
  pt.cex = c(3, 1),
  legend = c("stations", "grid cells"),
  col = c("steelblue", "darkgrey"),
  bty = "n"
)

par(p)
