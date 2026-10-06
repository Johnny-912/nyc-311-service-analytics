
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

