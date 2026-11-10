-- =====================================================================
-- STEP 5: ADVANCED SQL SHOWCASE  (9 queries)                    (MySQL 8.0)
-- Builds on 04_analysis_queries.sql. Reads ONLY from the view `lead_master`
-- created in 03_data_quality_and_cleaning.sql (one row per lead), so run 01 -> 03 first.
--
-- SKILLS SHOWN:  CTE | window functions (SUM OVER, RANK, LAG, moving AVG,
--                ROW_NUMBER, running total) | percentiles | recursive CTE |
--                conditional aggregation | CASE segmentation | cohort analysis
--
-- HOW TO USE: run ONE query at a time (click inside it, press Ctrl+Enter).
-- Why these queries differ from 04: 04 answers "what is the number?".
-- This file answers "is the number fair, and what should we DO about it?".
-- Terms: converted_flag = 1 means the lead became a closed deal;
--        cohort_period  = 'Jan-May 2018' is the fair, comparable period
--        (deal recording starts in Dec 2017, so Jun-Dec 2017 looks artificially weak).
-- =====================================================================
USE olist_funnel;

-- ---------------------------------------------------------------------
-- A1 | Volume vs value by channel                (CTE + SUM() OVER ())
-- RESULT FILE: 05_A1_channel_volume_vs_value
-- Business question: Which channels bring MANY leads but FEW sign-ups?
-- Read: gap_in_share_pts < 0 means the channel has a bigger share of leads
--       than of deals = "volume without value".
-- ---------------------------------------------------------------------
WITH channel AS (
    SELECT origin,
           COUNT(*)            AS leads,
           SUM(converted_flag) AS deals
    FROM lead_master
    GROUP BY origin
)
SELECT origin,
       leads,
       deals,
       ROUND(100 * deals / leads, 1)                             AS conversion_rate_pct,
       ROUND(100 * leads / SUM(leads) OVER (), 1)                AS share_of_leads_pct,
       ROUND(100 * deals / SUM(deals) OVER (), 1)                AS share_of_deals_pct,
       ROUND(100 * deals / SUM(deals) OVER ()
           - 100 * leads / SUM(leads) OVER (), 1)                AS gap_in_share_pts
FROM channel
ORDER BY gap_in_share_pts;

-- ---------------------------------------------------------------------
-- A2 | Is the channel ranking stable?            (RANK + HAVING + conditional aggregation)
-- RESULT FILE: 05_A2_channel_rank_stability
-- Business question: Does the channel ranking change if we use only the
--                    fair period (Jan-May 2018)?
-- Read: if rank_all_months = rank_jan_may, the ranking is robust.
--       Channels under 100 leads are left out (too small to rank).
-- ---------------------------------------------------------------------
WITH channel AS (
    SELECT origin,
           COUNT(*)                                                           AS leads,
           100.0 * SUM(converted_flag) / COUNT(*)                             AS conv_all_months,
           100.0 * SUM(CASE WHEN cohort_period = 'Jan-May 2018' THEN converted_flag END)
                 / SUM(CASE WHEN cohort_period = 'Jan-May 2018' THEN 1 END)   AS conv_jan_may
    FROM lead_master
    GROUP BY origin
    HAVING COUNT(*) >= 100
)
SELECT origin,
       leads,
       ROUND(conv_all_months, 1)                       AS conv_all_months_pct,
       ROUND(conv_jan_may, 1)                          AS conv_jan_may_pct,
       RANK() OVER (ORDER BY conv_all_months DESC)     AS rank_all_months,
       RANK() OVER (ORDER BY conv_jan_may DESC)        AS rank_jan_may
FROM channel
ORDER BY rank_jan_may;

-- ---------------------------------------------------------------------
-- A3 | Channel action matrix                      (CASE segmentation)
-- RESULT FILE: 05_A3_channel_action_matrix
-- Business question: Which channels should get MORE budget, a QUALITY REVIEW,
--                    or a TRACKING FIX?
-- Rule: big channel = at least 5% of all leads; good = converts above the
--       overall Jan-May 2018 rate (13.0%).
-- ---------------------------------------------------------------------
WITH base AS (
    SELECT origin,
           COUNT(*)                                  AS leads,
           100.0 * SUM(converted_flag) / COUNT(*)    AS conv_pct
    FROM lead_master
    WHERE cohort_period = 'Jan-May 2018'
    GROUP BY origin
),
overall AS (
    SELECT 100.0 * SUM(converted_flag) / COUNT(*) AS overall_pct
    FROM lead_master
    WHERE cohort_period = 'Jan-May 2018'
)
SELECT b.origin,
       b.leads,
       ROUND(b.conv_pct, 1)  AS conv_pct,
       ROUND(o.overall_pct, 1) AS overall_pct,
       CASE WHEN b.origin IN ('unknown', 'not_provided') THEN 'FIX TRACKING (converts well, source hidden)'
            WHEN b.leads >= 0.05 * (SELECT SUM(leads) FROM base) AND b.conv_pct >= o.overall_pct THEN 'SCALE (big and converts)'
            WHEN b.leads >= 0.05 * (SELECT SUM(leads) FROM base) AND b.conv_pct <  o.overall_pct THEN 'REVIEW QUALITY (big but weak)'
            ELSE 'WATCH (small channel)' END AS suggested_action
