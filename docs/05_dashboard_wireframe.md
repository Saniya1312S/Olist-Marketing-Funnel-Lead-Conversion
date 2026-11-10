# 05. Dashboard Wireframe and Reading Guide

There are two dashboards. The **Excel dashboard** is the main one (live formulas, PivotTables, Checks sheet). The **interactive HTML dashboard** adds filters. A Power BI version is described in [`../powerbi/POWERBI_BUILD_GUIDE.md`](../powerbi/POWERBI_BUILD_GUIDE.md).

## A. Excel dashboard (`excel/Olist_Funnel_Dashboard.xlsx`, sheet "Dashboard")

```
+----------------------------------------------------------------------------------+
|  OLIST MARKETING FUNNEL & LEAD CONVERSION DASHBOARD                              |
+--------------+---------------+------------------+--------------------------------+
| TOTAL MQLs   | CLOSED DEALS  | CONVERSION RATE  | CONVERSION RATE, JAN-MAY 2018  |
| 8,000        | 842           | (all) 10.5%      | 13.0%                          |
+--------------+---------------+------------------+--------------------------------+
| NOT CONVERTED| AVG DAYS      | MEDIAN DAYS      | CLOSED WITHIN 30 DAYS          |
| 7,158        | 48.5          | 14.0             | 65.9%                          |
+--------------+---------------+------------------+--------------------------------+
|  FUNNEL: MQLs vs closed vs not          |  MONTHLY COHORT: MQLs, conversion %,   |
|  converted                              |  30-day conversion (warning: pre-2018) |
+-----------------------------------------+----------------------------------------+
|  LEAD ORIGIN: bars = MQLs, line = conv% |  CLOSED DEALS BY LEAD TYPE             |
+-----------------------------------------+----------------------------------------+
|  DAYS TO CLOSE BANDS (0-7 / 8-30 / ...) |  TOP 10 BUSINESS SEGMENTS              |
+-----------------------------------------+----------------------------------------+
|  ORIGIN TABLE (arrows vs overall)       |  TOP LANDING PAGES (+ % social)        |
+----------------------------------------------------------------------------------+
|  Notes, small-sample warning, "Data checks: ALL CHECKS PASS"                     |
+----------------------------------------------------------------------------------+
```
Other sheets: Insights (11 findings with live evidence), Analysis, PivotTables (6), Checks (18 tests), Master_Data, MQL_Data, Closed_Deals, Data_Notes.

## B. Interactive HTML dashboard (`dashboard/olist_funnel_dashboard.html`)

```
+----------------------------------------------------------------------------------+
| PERIOD:  [All months] [Jan-May 2018 (fair)] [Jun-Dec 2017]                       |
| CHANNEL: [All] [None] [organic_search] [paid_search] [social] [unknown] ...      |
+------+------+------+------+------+------+------+------+
| Leads|Signed|Rate  |Jan-May|Median|Avg   |<=30d |>90d  |   8 KPI cards react to filters
+------+------+------+------+------+------+------+------+
| Note: pre-2018 warning + unknown-source share and its conversion                 |
+--------------------------------------+-------------------------------------------+
| Sign-up rate by channel              | Monthly leads and sign-up rate            |
+--------------------------------------+-------------------------------------------+
| How long a deal takes                | Share of leads vs share of sign-ups       |
+--------------------------------------+-------------------------------------------+
```
Try this in an interview: pick **Jan-May 2018**, then select only **social**: 6.3% sign-up and median 23 days. Select only **unknown**: 20.7%.

## How to read it in 30 seconds
1. **Top row:** funnel health. About 1 in 10 leads signs up; 13.0% in the fair period.
2. **Channel view:** a tall bar with a low rate is volume without value (social, email).
3. **Days to close:** most deals close fast; the slow tail is smaller in the fair period (13.2% over 90 days).
4. **Warnings:** early months are not comparable.

## Who uses which part

| Panel | Main user | Decision |
|---|---|---|
| KPI cards | Leadership | Is the funnel healthy? |
| Channel chart and table | Marketing Manager | Where should budget go? |
| Days to close | Sales Manager | When to follow up |
| Unknown-source note (HTML) and Insights sheet | BI / CRM team | Fix tracking |
