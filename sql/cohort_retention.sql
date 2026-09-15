-- ============================================================
-- cohort_retention.sql
--
-- Weekly signup cohorts x weeks-since-signup retention matrix.
-- For each cohort (week a user signed up), what % of that cohort
-- was still active in week 0, 1, 2, 3... after signup.
--
-- This is THE core Business Insights SQL pattern -- almost every
-- product analytics team runs a version of this weekly.
-- ============================================================

WITH cohorts AS (
    SELECT
        user_id,
        DATE_TRUNC('week', signup_date) AS cohort_week
    FROM users
),
cohort_sizes AS (
    SELECT cohort_week, COUNT(*) AS cohort_size
    FROM cohorts
    GROUP BY cohort_week
),
user_activity_weeks AS (
    -- every distinct (user, week) they were active in
    SELECT DISTINCT
        s.user_id,
        DATE_TRUNC('week', s.session_date) AS activity_week
    FROM sessions s
),
cohort_activity AS (
    SELECT
        c.user_id,
        c.cohort_week,
        a.activity_week,
        -- weeks_since_signup: 0 = signup week itself, 1 = next week, etc.
        FLOOR(EXTRACT(EPOCH FROM (a.activity_week - c.cohort_week)) / (7 * 86400))::INT AS weeks_since_signup
    FROM cohorts c
    JOIN user_activity_weeks a ON a.user_id = c.user_id
    WHERE a.activity_week >= c.cohort_week
)
SELECT
    ca.cohort_week,
    ca.weeks_since_signup,
    COUNT(DISTINCT ca.user_id) AS active_users,
    cs.cohort_size,
    ROUND(COUNT(DISTINCT ca.user_id) * 100.0 / cs.cohort_size, 1) AS retention_pct
FROM cohort_activity ca
JOIN cohort_sizes cs ON cs.cohort_week = ca.cohort_week
WHERE ca.weeks_since_signup BETWEEN 0 AND 12  -- first 12 weeks of life
GROUP BY ca.cohort_week, ca.weeks_since_signup, cs.cohort_size
ORDER BY ca.cohort_week, ca.weeks_since_signup;