FROM base b CROSS JOIN overall o
ORDER BY b.leads DESC;

-- ---------------------------------------------------------------------
-- A4 | Median, P25, P75, P90 days to close, ALL vs FAIR period
-- RESULT FILE: 05_A4_days_to_close_percentiles_by_period
--      (ROW_NUMBER + COUNT() OVER with PARTITION BY)
-- Business question: Is the "slow tail" real, or caused by the recording start?
-- Read: Jun-Dec 2017 leads can only appear if they closed AFTER recording began
--       in Dec 2017, so their deals look very slow. Use Jan-May 2018 for the fair view.
-- MySQL has no MEDIAN/PERCENTILE function, so we rank the rows ourselves
-- (nearest-rank method; values can differ slightly from Excel or pandas).
-- ---------------------------------------------------------------------
WITH ranked AS (
    SELECT cohort_period,
           days_to_close,
           ROW_NUMBER() OVER (PARTITION BY cohort_period ORDER BY days_to_close) AS rn,
           COUNT(*)     OVER (PARTITION BY cohort_period)                        AS n
    FROM lead_master
    WHERE days_to_close IS NOT NULL
    UNION ALL
    SELECT 'All months', days_to_close,
           ROW_NUMBER() OVER (ORDER BY days_to_close),
           COUNT(*)     OVER ()
    FROM lead_master
    WHERE days_to_close IS NOT NULL
)
SELECT cohort_period,
       MAX(n)                                                              AS deals,
       ROUND(AVG(days_to_close), 1)                                        AS average_days,
       ROUND(AVG(CASE WHEN rn IN (FLOOR((n + 1) / 2), CEIL((n + 1) / 2)) THEN days_to_close END), 1) AS median_days,
       MIN(CASE WHEN rn >= CEIL(0.25 * n) THEN days_to_close END)          AS p25_days,
       MIN(CASE WHEN rn >= CEIL(0.75 * n) THEN days_to_close END)          AS p75_days,
       MIN(CASE WHEN rn >= CEIL(0.90 * n) THEN days_to_close END)          AS p90_days,
       ROUND(100.0 * SUM(days_to_close > 90) / COUNT(*), 1)                AS pct_over_90_days
FROM ranked
GROUP BY cohort_period
ORDER BY cohort_period;

-- ---------------------------------------------------------------------
-- A5 | Cohort close curve                          (cohort analysis, conditional aggregation)
-- RESULT FILE: 05_A5_cohort_close_curve
-- Business question: Of the leads that arrived each month, how many had closed
--                    after 7, 14, 30, 60 and 90 days?
-- Read: months are compared on the SAME time window, so the comparison is fair.
--       (Only Jan-May 2018, the period with complete deal recording.)
-- ---------------------------------------------------------------------
SELECT first_contact_month,
       COUNT(*)                                                              AS leads,
       ROUND(100.0 * SUM(days_to_close <=  7) / COUNT(*), 1)                 AS closed_by_day_7_pct,
       ROUND(100.0 * SUM(days_to_close <= 14) / COUNT(*), 1)                 AS closed_by_day_14_pct,
       ROUND(100.0 * SUM(days_to_close <= 30) / COUNT(*), 1)                 AS closed_by_day_30_pct,
       ROUND(100.0 * SUM(days_to_close <= 60) / COUNT(*), 1)                 AS closed_by_day_60_pct,
       ROUND(100.0 * SUM(days_to_close <= 90) / COUNT(*), 1)                 AS closed_by_day_90_pct
FROM lead_master
WHERE cohort_period = 'Jan-May 2018'
GROUP BY first_contact_month
ORDER BY first_contact_month;

