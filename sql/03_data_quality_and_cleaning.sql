-- =====================================================================
-- STEP 3: DATA QUALITY CHECKS AND THE ANALYSIS TABLE      (MySQL 8.0)
-- Nothing is deleted. Each check tells us whether the data can be trusted.
-- At the end we build ONE view (lead_master) with one row per lead.
-- =====================================================================
USE olist_funnel;

-- DQ1 | Row counts (expect 8,000 leads and 842 deals)
SELECT (SELECT COUNT(*) FROM mql)          AS mql_rows,
       (SELECT COUNT(*) FROM closed_deals) AS closed_deal_rows;

-- DQ2 | Duplicate lead IDs (expect 0 in both tables)
SELECT (SELECT COUNT(*) - COUNT(DISTINCT mql_id) FROM mql)          AS duplicate_mql_ids,
       (SELECT COUNT(*) - COUNT(DISTINCT mql_id) FROM closed_deals) AS duplicate_deal_ids;

-- DQ3 | Closed deals with no matching lead (expect 0, so the join is safe)
SELECT COUNT(*) AS orphan_deals
FROM closed_deals c
LEFT JOIN mql m ON m.mql_id = c.mql_id
WHERE m.mql_id IS NULL;

-- DQ4 | Leads with a blank origin (60). Kept and labelled not_provided later.
SELECT COUNT(*) AS leads_with_blank_origin FROM mql WHERE origin IS NULL;

-- DQ5 | Date ranges (first contact Jun 2017 - May 2018; deals won Dec 2017 - Nov 2018)
SELECT (SELECT MIN(first_contact_date) FROM mql)         AS first_contact_min,
       (SELECT MAX(first_contact_date) FROM mql)         AS first_contact_max,
       (SELECT MIN(won_day)            FROM closed_deals) AS first_deal_won,
       (SELECT MAX(won_day)            FROM closed_deals) AS last_deal_won;

-- DQ6 | Deals won BEFORE the lead first made contact (data error; expect 1)
SELECT COUNT(*) AS deals_with_negative_date_gap
FROM closed_deals c
JOIN mql m ON m.mql_id = c.mql_id
WHERE c.won_day < m.first_contact_date;

-- DQ7 | Missing details on closed deals (never guessed; shown as Not Provided)
SELECT SUM(lead_behaviour_profile IS NULL) AS missing_behaviour_profile,
       SUM(lead_type              IS NULL) AS missing_lead_type,
       SUM(business_segment       IS NULL) AS missing_segment
FROM closed_deals;

-- DQ8 | All origin values and how many leads each has
SELECT COALESCE(origin, 'not_provided') AS origin, COUNT(*) AS leads
FROM mql
GROUP BY COALESCE(origin, 'not_provided')
ORDER BY leads DESC;

-- =====================================================================
-- THE ANALYSIS VIEW: one row per lead
--   * conversion_status / converted_flag : did the lead become a closed deal?
--   * days_to_close : won day minus first-contact day (blank if the gap is negative)
--   * cohort_period : Jun-Dec 2017 is NOT comparable with Jan-May 2018, because
--                     the first deal in the data was won in Dec 2017
-- =====================================================================
CREATE OR REPLACE VIEW lead_master AS
SELECT m.mql_id,
       m.first_contact_date,
       DATE_FORMAT(m.first_contact_date, '%Y-%m')                      AS first_contact_month,
       COALESCE(m.origin, 'not_provided')                              AS origin,
       m.landing_page_id,
       CASE WHEN c.mql_id IS NOT NULL THEN 'Converted' ELSE 'Not Converted' END AS conversion_status,
       CASE WHEN c.mql_id IS NOT NULL THEN 1 ELSE 0 END                AS converted_flag,
       c.won_day,
       CASE WHEN c.mql_id IS NOT NULL AND DATEDIFF(c.won_day, m.first_contact_date) >= 0
            THEN DATEDIFF(c.won_day, m.first_contact_date) END         AS days_to_close,
       CASE WHEN c.mql_id IS NOT NULL THEN COALESCE(c.lead_type, 'Not Provided') END               AS lead_type,
       CASE WHEN c.mql_id IS NOT NULL THEN COALESCE(c.business_segment, 'Not Provided') END        AS business_segment,
       CASE WHEN c.mql_id IS NOT NULL THEN COALESCE(c.lead_behaviour_profile, 'Not Provided') END  AS behaviour_profile,
       c.sdr_id,
       c.sr_id,
       CASE WHEN m.first_contact_date < '2018-01-01' THEN 'Jun-Dec 2017' ELSE 'Jan-May 2018' END   AS cohort_period
FROM mql m
LEFT JOIN closed_deals c ON c.mql_id = m.mql_id;

-- Control query: the view must still have 8,000 rows and 842 converted leads
SELECT COUNT(*) AS rows_in_view, SUM(converted_flag) AS converted_leads FROM lead_master;
