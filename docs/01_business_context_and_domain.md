# 01. Business Context, Domain Knowledge, KPIs and Stakeholders

## Company background
**Olist** is a Brazilian company that connects small businesses to big online marketplaces. A business gives Olist its products, and Olist helps sell them on marketplaces and handles the logistics. Olist grows by signing up more **sellers**, so it needs a steady flow of good **leads**.

## How the Olist sales process works (domain knowledge)

```
Landing page  ->  Lead (MQL)  ->  SDR contact  ->  SR consultancy  ->  Closed deal (seller signs up)
 (marketing)      (marketing)     (sales)          (sales)             (won_date recorded)
```

| Step | Who | What happens |
|---|---|---|
| Landing page | Marketing | A business finds an Olist page (search, social, email, ads) and fills a form |
| Lead (MQL) | Marketing | The form fill makes it a **Marketing Qualified Lead** and it is passed to sales |
| SDR contact | Sales Development Rep | First call or message to check interest |
| SR consultancy | Sales Rep | A deeper conversation about what the seller needs |
| Closed deal | Sales Rep | The business signs up and becomes a seller |

**Important:** the public dataset only has the first stage (lead) and the last stage (closed deal). The middle stages (SDR contact, SR consultancy) are not recorded, so I cannot see exactly where leads drop out. This is listed under Future Scope in the README.

## Glossary (simple words first)

| Term | Plain meaning |
|---|---|
| **MQL** (Marketing Qualified Lead) | A business that showed interest and was passed to sales |
| **Conversion rate** | Of every 100 leads, how many sign up (842 of 8,000 = 10.5 per 100) |
| **Lead source / origin / channel** | Where the lead came from (organic search, paid search, social, email, direct...) |
| **Sales cycle (days to close)** | Days from first contact to the signed deal |
| **Funnel leakage** | Leads that drop out between stages |
| **Win rate** | Same idea as conversion rate, usually used by the sales team |
| **CAC** (Customer Acquisition Cost) | Marketing + sales cost to win one customer. **Not possible here, no cost data** |
| **Attribution** | Deciding which channel deserves the credit for a sale |
| **Right-censoring** | Leads that have not closed *yet* when the data ends. They look like "not converted" but may still convert |

## KPI definitions (formulas used in this project)

| KPI | Formula | Value |
|---|---|---|
| Total leads | Count of leads | 8,000 |
| Closed deals | Count of leads with a won date | 842 |
| Overall conversion rate | Closed deals / Total leads | 10.5% |
| Conversion rate, comparable period | Closed deals / Leads, leads first contacted Jan-May 2018 | 13.0% |
| Channel conversion rate | Closed deals of a channel / Leads of that channel | Search about 12%, social 5.6%, email 3.0% |
| Share of leads / share of deals | Channel leads (or deals) / All leads (or deals) | Used to spot "volume without value" |
| Median days to close | Middle value of days from first contact to won date | 14 days |
| Average days to close | Mean of the same | 48.5 days |
| Slow-deal share | Deals taking more than 90 days / Deals with a valid date | 150 / 841, about 18% (13.2% for Jan-May 2018 leads) |
| Closed within 30 days | Deals closed in 30 days or less / Deals with a valid date | 65.9% (70.6% for Jan-May 2018 leads) |
| Unknown-source share | Leads with unknown or blank origin / Total leads | 14.5% |

## Business questions this project answers
Questions are written as decisions, not as simple queries.

| # | Business question | Where answered |
|---|---|---|
| 1 | Which channels give the most sellers per lead, and which only give volume? | SQL 04 Q04-Q05, 05 A1-A3, chart 5 |
| 2 | Does the channel ranking survive when we remove the weak early months? | SQL 05 A2, chart 6, stats script |
| 3 | Are leads with an unknown source a problem or an opportunity? | SQL 04 Q05, README finding 4 |
| 4 | When should sales follow up, and how slow is the slow tail really? | SQL 05 A4-A5, chart 7 |
| 5 | Is the May 2018 drop caused by channel mix? | Stats script section 7, chart 8 |
| 6 | Which behaviour profiles need an earlier follow-up? | SQL 05 A9, Mann-Whitney test |

## Business problem and measurable objectives

**Problem:** Only about 10% of leads become sellers. Marketing money and sales time are limited. Judging channels only by *how many leads* they bring hides which ones actually produce sellers.

| # | Business objective (measurable) | Success looks like |
|---|---|---|
| 1 | Decide which channels deserve more budget and which need review | A ranked channel table with conversion rate and a confidence range |
| 2 | Shorten and plan the sales follow-up | Know the median and the slow-deal share, so follow-up timing is set |
| 3 | Fix the visibility gap in lead tracking | Unknown-source leads (14.5%) reduced next quarter. They convert at 16.7%, so the hidden source is valuable |
| 4 | Make month-to-month comparison fair | A fixed-window metric that does not reward old months |

## Stakeholders

| Stakeholder | Interest | What they get from this project |
|---|---|---|
| Marketing Manager | Where to spend the budget | Channel conversion table, "volume vs value" view |
| Sales Manager | When and how to follow up | Days-to-close profile, slow-deal flag |
| CRM / Data team | Clean, complete tracking | List of tracking gaps (unknown source, missing stages) |
| Leadership | Growth and efficiency | Headline conversion, opportunity sizing |
| Sellers (end customers) | Smooth sign-up | Faster follow-up on slow deals |