-- ---------------------------------------------------------------------
-- A6 | Month-on-month change and 3-month moving average   (LAG + moving AVG)
-- RESULT FILE: 05_A6_monthly_lag_moving_avg
-- Business question: Is conversion improving, and how much is noise?
-- WARNING: months before 2018 look low only because deal recording started
--          in Dec 2017. Read the Jan-May 2018 rows.
-- ---------------------------------------------------------------------
WITH monthly AS (
    SELECT first_contact_month                              AS contact_month,
           COUNT(*)                                          AS leads,
           SUM(converted_flag)                               AS deals,
           100.0 * SUM(converted_flag) / COUNT(*)            AS conv_pct
    FROM lead_master
    GROUP BY first_contact_month
)
SELECT contact_month,
       leads,
       deals,
       ROUND(conv_pct, 1)                                                          AS conv_pct,
       ROUND(conv_pct - LAG(conv_pct) OVER (ORDER BY contact_month), 1)            AS change_vs_prev_month_pts,
       ROUND(AVG(conv_pct) OVER (ORDER BY contact_month
                                 ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 1)     AS moving_avg_3m_pct
FROM monthly
ORDER BY contact_month;

-- ---------------------------------------------------------------------
-- A7 | Deals won per calendar month with a running total   (RECURSIVE CTE + SUM OVER)
-- RESULT FILE: 05_A7_deals_won_running_total
-- Business question: When were deals actually recorded?
-- A recursive CTE builds a month calendar (a "date spine") so months with
-- ZERO wins still appear. It shows no deals before Dec 2017: the recording start.
-- ---------------------------------------------------------------------
WITH RECURSIVE calendar AS (
    SELECT DATE('2017-06-01') AS month_start
    UNION ALL
    SELECT DATE_ADD(month_start, INTERVAL 1 MONTH)
    FROM calendar
    WHERE month_start < DATE('2018-11-01')
),
won AS (
    SELECT DATE_FORMAT(won_day, '%Y-%m') AS won_month, COUNT(*) AS deals_won
    FROM lead_master
    WHERE converted_flag = 1
    GROUP BY DATE_FORMAT(won_day, '%Y-%m')
)
SELECT DATE_FORMAT(c.month_start, '%Y-%m')                                AS month,
       COALESCE(w.deals_won, 0)                                           AS deals_won,
       SUM(COALESCE(w.deals_won, 0)) OVER (ORDER BY c.month_start)        AS running_total_deals,
       ROUND(100.0 * SUM(COALESCE(w.deals_won, 0)) OVER (ORDER BY c.month_start)
             / SUM(COALESCE(w.deals_won, 0)) OVER (), 1)                  AS running_total_pct
FROM calendar c
LEFT JOIN won w ON w.won_month = DATE_FORMAT(c.month_start, '%Y-%m')
ORDER BY c.month_start;

-- ---------------------------------------------------------------------
-- A8 | Pareto of product categories                (running total with window function)
-- RESULT FILE: 05_A8_segment_pareto
-- Business question: How many categories make up most of the new sellers?
-- (Closed deals only: shares of won deals, not conversion rates.)
-- ---------------------------------------------------------------------
WITH seg AS (
    SELECT business_segment, COUNT(*) AS deals
    FROM lead_master
    WHERE converted_flag = 1
    GROUP BY business_segment
)
SELECT RANK() OVER (ORDER BY deals DESC)                                       AS segment_rank,
       business_segment,
       deals,
       ROUND(100.0 * deals / SUM(deals) OVER (), 1)                            AS pct_of_deals,
       ROUND(100.0 * SUM(deals) OVER (ORDER BY deals DESC, business_segment)
             / SUM(deals) OVER (), 1)                                          AS cumulative_pct
FROM seg
ORDER BY deals DESC, business_segment
LIMIT 12;

-- ---------------------------------------------------------------------
-- A9 | Median days to close by behaviour profile   (ROW_NUMBER with PARTITION BY)
-- RESULT FILE: 05_A9_behaviour_profile_median_days
-- Business question: Do some behaviour profiles need an earlier follow-up?
-- Read: wolf deals take about 3x longer than cat or eagle deals.
--       Single profiles only; combined profiles such as "cat, wolf" are tiny groups.
-- ---------------------------------------------------------------------
WITH ranked AS (
    SELECT behaviour_profile,
           days_to_close,
           ROW_NUMBER() OVER (PARTITION BY behaviour_profile ORDER BY days_to_close) AS rn,
           COUNT(*)     OVER (PARTITION BY behaviour_profile)                        AS n
    FROM lead_master
    WHERE converted_flag = 1 AND days_to_close IS NOT NULL
      AND behaviour_profile IN ('cat', 'eagle', 'wolf', 'shark', 'Not Provided')
)
SELECT behaviour_profile,
       MAX(n)                                                                              AS deals,
       ROUND(AVG(CASE WHEN rn IN (FLOOR((n + 1) / 2), CEIL((n + 1) / 2)) THEN days_to_close END), 1) AS median_days,
       ROUND(AVG(days_to_close), 1)                                                        AS average_days
FROM ranked
GROUP BY behaviour_profile
ORDER BY median_days DESC;
