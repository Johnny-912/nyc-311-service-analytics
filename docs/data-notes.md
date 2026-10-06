# Data Notes

Source: NYC 311 Service Requests from 2020 to Present
https://data.cityofnewyork.us/d/erm2-nwe9

Planned scope: Requests created in 2025 and assigned to DSNY.

## Columns

- Unique Key: Identifier for each service request.
- Created Date: When the request was created.
- Closed Date: When the agency closed the request; may be blank.
- Agency: City agency responsible for the request.
- Problem: Type of issue reported.
- Status: Current status of the request.
- Borough: NYC borough associated with the request.

## Planned measure

Time to closure = Closed Date minus Created Date.

Calculate this only when both dates are present and valid.
Closure does not necessarily mean the underlying problem was solved.

## Initial sample findings

- 1,000 requests; no duplicate IDs.
- Seven records have missing closure dates.
- No negative closure durations were found.
- Graffiti has a median closure time of approximately 35 days.
- Categories with very few records need cautious interpretation.
- This sample contains the earliest 1,000 matching requests,
  so these findings do not represent all January or 2025 requests.
  
## Full January 2025 analysis

- Downloaded 26,370 DSNY requests.
- No duplicate IDs, date conversion failures, or negative durations.
- 117 requests lack a closure date.
- 18 requests have an unspecified borough.
- Median recorded time to closure: 32.21 hours.
- Brooklyn had the most requests: 9,268.
- Brooklyn had the highest overall borough median: 50.98 hours.
- For Dirty Condition requests, Queens had the highest median:
  23.08 hours.
- SQL and R produced matching Dirty Condition borough medians.

## Interpretation limits

Borough comparisons can change with the mix of request types.
Closure times describe records with a recorded closure date.
These results do not establish what caused the differences.