# Count all matching January requests
count_query <- paste(
  "SELECT count(*) AS total_requests",
  "WHERE agency = 'DSNY'",
  "AND created_date >= '2025-01-01T00:00:00'",
  "AND created_date < '2025-02-01T00:00:00'"
)

count_url <- paste0(
  "https://data.cityofnewyork.us/resource/erm2-nwe9.csv?$query=",
  URLencode(count_query, reserved = TRUE)
)

options(timeout = 120)

january_count <- read.csv(count_url)

print(january_count)

dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)

total_requests <- as.integer(january_count$total_requests[1])
batch_size <- 5000
batches <- list()

for (offset in seq(0, total_requests - 1, by = batch_size)) {
  
  query <- paste(
    "SELECT unique_key, created_date, closed_date,",
    "agency, complaint_type, status, borough",
    "WHERE agency = 'DSNY'",
    "AND created_date >= '2025-01-01T00:00:00'",
    "AND created_date < '2025-02-01T00:00:00'",
    "ORDER BY created_date, unique_key",
    "LIMIT", batch_size,
    "OFFSET", offset
  )
  
  data_url <- paste0(
    "https://data.cityofnewyork.us/resource/erm2-nwe9.csv?$query=",
    URLencode(query, reserved = TRUE)
  )
  
  batch <- read.csv(
    data_url,
    colClasses = "character",
    na.strings = ""
  )
  
  batches[[length(batches) + 1]] <- batch
  
  message("Downloaded ", offset + nrow(batch), " records")
}

january_requests <- do.call(rbind, batches)

# Check completeness and duplicate IDs before saving
stopifnot(
  nrow(january_requests) == total_requests,
  anyDuplicated(january_requests$unique_key) == 0
)

write.csv(
  january_requests,
  "data/raw/dsny_jan2025.csv",
  row.names = FALSE,
  na = ""
)

dim(january_requests)