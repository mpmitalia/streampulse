-- ============================================================
-- genre_stickiness.sql
--
-- Ranks genres (including Podcast) by "repeat-listen rate": the
-- share of listeners who played that genre more than once, as a
-- proxy for how "sticky"/habit-forming the content type is.
--
-- Demonstrates RANK() (ties share a rank, gaps follow) vs
-- ROW_NUMBER() (always unique, no gaps) on the same data --
-- an easy thing to get asked to explain the difference on.
-- ============================================================

WITH user_genre_plays AS (
    SELECT
        p.user_id,
        t.genre,
        COUNT(*) AS play_count
    FROM plays p
    JOIN tracks t ON t.track_id = p.track_id
    GROUP BY p.user_id, t.genre
),
genre_stats AS (
    SELECT
        genre,
        COUNT(DISTINCT user_id) AS total_listeners,
        COUNT(DISTINCT CASE WHEN play_count > 1 THEN user_id END) AS repeat_listeners,
        ROUND(
            COUNT(DISTINCT CASE WHEN play_count > 1 THEN user_id END) * 100.0
            / COUNT(DISTINCT user_id), 1
        ) AS repeat_listen_rate_pct
    FROM user_genre_plays
    GROUP BY genre
)
SELECT
    genre,
    total_listeners,
    repeat_listeners,
    repeat_listen_rate_pct,
    RANK()       OVER (ORDER BY repeat_listen_rate_pct DESC) AS rank_with_ties,
    ROW_NUMBER() OVER (ORDER BY repeat_listen_rate_pct DESC) AS row_number_no_ties
FROM genre_stats
ORDER BY repeat_listen_rate_pct DESC;
