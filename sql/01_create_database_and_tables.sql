-- =====================================================================
-- STEP 1: CREATE THE DATABASE AND TABLES        (MySQL 8.0)
-- Run this first. It creates two tables from the two cleaned CSV files:
--   mql          = 8,000 marketing-qualified leads (interested businesses)
--   closed_deals = 842 of those leads that became sellers (deal won)
-- =====================================================================
CREATE DATABASE IF NOT EXISTS olist_funnel;
USE olist_funnel;

DROP VIEW  IF EXISTS lead_master;
DROP TABLE IF EXISTS closed_deals;
DROP TABLE IF EXISTS mql;

CREATE TABLE mql (
    mql_id              VARCHAR(32) NOT NULL PRIMARY KEY,   -- unique lead ID
    first_contact_date  DATE        NOT NULL,               -- when the lead first made contact
    landing_page_id     VARCHAR(32),                        -- page the lead signed up on
    origin              VARCHAR(30)                         -- marketing channel (NULL for 60 leads)
);

CREATE TABLE closed_deals (
    mql_id                  VARCHAR(32) NOT NULL PRIMARY KEY,  -- one deal per lead
    seller_id               VARCHAR(32),
    sdr_id                  VARCHAR(32),                       -- Sales Development Representative
    sr_id                   VARCHAR(32),                       -- Sales Representative
    won_date                DATETIME,                          -- when the deal was won
    won_day                 DATE,                              -- won_date without the time
    business_segment        VARCHAR(50),
    lead_type               VARCHAR(30),
    lead_behaviour_profile  VARCHAR(30),
    business_type           VARCHAR(30),
    CONSTRAINT fk_deal_lead FOREIGN KEY (mql_id) REFERENCES mql (mql_id)
);

CREATE INDEX idx_mql_origin  ON mql (origin);
CREATE INDEX idx_mql_contact ON mql (first_contact_date);
