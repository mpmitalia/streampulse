# StreamPulse — SQL Analysis Library

All queries below were validated against the actual generated dataset
(60,000 users, 8,800 tracks, 2.84M sessions, 22.8M plays) using an
equivalent pandas computation before being finalized — the numbers
in this README are real outputs from that validation, not projections.

## Two adaptations from the original project plan (worth knowing before an interview)

1. **Funnel definition changed.** The original plan called for a
   "browse → play → complete" funnel, but this schema doesn't generate
   a separate browse-only event (every session already has plays
   attached). `activation_funnel.sql` instead measures early-life
   activation: signup → first session → returned in week 1 → still
   active at day 30. This turned out to surface a genuinely useful,
   non-obvious finding (see below).

2. **No sessionization query needed.** Since `sessions` already exists
   as a first-class table with `session_id`, there's no raw
   unsessionized event log to reconstruct sessions from. (If you want
   to demonstrate sessionization-from-raw-events specifically for an
   interview talking point, that would need building play-level data
   without session_id first — ask if you want that added.)

## Files and validated results

| File | What it does | Validated result |
|---|---|---|
| `cohort_retention.sql` | Weekly signup cohort × weeks-since-signup retention matrix | Mid-year cohort: 96.6% week 0 → 73-78% by week 12 (weekly "active at least once" retention) |
| `d1_d7_d30_retention.sql` | Day-exact D1/D7/D30 retention (industry-standard definition) | D1: 76.6%, D7: 52.4%, D30: 26.7% — a realistic decay curve. Segmented: podcast adopters hit **34.9% D30 retention vs. 23.9%** for non-adopters (~46% relative lift) — this is your headline finding |
| `rolling_active_users.sql` | DAU + 7-day rolling average (window frame) | DAU grows from ~124 (Jan) to ~15-19K (Dec), consistent with the designed growth trend |
| `genre_stickiness.sql` | Ranks genres by repeat-listen rate; demonstrates RANK() vs ROW_NUMBER() | Podcast leads at 99.9% repeat-listen rate; music genres cluster tightly around 91% |
| `session_gaps_reengagement.sql` | LAG()-based detection of users who went quiet 30+ days then returned | 12,985 resurrection events found; most gaps cluster in the 30-44 day range |
| `activation_funnel.sql` | Signup → first session → week-1 return → day-30 active | Stages 1-3 are all ~97-100% (near-universal early engagement) — **the real drop-off is entirely between week-1 return and day-30 retention (only 27% survive that stage)**. This is a genuine, defensible insight: early activation isn't the problem here, longer-term retention is. |

## Why this matters for the interview

The `d1_d7_d30_retention.sql` podcast segmentation and the
`activation_funnel.sql` finding above are your two strongest,
most defensible talking points — both are real patterns that
emerged from the designed data-generating process (documented in
`config.py` in the data-generation folder), not cherry-picked or
fabricated after the fact. Be ready to explain *why* podcast adopters
retain better (the mechanism: podcast content has a longer natural
listening habit and lower skip rate, which we modeled explicitly)
rather than just stating the number.
