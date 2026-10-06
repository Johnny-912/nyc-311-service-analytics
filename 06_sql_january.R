library(DBI)
library(duckdb)

# Load the cleaned January data
january <- readRDS("data/processed/dsny_jan2025_clean.rds")

# Open a temporary database and add the data
con <- dbConnect(duckdb(), dbdir = ":memory:")
dbWriteTable(con, "requests", january)

# Summarize requests by borough using SQL
borough_query <- "
SELECT
  borough,
  COUNT(*) AS total_requests,
  COUNT(closure_hours) AS with_closure_time,
  COUNT(*) - COUNT(closure_hours) AS missing_closure_time,
  ROUND(MEDIAN(closure_hours), 2) AS median_hours
FROM requests
GROUP BY borough
ORDER BY total_requests DESC
"

borough_summary <- dbGetQuery(con, borough_query)
print(borough_summary)

# Check that all requests are accounted for
stopifnot(sum(borough_summary$total_requests) == nrow(january))

# Save the query and results
dir.create("sql", showWarnings = FALSE)
dir.create("outputs", showWarnings = FALSE)

writeLines(borough_query, "sql/january_by_borough.sql")

write.csv(
  borough_summary,
  "outputs/january_by_borough.csv",
  row.names = FALSE
)

# Compare Dirty Condition requests across boroughs
dirty_query <- "
SELECT
  borough,
  COUNT(*) AS total_requests,
  COUNT(closure_hours) AS with_closure_time,
  ROUND(MEDIAN(closure_hours), 2) AS median_hours
FROM requests
WHERE complaint_type = 'Dirty Condition'
  AND borough <> 'Unspecified'
GROUP BY borough
ORDER BY median_hours DESC
"

dirty_summary <- dbGetQuery(con, dirty_query)
print(dirty_summary)

writeLines(dirty_query, "sql/dirty_condition_by_borough.sql")

write.csv(
  dirty_summary,
  "outputs/dirty_condition_by_borough.csv",
  row.names = FALSE
)

# Calculate the same medians independently in R
dirty_r <- subset(
  january,
  complaint_type == "Dirty Condition" &
    borough != "Unspecified" &
    !is.na(closure_hours)
)

r_check <- aggregate(
  closure_hours ~ borough,
  data = dirty_r,
  FUN = median
)

r_check$closure_hours <- round(r_check$closure_hours, 2)

comparison <- merge(dirty_summary, r_check, by = "borough")

names(comparison)[names(comparison) == "closure_hours"] <-
  "r_median_hours"

print(comparison)

stopifnot(
  all(abs(comparison$median_hours -
            comparison$r_median_hours) < 0.01)
)

message("SQL and R medians match.")

# Close the database
dbDisconnect(con, shutdown = TRUE)