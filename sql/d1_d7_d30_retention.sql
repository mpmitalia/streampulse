-- ============================================================
-- d1_d7_d30_retention.sql
--
-- Classic D1/D7/D30 retention: for each user, was there a session
-- on EXACTLY day 1 / day 7 / day 30 after signup (not "sometime in
-- that week"). This is the industry-standard definition and reads
-- lower than weekly-cohort retention (cohort_retention.sql) by design
-- -- both are correct, they answer different questions.
-- ============================================================

WITH user_days_active AS (
    SELECT DISTINCT
        s.user_id,
        s.session_date::DATE AS active_date
    FROM sessions s
),
signup_dates AS (
    SELECT user_id, signup_date::DATE AS signup_date
    FROM users
)
SELECT
    COUNT(DISTINCT sd.user_id) AS total_users,

    COUNT(DISTINCT CASE
        WHEN uda.active_date = sd.signup_date + INTERVAL '1 day' THEN sd.user_id
    END) AS d1_retained,
    ROUND(COUNT(DISTINCT CASE
        WHEN uda.active_date = sd.signup_date + INTERVAL '1 day' THEN sd.user_id
    END) * 100.0 / COUNT(DISTINCT sd.user_id), 1) AS d1_retention_pct,

    COUNT(DISTINCT CASE
        WHEN uda.active_date = sd.signup_date + INTERVAL '7 day' THEN sd.user_id
    END) AS d7_retained,
    ROUND(COUNT(DISTINCT CASE
        WHEN uda.active_date = sd.signup_date + INTERVAL '7 day' THEN sd.user_id
    END) * 100.0 / COUNT(DISTINCT sd.user_id), 1) AS d7_retention_pct,

    COUNT(DISTINCT CASE
        WHEN uda.active_date = sd.signup_date + INTERVAL '30 day' THEN sd.user_id
    END) AS d30_retained,
    ROUND(COUNT(DISTINCT CASE
        WHEN uda.active_date = sd.signup_date + INTERVAL '30 day' THEN sd.user_id
    END) * 100.0 / COUNT(DISTINCT sd.user_id), 1) AS d30_retention_pct

FROM signup_dates sd
LEFT JOIN user_days_active uda ON uda.user_id = sd.user_id
-- only include users who've had the chance to reach day 30
WHERE sd.signup_date <= (SELECT MAX(session_date::DATE) FROM sessions) - INTERVAL '30 day';


-- Segmented version: same logic, broken out by podcast_adopter,
-- to reproduce the "podcast listeners retain better" headline finding.
WITH user_days_active AS (
    SELECT DISTINCT s.user_id, s.session_date::DATE AS active_date
    FROM sessions s
),
signup_dates AS (
    SELECT user_id, signup_date::DATE AS signup_date, podcast_adopter
    FROM users
)
SELECT
    sd.podcast_adopter,
    COUNT(DISTINCT sd.user_id) AS total_users,
    ROUND(COUNT(DISTINCT CASE
        WHEN uda.active_date = sd.signup_date + INTERVAL '30 day' THEN sd.user_id
    END) * 100.0 / COUNT(DISTINCT sd.user_id), 1) AS d30_retention_pct
FROM signup_dates sd
LEFT JOIN user_days_active uda ON uda.user_id = sd.user_id
WHERE sd.signup_date <= (SELECT MAX(session_date::DATE) FROM sessions) - INTERVAL '30 day'
GROUP BY sd.podcast_adopter;


total_users	d1_retained	d1_retention_pct	d7_retained	d7_retention_pct	d30_retained	d30_retention_pct
54689	    41909	    76.6	            28647	    52.4	            14590	        26.7

podcast_adopter	total_users	d30_retention_pct
false	        40872	    23.9
true	        13817	    34.9
