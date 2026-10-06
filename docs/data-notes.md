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