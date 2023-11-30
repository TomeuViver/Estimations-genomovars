#!/usr/bin/env Rscript

library(enveomics.R)
samples <- read.table("subsample/count95.tsv", sep = "\t", header = FALSE)

pdf("rarefaction/projection.pdf")

col <- rainbow(nrow(samples), s = 3/4, v = 3/4)
pred <- data.frame()

layout(matrix(1:4, ncol = 2))
for (i in 1:nrow(samples)) {
  par(bty = "l")
  plot(
    1, ylim = c(1, 1e5), xlim = c(0.4, 1), log = "y",
    ylab = "Dereplicated genomes (genomovars)",
    xlab = "Fraction of the reads (%)",
    type = "n", xaxt = "n", yaxt = "n", xaxs = "i", yaxs = "i",
  )
  axis(1, at = seq(0.4, 1, by = 0.1), seq(40, 100, by = 10))
  axis(1, at = seq(0.4, 1, by = 0.01), NA, tck = -0.01)
  axis(2, at = 10 ^ (0:5), parse(text = paste("10 ^", 0:5)), las = 1)
  axis(2, at = rep(10 ^ (0:5), each = 9) * (1:9), NA, tck = -0.01)

  cat(samples[i, 1], "\n")

  a <- read.table(
    paste0("rarefaction/", samples[i, 1], ".tsv"),
    sep = "\t", header = FALSE, row.names = 1
  )
  genomes <- as.numeric(rownames(a)) # Genomes
  reads <- apply(a, 1, median) # Reads
  genomes.20 <- rep(genomes[genomes > 20], each = ncol(a))
  readsfrx.20 <- as.numeric(t(a[genomes > 20, ])) / samples[i, 2]
  lm <- lm(log(genomes.20) ~ log(readsfrx.20))

  points(
    unlist(a) / samples[i, 2], rep(genomes, ncol(a)),
    cex = 1/8, pch = 19, col = enve.col.alpha(col[i], 0.1)
  )

  proj.reads.frx <- seq(0.2, 1.0, by = 0.1)
  proj <- exp(predict(
    lm, data.frame(readsfrx.20 = proj.reads.frx),
    interval = "prediction", level = 0.99
  ))
  print(proj)

  abline(h = 20, lty = 3, col = "grey")
  polygon(
    c(proj.reads.frx, rev(proj.reads.frx)),
    c(proj[, 2], rev(proj[, 3])),
    col = enve.col.alpha(col[i], 0.1),
    border = NA
  )
  lines(
    proj.reads.frx, proj[, 1],
    col = enve.col.alpha(col[i], 0.5)
  )
  for(edge in seq(0, 0.5, by = 0.1)) {
    polygon(
      c(
        apply(a, 1, quantile, p = edge, names = FALSE) / samples[i, 2],
        rev(apply(a, 1, quantile, p = 1.0 - edge, names = FALSE) / samples[i, 2])
      ),
      c(genomes, rev(genomes)),
      border = NA,
      col = enve.col.alpha(col[i], 0.25)
    )
  }
  lines(reads / samples[i, 2], genomes, col = col[i])
  pred <- rbind(pred, c(samples[i, 1], tail(proj, n = 1)))
  legend(
    "topleft", col = c(col[i], NA), pch = c(19, NA), bty = "n",
    legend = c(
      samples[i, 1], paste("Estimated:", signif(tail(proj[, 1], n = 1), 6))
    )
  )
}
colnames(pred) <- c("sample", "strains_fit", "strains_lwr", "strains_upr")
write.table(
  pred, "rarefaction/projection.tsv", sep = "\t",
  col.names = TRUE, row.names = FALSE, quote = FALSE
)
t <- dev.off()

