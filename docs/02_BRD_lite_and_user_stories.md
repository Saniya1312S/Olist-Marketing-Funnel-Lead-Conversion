# 02. Business Requirement Document (BRD-lite), Functional Requirements and User Stories

> This is a learning project on a public dataset. The documents below show how I would capture requirements if this were a real request from Olist.

## 1. Business Requirement Document (BRD-lite)

| Item | Detail |
|---|---|
| Project name | Olist Marketing Funnel & Lead Conversion Analytics |
| Requested by (assumed) | Head of Marketing and Head of Sales |
| Business problem | Only about 10% of leads sign up. The company cannot tell which channels bring leads that convert, and how long sales take. |
| Goal | Give managers a clear, trusted view of conversion by channel and by time, with actions |
| In scope | 8,000 leads (Jun 2017 - May 2018), 842 closed deals, conversion by channel, days to close, seller profile, dashboard, recommendations |
| Out of scope | Marketing cost and ROI, revenue per seller, predictive lead scoring, rep performance ranking |
| Data sources | Kaggle "Marketing Funnel by Olist": leads table and closed deals table |
| Success criteria | (1) Numbers reconcile across Python, SQL and Excel. (2) A manager can answer "which channel converts best?" in under one minute from the dashboard. (3) Recommendations have an owner and a measure. |
| Assumptions | A lead with no deal record is "not converted". Dates are in one time zone. |
| Constraints | No cost data, no stage-by-stage tracking, deal recording starts Dec 2017 |

## 2. Functional requirements (FRD-lite)

| ID | Requirement | Priority |
|---|---|---|
| FR-1 | The dashboard shows total leads, closed deals and overall conversion rate as KPI cards | Must |
| FR-2 | The dashboard shows leads and conversion rate by lead source | Must |
| FR-3 | The dashboard shows days-to-close (median, average, share over 90 days) | Must |
| FR-4 | The dashboard shows monthly conversion with a visible warning for months before 2018 | Must |
| FR-5 | Channel table uses a clear signal (arrow or colour) for above / below average | Should |
| FR-6 | A Checks sheet proves totals, pivots and KPIs match the source data | Must |
| FR-7 | Every insight shows its evidence number | Should |
| FR-8 | Users can filter by lead source and period | Should (delivered in `dashboard/olist_funnel_dashboard.html`; the Excel dashboard has no slicers) |

## 3. User stories and acceptance criteria

| ID | User story | Acceptance criteria |
|---|---|---|
| US-1 | As a **Marketing Manager**, I want conversion rate by channel, so that I can move budget to channels that produce sellers. | Each channel shows leads, deals and conversion rate. Search about 12%, social 5.6%, email 3.0% match the SQL result. |
| US-2 | As a **Marketing Manager**, I want to see volume AND value together, so that I do not reward channels that only bring crowds. | Chart shows lead count (bars) with conversion (line). Channels with a large share of leads but a small share of deals are visible. |
| US-3 | As a **Sales Manager**, I want to know how long deals take, so that I can plan follow-ups. | Median (14 days), average (48.5 days) and the 90+ day share (about 18%) are shown. The note says only closed deals are measured. |
| US-4 | As a **CRM Manager**, I want to know how many leads have no source, so that I can fix tracking. | The unknown or blank share (1,159, 14.5%, converting at 16.7%) is shown in the interactive dashboard note and on the Excel Insights sheet (finding 5). |
| US-5 | As a **Leadership member**, I want a fair monthly trend, so that I do not draw wrong conclusions. | Months before Jan 2018 carry a warning about deal-recording coverage. |
| US-6 | As an **Analyst reviewing the work**, I want proof the numbers are right, so that I can trust the dashboard. | Checks sheet reports ALL CHECKS PASS (18 tests). |

## 4. Traceability: requirement to project file

| Requirement | Where it is delivered |
|---|---|
| FR-1 to FR-5, FR-7 | `excel/Olist_Funnel_Dashboard.xlsx` (Dashboard + Insights sheets) |
| FR-8, US-4 | `dashboard/olist_funnel_dashboard.html` (period and channel filters) |
| FR-6 | Checks sheet in the same workbook |
| Numbers cross-check | `python/` notebooks, `sql/04_analysis_queries.sql`, `sql/05_sql_showcase_advanced.sql`, dashboard HTML |
| Statistical support | `python/03_statistical_tests.py` |
