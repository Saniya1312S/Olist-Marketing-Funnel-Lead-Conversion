# Power BI Build Guide (not yet built)

> **Status: guide only.** No `.pbix` file is in this repo. Build it in about 1 to 2 hours with this guide, save a screenshot to `documents/images/`, and only then say "Power BI dashboard" in your README or resume.

## 1. Load the data
Get Data > Text/CSV > `data/cleaned/lead_master.csv` (8,000 rows, one per lead). In Power Query set `first_contact_date` and `won_day` to Date, `converted_flag` and `days_to_close` to Whole Number. Name the table `Leads`.

## 2. Helper columns (Modeling > New column)
```
Period = IF(Leads[first_contact_date] < DATE(2018,1,1), "Jun-Dec 2017", "Jan-May 2018")
Channel Group = SWITCH(TRUE(),
    Leads[origin] IN {"organic_search","paid_search"}, "Search",
    Leads[origin] IN {"social","email"}, "Social + email",
    Leads[origin] IN {"unknown","not_provided"}, "Unknown / blank",
    "Other known")
Days Band = SWITCH(TRUE(), ISBLANK(Leads[days_to_close]), BLANK(),
    Leads[days_to_close] <= 7, "1) 0-7", Leads[days_to_close] <= 30, "2) 8-30",
    Leads[days_to_close] <= 90, "3) 31-90", "4) 90+")
```

## 3. DAX measures
```
Leads = COUNTROWS(Leads)
Closed Deals = SUM(Leads[converted_flag])
Conversion Rate = DIVIDE([Closed Deals], [Leads])
Conversion Jan-May 2018 = CALCULATE([Conversion Rate], Leads[Period] = "Jan-May 2018")
Median Days to Close = MEDIAN(Leads[days_to_close])
Average Days to Close = AVERAGE(Leads[days_to_close])
Closed Within 30 Days % = DIVIDE(CALCULATE(COUNTROWS(Leads), Leads[days_to_close] <= 30), CALCULATE(COUNTROWS(Leads), NOT ISBLANK(Leads[days_to_close])))
Over 90 Days % = DIVIDE(CALCULATE(COUNTROWS(Leads), Leads[days_to_close] > 90), CALCULATE(COUNTROWS(Leads), NOT ISBLANK(Leads[days_to_close])))
Share of Leads = DIVIDE([Leads], CALCULATE([Leads], ALL(Leads[origin])))
Share of Deals = DIVIDE([Closed Deals], CALCULATE([Closed Deals], ALL(Leads[origin])))
Volume-Value Gap (pts) = ([Share of Deals] - [Share of Leads]) * 100
```
**Check your build:** with no filters you must see 8,000 / 842 / 10.5% / median 14 / average 48.5. With Period = Jan-May 2018: 5,998 / 781 / 13.0% / median 12.5.

## 4. Pages (matches the handbook's three dashboard levels)

| Page | Audience | Visuals |
|---|---|---|
| 1 Executive | Leadership | 6 KPI cards, funnel, monthly line (leads + conversion), text box with the Dec 2017 warning |
| 2 Operational | Marketing and Sales | Clustered bar `Share of Leads` vs `Share of Deals` by Channel Group, conversion by origin table with conditional formatting, days-band column chart, drill-through from origin to landing page |
| 3 Manager | Sales Manager | Recommendations text box, alert card when `Over 90 Days %` > 15%, behaviour-profile median days |

Slicers on every page: **Period**, **origin**, **first_contact_month**. Sync them across pages (View > Sync slicers).

## 5. Publish checklist
- [ ] Screenshot of each page saved to `documents/images/`
- [ ] `.pbix` saved in `powerbi/`
- [ ] README Dashboard section updated to mention Power BI
