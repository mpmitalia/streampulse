-- ============================================================
-- activation_funnel.sql
--
-- NOTE ON ADAPTATION: the original project brief called for a
-- "browse -> play -> complete" funnel, but our schema doesn't
-- generate a separate "browse-only" event (every session already
-- has plays attached). This funnel instead measures early-life
-- ACTIVATION: signup -> first session -> came back within week 1
-- -> still active at day 30. This is arguably more useful for a
-- Business Insights team anyway, since it's the funnel that
-- explains WHERE early drop-off actually happens.
-- ============================================================

WITH signups AS (
    SELECT user_id, signup_date::DATE AS signup_date
    FROM users
    WHERE signup_date::DATE <= (SELECT MAX(session_date::DATE) FROM sessions) - INTERVAL '30 day'
),
first_session AS (
    SELECT
        s.user_id,
        MIN(s.session_date::DATE) AS first_session_date
    FROM sessions s
    GROUP BY s.user_id
),
week1_return AS (
    SELECT DISTINCT s.user_id
    FROM sessions s
    JOIN signups su ON su.user_id = s.user_id
    WHERE s.session_date::DATE BETWEEN su.signup_date + INTERVAL '1 day'
                                    AND su.signup_date + INTERVAL '7 day'
),
day30_active AS (
    SELECT DISTINCT s.user_id
    FROM sessions s
    JOIN signups su ON su.user_id = s.user_id
    WHERE s.session_date::DATE = su.signup_date + INTERVAL '30 day'
)
SELECT
    COUNT(DISTINCT su.user_id) AS stage_1_signed_up,
    COUNT(DISTINCT fs.user_id) AS stage_2_had_first_session,
    COUNT(DISTINCT w1.user_id) AS stage_3_returned_week1,
    COUNT(DISTINCT d30.user_id) AS stage_4_active_day30,

    ROUND(COUNT(DISTINCT fs.user_id) * 100.0 / COUNT(DISTINCT su.user_id), 1) AS pct_had_first_session,
    ROUND(COUNT(DISTINCT w1.user_id) * 100.0 / COUNT(DISTINCT fs.user_id), 1) AS pct_first_session_to_week1_return,
    ROUND(COUNT(DISTINCT d30.user_id) * 100.0 / COUNT(DISTINCT w1.user_id), 1) AS pct_week1_return_to_day30
FROM signups su
LEFT JOIN first_session fs ON fs.user_id = su.user_id
LEFT JOIN week1_return   w1 ON w1.user_id = su.user_id
LEFT JOIN day30_active   d30 ON d30.user_id = su.user_id;
