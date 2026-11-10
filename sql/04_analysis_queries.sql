-- =====================================================================
-- STEP 4: BUSINESS ANALYSIS QUERIES  (12 queries)                (MySQL 8.0)
-- HOW TO USE:
--   * Run ONE query at a time (click inside it, press Ctrl+Enter).
--   * The result of each query is saved in data/query_results/ under the
--     file name shown in the "RESULT FILE" line above the query.
--   * Terms: a LEAD (MQL) is a business that showed interest; a CLOSED DEAL
--     means that lead signed up as a seller; CONVERSION RATE = closed / leads.
--   * Lead type, segment, behaviour profile and sales reps exist ONLY for
--     closed deals, so those views show counts and shares, NOT conversion rates.
--   * Jun-Dec 2017 leads are not comparable with Jan-May 2018 (the first
--     deal in the data was won in Dec 2017). Use Jan-May 2018 as the benchmark.
-- =====================================================================
USE olist_funnel;

-- #####################################################################
-- SECTION 1: THE FUNNEL
-- #####################################################################

-- Q01 | RESULT FILE: 01_funnel_kpis
-- Business question: How many interested businesses do we get, and how many sign up?
SELECT COUNT(*)                                       AS total_mqls,
       SUM(converted_flag)                            AS closed_deals,
       COUNT(*) - SUM(converted_flag)                 AS not_converted,
       ROUND(100.0 * SUM(converted_flag) / COUNT(*), 2) AS conversion_rate_pct
FROM lead_master;

-- Q02 | RESULT FILE: 02_comparable_window
-- Business question: Is the 10.5% headline fair, or does it mix periods that cannot be compared?
SELECT cohort_period,
       COUNT(*)                                       AS mqls,
       SUM(converted_flag)                            AS closed_deals,
       ROUND(100.0 * SUM(converted_flag) / COUNT(*), 2) AS conversion_rate_pct
FROM lead_master
GROUP BY cohort_period
ORDER BY cohort_period DESC;

-- Q03 | RESULT FILE: 03_monthly_cohort
-- Business question: How does conversion change by the month a lead first made contact?
-- (30-day conversion gives older and newer months the same time to close.)
SELECT first_contact_month,
       COUNT(*)                                       AS mqls,
       SUM(converted_flag)                            AS closed_deals,
       ROUND(100.0 * SUM(converted_flag) / COUNT(*), 2) AS conversion_pct_ever,
       SUM(CASE WHEN days_to_close <= 30 THEN 1 ELSE 0 END) AS closed_within_30_days,
       ROUND(100.0 * SUM(CASE WHEN days_to_close <= 30 THEN 1 ELSE 0 END) / COUNT(*), 2) AS conversion_pct_30_days
FROM lead_master
GROUP BY first_contact_month
ORDER BY first_contact_month;

-- #####################################################################
-- SECTION 2: MARKETING CHANNELS (lead origin)
-- #####################################################################

-- Q04 | RESULT FILE: 04_conversion_by_origin
-- Business question: Which marketing channels bring leads that actually sign up?
SELECT origin,
       COUNT(*)                                       AS mqls,
       SUM(converted_flag)                            AS closed_deals,
       ROUND(100.0 * SUM(converted_flag) / COUNT(*), 2) AS conversion_rate_pct,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM lead_master), 1)            AS pct_of_all_mqls,
       ROUND(100.0 * SUM(converted_flag) / (SELECT SUM(converted_flag) FROM lead_master), 1) AS pct_of_all_closed,
       ROUND(100.0 * SUM(CASE WHEN cohort_period = 'Jan-May 2018' THEN converted_flag ELSE 0 END)
             / SUM(CASE WHEN cohort_period = 'Jan-May 2018' THEN 1 ELSE 0 END), 2)  AS conversion_pct_jan_may_2018,
       CASE WHEN COUNT(*) < 100 THEN 'small sample (under 100 leads)' ELSE '' END   AS note
FROM lead_master
GROUP BY origin
ORDER BY mqls DESC;

-- Q05 | RESULT FILE: 05_channel_groups
-- Business question: Do search channels, social/email and untracked leads deserve different treatment?
SELECT CASE WHEN origin IN ('organic_search', 'paid_search') THEN '1 Search (organic + paid)'
            WHEN origin IN ('social', 'email')               THEN '2 Social + email'
            WHEN origin IN ('unknown', 'not_provided')       THEN '4 Unknown or blank origin'
            ELSE '3 Other known channels' END         AS channel_group,
       COUNT(*)                                       AS mqls,
       SUM(converted_flag)                            AS closed_deals,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM lead_master), 1)            AS pct_of_all_mqls,
       ROUND(100.0 * SUM(converted_flag) / (SELECT SUM(converted_flag) FROM lead_master), 1) AS pct_of_all_closed,
       ROUND(100.0 * SUM(converted_flag) / COUNT(*), 2) AS conversion_rate_pct
FROM lead_master
GROUP BY channel_group
ORDER BY channel_group;

