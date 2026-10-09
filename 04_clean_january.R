// Load the January data
january <- read.csv(
  "data/raw/dsny_jan2025.csv",
  colClasses = "character",
  na.strings = ""
)

// Preserve the original dates
created_text <- january$created_date
closed_text <- january$closed_date

// Convert the dates
january$created_date <- as.POSIXct(
  created_text,
  format = "%Y-%m-%dT%H:%M:%S",
  tz = "America/New_York"
)

january$closed_date <- as.POSIXct(
  closed_text,
  format = "%Y-%m-%dT%H:%M:%S",
  tz = "America/New_York"
)

// Validate the conversion
parse_failures <- c(
  created = sum(!is.na(created_text) & is.na(january$created_date)),
  closed = sum(!is.na(closed_text) & is.na(january$closed_date))
)

print(parse_failures)
stopifnot(all(parse_failures == 0))

// Calculate closure times
january$closure_hours <- as.numeric(
  difftime(
    january$closed_date,
    january$created_date,
    units = "hours"
  )
)

negative_count <- sum(january$closure_hours < 0, na.rm = TRUE)
print(c(negative_durations = negative_count))
stopifnot(negative_count == 0)

print(summary(january$closure_hours))

// Summarize each problem type
january_summary <- do.call(
  rbind,
  lapply(split(january, january$complaint_type), function(group) {
    
    hours <- group$closure_hours
    recorded <- hours[!is.na(hours)]
    
    data.frame(
      problem = group$complaint_type[1],
      total_requests = nrow(group),
      with_closure_time = length(recorded),
      missing_closure_time = sum(is.na(hours)),
      median_hours = if (length(recorded) > 0) median(recorded) else NA_real_,
      mean_hours = if (length(recorded) > 0) mean(recorded) else NA_real_
    )
  })
)

january_summary <- january_summary[
  order(january_summary$total_requests, decreasing = TRUE),
]

rownames(january_summary) <- NULL

# Verify that category counts match the dataset
stopifnot(
  sum(january_summary$total_requests) == nrow(january),
  all(
    january_summary$with_closure_time +
      january_summary$missing_closure_time ==
      january_summary$total_requests
  )
)

print(head(january_summary, 10), row.names = FALSE)

// Save the results
dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs", showWarnings = FALSE)

saveRDS(january, "data/processed/dsny_jan2025_clean.rds")

write.csv(
  january_summary,
  "outputs/closure_summary_january.csv",
  row.names = FALSE
)
