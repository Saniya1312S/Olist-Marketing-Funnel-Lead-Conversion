-- =====================================================================
-- STEP 2: LOAD THE CLEANED CSV FILES             (MySQL 8.0)
-- Files: data/cleaned/mql_clean.csv and data/cleaned/closed_deals_clean.csv
--
-- EASIEST WAY (recommended for beginners):
--   MySQL Workbench -> right-click the table -> "Table Data Import Wizard"
--   -> choose the CSV file -> import into the EXISTING table.
--
-- COMMAND WAY (change the paths first; local_infile must be enabled):
--   SET GLOBAL local_infile = 1;
--   If your CSV has Windows line endings, use '\r\n' instead of '\n'.
-- =====================================================================
USE olist_funnel;

LOAD DATA LOCAL INFILE 'data/cleaned/mql_clean.csv'
INTO TABLE mql
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(mql_id, first_contact_date, landing_page_id, @origin)
SET origin = NULLIF(@origin, '');                 -- blank origin becomes NULL

LOAD DATA LOCAL INFILE 'data/cleaned/closed_deals_clean.csv'
INTO TABLE closed_deals
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(mql_id, seller_id, sdr_id, sr_id, won_date, won_day,
 @segment, @lead_type, @profile, @btype)
SET business_segment       = NULLIF(@segment, ''),
    lead_type              = NULLIF(@lead_type, ''),
    lead_behaviour_profile = NULLIF(@profile, ''),
    business_type          = NULLIF(@btype, '');

-- Row-count check: expect 8,000 and 842
SELECT 'mql' AS table_name, COUNT(*) AS row_count FROM mql
UNION ALL
SELECT 'closed_deals', COUNT(*) FROM closed_deals;
