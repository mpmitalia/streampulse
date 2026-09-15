-- ============================================================
-- rolling_active_users.sql
--
-- Daily active users (DAU) alongside a rolling 7-day average,
-- using a window frame -- the standard way to smooth out daily
-- noise (weekday/weekend swings) when reporting trend to execs.
-- ============================================================

WITH daily_actives AS (
    SELECT
        session_date::DATE AS activity_date,
        COUNT(DISTINCT user_id) AS dau
    FROM sessions
    GROUP BY session_date::DATE
)
SELECT
    activity_date,
    dau,
    ROUND(AVG(dau) OVER (
        ORDER BY activity_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 0) AS rolling_7day_avg_dau
FROM daily_actives
ORDER BY activity_date;
