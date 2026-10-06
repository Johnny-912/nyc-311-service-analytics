# Read the saved summary
january_summary <- read.csv(
  "outputs/closure_summary_january.csv"
)

# Select the 10 busiest categories
top10 <- head(
  january_summary[
    order(january_summary$total_requests, decreasing = TRUE),
  ],
  10
)

# Reverse the order so the busiest appears at the top
top10 <- top10[nrow(top10):1, ]

# Save a horizontal bar chart
dir.create("outputs", showWarnings = FALSE)

png(
  "outputs/january_top10_requests.png",
  width = 1600,
  height = 1000,
  res = 150
)

par(mar = c(5, 16, 4, 2))

barplot(
  top10$total_requests,
  names.arg = top10$problem,
  horiz = TRUE,
  las = 1,
  col = "steelblue",
  border = NA,
  main = "Top 10 DSNY Request Types — January 2025",
  xlab = "Number of requests"
)

dev.off()