-- Q06 | RESULT FILE: 06_landing_pages
-- Business question: Do the biggest landing pages differ in conversion, and is that just channel mix?
SELECT LEFT(landing_page_id, 8)                       AS landing_page,
       COUNT(*)                                       AS mqls,
       SUM(converted_flag)                            AS closed_deals,
       ROUND(100.0 * SUM(converted_flag) / COUNT(*), 1) AS conversion_rate_pct,
       ROUND(100.0 * SUM(CASE WHEN origin = 'social' THEN 1 ELSE 0 END) / COUNT(*), 0) AS pct_from_social
FROM lead_master
GROUP BY landing_page_id
ORDER BY mqls DESC
LIMIT 10;

-- #####################################################################
-- SECTION 3: SPEED TO CLOSE (sales cycle)
-- #####################################################################

-- Q07 | RESULT FILE: 07_time_to_close_summary
-- Business question: How long does a typical deal take, and how long is the slow tail?
-- (MySQL has no MEDIAN function, so the median is the middle value found with ROW_NUMBER.)
WITH ranked AS (
    SELECT days_to_close,
           ROW_NUMBER() OVER (ORDER BY days_to_close) AS rn,
           COUNT(*)     OVER ()                       AS cnt
    FROM lead_master
    WHERE days_to_close IS NOT NULL
),
median_value AS (
    SELECT AVG(days_to_close) AS median_days
    FROM ranked
    WHERE rn BETWEEN cnt / 2.0 AND cnt / 2.0 + 1
)
SELECT COUNT(*)                                       AS deals_with_valid_days,
       ROUND(AVG(l.days_to_close), 1)                 AS average_days,
       (SELECT median_days FROM median_value)         AS median_days,
       ROUND(100.0 * SUM(CASE WHEN l.days_to_close <= 30 THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_closed_within_30_days,
       ROUND(100.0 * SUM(CASE WHEN l.days_to_close > 90  THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_closed_after_90_days
FROM lead_master l
WHERE l.days_to_close IS NOT NULL;

-- Q08 | RESULT FILE: 08_days_to_close_bands
-- Business question: How are deals spread across fast, medium and slow?
SELECT CASE WHEN days_to_close <= 7  THEN '1  0-7 days'
            WHEN days_to_close <= 30 THEN '2  8-30 days'
            WHEN days_to_close <= 90 THEN '3  31-90 days'
            ELSE '4  Over 90 days' END                AS days_band,
       COUNT(*)                                       AS closed_deals,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM lead_master WHERE days_to_close IS NOT NULL), 1) AS pct_of_deals
FROM lead_master
WHERE days_to_close IS NOT NULL
GROUP BY days_band
ORDER BY days_band;

-- #####################################################################
-- SECTION 4: WHO ARE THE CLOSED DEALS? (closed deals only)
-- #####################################################################

-- Q09 | RESULT FILE: 09_lead_type
-- Business question: Which kinds of sellers do we win most, and how long do they take?
SELECT lead_type,
       COUNT(*)                                       AS closed_deals,
       ROUND(100.0 * COUNT(*) / (SELECT SUM(converted_flag) FROM lead_master), 1) AS pct_of_closed,
       ROUND(AVG(days_to_close), 1)                   AS avg_days_to_close
FROM lead_master
WHERE converted_flag = 1
GROUP BY lead_type
ORDER BY closed_deals DESC;

-- Q10 | RESULT FILE: 10_top_segments
-- Business question: Which product categories do the new sellers sell?
SELECT business_segment,
       COUNT(*)                                       AS closed_deals,
       ROUND(100.0 * COUNT(*) / (SELECT SUM(converted_flag) FROM lead_master), 1) AS pct_of_closed
FROM lead_master
WHERE converted_flag = 1
GROUP BY business_segment
ORDER BY closed_deals DESC
LIMIT 10;

-- Q11 | RESULT FILE: 11_behaviour_profile
-- Business question: Do some behaviour profiles take much longer to close?
SELECT behaviour_profile,
       COUNT(*)                                       AS closed_deals,
       ROUND(100.0 * COUNT(*) / (SELECT SUM(converted_flag) FROM lead_master), 1) AS pct_of_closed,
       ROUND(AVG(days_to_close), 1)                   AS avg_days_to_close
FROM lead_master
WHERE converted_flag = 1
GROUP BY behaviour_profile
ORDER BY closed_deals DESC;

-- Q12 | RESULT FILE: 12_sdr_workload
-- Business question: Is the closing work concentrated in a few sales reps?
-- (This is WORKLOAD, not performance: leads worked per person are not in the data.)
SELECT LEFT(sdr_id, 8)                                AS sdr,
       COUNT(*)                                       AS closed_deals,
       ROUND(100.0 * COUNT(*) / (SELECT SUM(converted_flag) FROM lead_master), 1) AS pct_of_closed
FROM lead_master
WHERE converted_flag = 1
GROUP BY sdr_id
ORDER BY closed_deals DESC
LIMIT 10;
