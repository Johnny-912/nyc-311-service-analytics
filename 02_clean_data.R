# Load the original sample
requests <- read.csv(
  "data/raw/dsny_jan2025_sample.csv",
  colClasses = "character",
  na.strings = ""
)

# Create a working copy
clean_requests <- requests

# Convert date text into date-time values
clean_requests$created_date <- as.POSIXct(
  requests$created_date,
  format = "%Y-%m-%dT%H:%M:%S",
  tz = "America/New_York"
)

clean_requests$closed_date <- as.POSIXct(
  requests$closed_date,
  format = "%Y-%m-%dT%H:%M:%S",
  tz = "America/New_York"
)

# Check whether conversion introduced missing values
c(
  created_parse_failures = sum(
    !is.na(requests$created_date) &
      is.na(clean_requests$created_date)
  ),
  closed_parse_failures = sum(
    !is.na(requests$closed_date) &
      is.na(clean_requests$closed_date)
  )
)

# Calculate elapsed hours from creation to closure
clean_requests$closure_hours <- as.numeric(
  difftime(
    clean_requests$closed_date,
    clean_requests$created_date,
    units = "hours"
  )
)

# Check for impossible negative durations
sum(clean_requests$closure_hours < 0, na.rm = TRUE)

# Summarize closure times
summary(clean_requests$closure_hours)

# Find the 10 longest recorded closure times
closed_requests <- clean_requests[
  !is.na(clean_requests$closure_hours),
]

longest_requests <- closed_requests[
  order(closed_requests$closure_hours, decreasing = TRUE),
]

head(
  longest_requests[c(
    "unique_key", "complaint_type", "status",
    "created_date", "closed_date", "closure_hours"
  )],
  10
)

# Summarize records that have a closure time
closure_summary <- aggregate(
  closure_hours ~ complaint_type,
  data = closed_requests,
  FUN = function(x) c(
    count = length(x),
    median_hours = median(x),
    mean_hours = mean(x)
  )
)

# Put the results into separate columns
closure_summary <- data.frame(
  complaint_type = closure_summary$complaint_type,
  closure_summary$closure_hours
)

# Sort by median closure time
closure_summary <- closure_summary[
  order(closure_summary$median_hours, decreasing = TRUE),
]

print(closure_summary, row.names = FALSE)

# Create output folders
dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs", showWarnings = FALSE)

# Preserve the cleaned data, including date-time types
saveRDS(
  clean_requests,
  "data/processed/dsny_jan2025_sample_clean.rds"
)

# Save the summary for Excel
write.csv(
  closure_summary,
  "outputs/closure_summary_sample.csv",
  row.names = FALSE
)