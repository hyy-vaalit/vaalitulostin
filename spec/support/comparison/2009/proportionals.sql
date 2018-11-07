-- Query good coalition and alliance proportionals for comparison tests.
SELECT
  candidates.candidate_number,
  coalition_proportionals.number as coalition_proportional,
  alliance_proportionals.number as alliance_proportional
FROM candidates
  INNER JOIN coalition_proportionals ON candidates.id = coalition_proportionals.candidate_id
  INNER JOIN alliance_proportionals ON candidates.id = alliance_proportionals.candidate_id
  INNER JOIN results ON coalition_proportionals.result_id = results.id AND alliance_proportionals.result_id = results.id

WHERE results.id = 1 -- NOTE THIS

ORDER BY 1,2,3 DESC;
