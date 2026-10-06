
SELECT
  borough,
  COUNT(*) AS total_requests,
  COUNT(closure_hours) AS with_closure_time,
  COUNT(*) - COUNT(closure_hours) AS missing_closure_time,
  ROUND(MEDIAN(closure_hours), 2) AS median_hours
FROM requests
GROUP BY borough
ORDER BY total_requests DESC

