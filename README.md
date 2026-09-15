# StreamPulse — Music Streaming Retention & Cohort Analytics

A product analytics project simulating a music-streaming platform's Business Insights function: diagnosing retention, engagement, and content performance for a 60,000-user, 12-month synthetic dataset, from raw data generation through SQL analysis to a live Apache Superset dashboard.

Built as portfolio evidence for Data Analyst / Business Insights roles requiring advanced SQL, product analytics, and BI dashboarding (Superset specifically).

## Business Problem

*"Weekly active users are flat despite catalog growth. Which content types and user segments drive retention, and where are we losing users?"*

## Headline Findings

1. **Podcast adopters retain nearly 50% better than non-adopters** — 34.9% D30 retention vs. 23.9% for users who never engage with podcast content, a mechanism explicitly modeled into the data-generation process (longer natural listening habit, lower skip rate) and confirmed at both weekly-cohort and day-exact retention resolutions.
2. **Early activation is not the problem — day-30 retention is.** ~97-100% of signups have a first session and return at least once in week 1. The real drop-off happens entirely between week-1 return and day-30 retention, where only ~27% of returning users are still active.

## Tech Stack

- **Data generation:** Python (pandas, NumPy) — a designed generative process (retention decay curves, channel/content effects, deliberately injected data-quality issues), not random data
- **Database:** PostgreSQL
- **Analysis:** Advanced SQL (window functions, CTEs, cohort/retention/funnel patterns), Python/pandas exploratory analysis
- **Dashboarding:** Apache Superset
- **Automation:** Python scripts for chunked data generation and loading

## Repository Structure

```
StreamPulse/
├── data/              # Data-generation scripts + (gitignored) generated CSVs
├── notebook/          # Jupyter notebooks: data generation, exploratory analysis
├── sql/               # Standalone .sql analysis library (cohort, retention, funnel, etc.)
├── reports/           # Chart PNGs and summary CSVs from the exploratory pass
├── superset/           # Exported Superset dashboard JSON + screenshots
├── Dashboard/         # Dashboard screenshots / final visual deliverables
└── README.md
```

## Dataset

Synthetic but structurally realistic: 60,000 users, 8,800 tracks, ~2.85M sessions, ~22.8M plays over 12 months (Jan–Dec 2025). Generated via a designed process documented in `data/config.py` — retention decay curves, acquisition-channel effects, podcast-adoption boosts, and weekday/weekend texture — with deliberately injected, realistic data-quality issues (duplicate plays, missing device types, a simulated logging-outage week, a timezone bug affecting tier-3 city users) to mirror real production data.

## SQL Analysis Library (`/sql`)

| File | What it does |
|---|---|
| `cohort_retention.sql` | Weekly signup cohort × weeks-since-signup retention matrix |
| `d1_d7_d30_retention.sql` | Day-exact D1/D7/D30 retention, overall and segmented by podcast adoption |
| `rolling_active_users.sql` | DAU with a 7-day rolling average (window frame) |
| `genre_stickiness.sql` | Genre/content repeat-listen ranking (RANK vs. ROW_NUMBER) |
| `session_gaps_reengagement.sql` | LAG()-based detection of users who churned 30+ days then returned |
| `activation_funnel.sql` | Signup → first session → week-1 return → day-30 active |

Full documentation of adaptations and validated results in `sql/README.md`.

## Dashboard

Built in Apache Superset, connected directly to the PostgreSQL warehouse. Pages/charts include:
- Weekly cohort retention heatmap
- D30 retention: podcast adopters vs. non-adopters
- DAU trend with 7-day rolling average
- Content stickiness by genre
- Activation funnel
- Re-engagement gap distribution

See `/superset` for the exported dashboard JSON and `/Dashboard` for screenshots.

## Reproducing This Project

1. Set up PostgreSQL and create a `streampulse` database
2. Run `notebook/01_data_generation.ipynb` to generate and load the dataset (~60K users; the sessions/plays step is the slow part — expect 15-45+ minutes depending on hardware)
3. Run the queries in `/sql` against the loaded database
4. Run `notebook/02_exploratory_analysis.ipynb` for charts and summary tables
5. Connect Apache Superset to the same database and import the dashboard from `/superset` (or rebuild charts using the queries in `/sql`)

## Notes on Adaptations

The original project brief called for a "browse → play → complete" funnel; this schema doesn't generate a separate browse-only event (every session already has plays attached), so `activation_funnel.sql` instead measures early-life activation, which surfaced the day-30 retention finding above. Full reasoning in `sql/README.md`.
