# Data Dictionary

Source: Kaggle, *Marketing Funnel by Olist*. Two tables joined on `mql_id` (one lead to at most one closed deal).

## Table 1: Marketing Qualified Leads (8,000 rows, 4 columns)

| Column | Type | Meaning | Notes |
|---|---|---|---|
| `mql_id` | Text | Unique lead ID | Join key |
| `first_contact_date` | Date | Day the lead first contacted Olist | Jun 2017 - May 2018 |
| `landing_page_id` | Text | Landing page the lead came from | |
| `origin` | Text | Lead source / channel (organic search, paid search, social, email, direct traffic, unknown, ...) | 60 blank values labelled `not_provided`; `unknown` is a real recorded value, kept separate |

## Table 2: Closed Deals (842 rows, 14 columns)

| Column | Type | Meaning | Used? |
|---|---|---|---|
| `mql_id` | Text | Lead that signed up | Yes, join key |
| `seller_id` | Text | Unique seller ID | Yes |
| `sdr_id` | Text | Sales Development Rep who handled the lead | Counted only (no ranking) |
| `sr_id` | Text | Sales Rep who closed the deal | Counted only (no ranking) |
| `won_date` | Date | Day the deal was signed | Yes, gives days to close |
| `business_segment` | Text | Product category the seller will sell | Yes (signed deals only) |
| `lead_type` | Text | Type of seller business (e.g. online medium) | Yes (signed deals only) |
| `lead_behaviour_profile` | Text | Behaviour profile of the lead | 21% missing, labelled "Not Provided" |
| `has_company` | Yes/No | Seller has a registered company | Mostly blank, not used |
| `has_gtin` | Yes/No | Products have barcodes | Mostly blank, not used |
| `average_stock` | Text | Seller's stock size | Mostly blank, not used |
| `business_type` | Text | Reseller, manufacturer, other | Not used |
| `declared_product_catalog_size` | Number | Number of products declared | Mostly blank, not used |
| `declared_monthly_revenue` | Number | Revenue declared by the seller | 0 for 95% of deals, not used |

## Created columns (feature engineering)

| Column | How it is made | Why |
|---|---|---|
| `converted` | 1 if the lead has a closed deal, else 0 | Target flag for conversion rate |
| `days_to_close` | `won_date` minus `first_contact_date` in days | Sales cycle length. One negative gap is set to blank |
| `contact_month` | Month of `first_contact_date` | Monthly cohort view |
| `origin` (cleaned) | Blank origin becomes `not_provided` | Keeps every lead in the counts |
