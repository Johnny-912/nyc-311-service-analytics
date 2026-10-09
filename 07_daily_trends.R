# Load the cleaned January data
january <- readRDS("data/processed/dsny_jan2025_clean.rds")

# Extract the creation date in New York time
january$request_date <- as.Date(
  january$created_date,
  tz = "America/New_York"
)

# Count requests for every day in January
january_days <- seq(
  as.Date("2025-01-01"),
  as.Date("2025-01-31"),
  by = "day"
)

daily_summary <- data.frame(
  date = january_days,
  total_requests = as.integer(
    table(factor(january$request_date, levels = january_days))
  )
)

# Check that all requests are included
stopifnot(sum(daily_summary$total_requests) == nrow(january))

# Save the daily counts
write.csv(
  daily_summary,
  "outputs/january_daily_requests.csv",
  row.names = FALSE
)

# Show the five busiest days
print(
  head(
    daily_summary[order(-daily_summary$total_requests), ],
    5
  ),
  row.names = FALSE
)
# Plot daily request volume
png(
  "outputs/january_daily_requests.png",
  width = 1600,
  height = 900,
  res = 150
)

plot(
  daily_summary$date,
  daily_summary$total_requests,
  type = "o",
  pch = 16,
  col = "steelblue",
  xlab = "Date",
  ylab = "Number of requests",
  main = "Daily NYC Sanitation Requests — January 2025"
)

dev.off()

# Find the busiest date
peak_date <- daily_summary$date[
  which.max(daily_summary$total_requests)
]

# Select requests created that day
peak_requests <- january[
  january$request_date == peak_date,
]

# Count requests by problem type
peak_summary <- as.data.frame(
  sort(table(peak_requests$complaint_type), decreasing = TRUE),
  stringsAsFactors = FALSE
)

names(peak_summary) <- c("problem", "total_requests")

write.csv(
  peak_summary,
  "outputs/january_peak_day_problems.csv",
  row.names = FALSE
)

print(head(peak_summary, 10), row.names = FALSE)