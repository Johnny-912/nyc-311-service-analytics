getwd()

list.files()

dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)

query <- paste(
  "SELECT unique_key, created_date, closed_date,",
  "agency, complaint_type, status, borough",
  "WHERE agency = 'DSNY'",
  "AND created_date >= '2025-01-01T00:00:00'",
  "AND created_date < '2025-02-01T00:00:00'",
  "ORDER BY created_date, unique_key",
  "LIMIT 1000"
)

data_url <- paste0(
  "https://data.cityofnewyork.us/resource/erm2-nwe9.csv?$query=",
  URLencode(query, reserved = TRUE)
)

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

dim(requests)
head(requests)

sort(table(requests$complaint_type), decreasing = TRUE)

colSums(is.na(requests))

sum(duplicated(requests$unique_key))
