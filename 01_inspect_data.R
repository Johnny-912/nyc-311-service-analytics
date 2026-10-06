# Check the project folder
getwd()

# Show the project files
list.files()

# Create a folder for the original data
dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)

# Specify the fields and requests we want
query <- paste(
  "SELECT unique_key, created_date, closed_date,",
  "agency, complaint_type, status, borough",
  "WHERE agency = 'DSNY'",
  "AND created_date >= '2025-01-01T00:00:00'",
  "AND created_date < '2025-02-01T00:00:00'",
  "ORDER BY created_date, unique_key",
  "LIMIT 1000"
)

# Build the download address
data_url <- paste0(
  "https://data.cityofnewyork.us/resource/erm2-nwe9.csv?$query=",
  URLencode(query, reserved = TRUE)
)

# Download and read the sample
options(timeout = 120)

download.file(
  data_url,
  destfile = "data/raw/dsny_jan2025_sample.csv",
  method = "libcurl"
)

requests <- read.csv(
  "data/raw/dsny_jan2025_sample.csv",
  colClasses = "character",
  na.strings = ""
)

# Inspect the sample
dim(requests)
head(requests)


# Count requests by problem type
sort(table(requests$complaint_type), decreasing = TRUE)

# Count missing values in each column
colSums(is.na(requests))

# Count repeated request IDs
sum(duplicated(requests$unique_key))
