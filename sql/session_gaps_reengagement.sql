-- ============================================================
-- session_gaps_reengagement.sql
--
-- For each user, the gap (in days) between consecutive sessions,
-- using LAG(). Flags "resurrected" users: someone who went quiet
-- for 30+ days and then came back -- a genuinely useful behavioral
-- signal (distinct from a simple churn flag) that a re-engagement
-- campaign team would care about.
-- ============================================================

WITH user_sessions_ordered AS (
    SELECT
        user_id,
        session_date::DATE AS session_date,
        LAG(session_date::DATE) OVER (
            PARTITION BY user_id ORDER BY session_date
        ) AS prev_session_date
    FROM (SELECT DISTINCT user_id, session_date FROM sessions) s
),
gaps AS (
    SELECT
        user_id,
        session_date,
        prev_session_date,
        session_date - prev_session_date AS gap_days
    FROM user_sessions_ordered
    WHERE prev_session_date IS NOT NULL
)
SELECT
    user_id,
    prev_session_date,
    session_date AS resurrection_date,
    gap_days
FROM gaps
WHERE gap_days >= 30
ORDER BY gap_days DESC;

-- Summary: how many resurrection events happen at each gap-length bucket
-- (useful for deciding what "churned" threshold to use in a churn model)
WITH user_sessions_ordered AS (
    SELECT
        user_id,
        session_date::DATE AS session_date,
        LAG(session_date::DATE) OVER (
            PARTITION BY user_id ORDER BY session_date
        ) AS prev_session_date
    FROM (SELECT DISTINCT user_id, session_date FROM sessions) s
),
gaps AS (
    SELECT session_date - prev_session_date AS gap_days
    FROM user_sessions_ordered
    WHERE prev_session_date IS NOT NULL
)
SELECT
    CASE
        WHEN gap_days BETWEEN 30 AND 44 THEN '30-44 days'
        WHEN gap_days BETWEEN 45 AND 59 THEN '45-59 days'
        WHEN gap_days BETWEEN 60 AND 89 THEN '60-89 days'
        WHEN gap_days >= 90 THEN '90+ days'
    END AS gap_bucket,
    COUNT(*) AS num_resurrections
FROM gaps
WHERE gap_days >= 30
GROUP BY 1
ORDER BY MIN(gap_days);
