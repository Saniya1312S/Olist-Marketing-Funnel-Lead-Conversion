# 04. Risk Register and Stakeholder Matrix

## Risk register

| ID | Risk | Likelihood | Impact | Mitigation in this project |
|---|---|---|---|---|
| R1 | Early months look weak only because deal recording starts Dec 2017 | High | High | Use Jan-May 2018 as the comparable period. Warning shown on dashboard. |
| R2 | Recent leads have not had time to close (right-censoring), so conversion and cycle length are understated | High | Medium | Same-window cohort curve (`sql/05` A5). State the limit openly. |
| R9 | Days to close for all months is inflated: Jun-Nov 2017 leads only appear if they closed late (median 216 days) | High | Medium | Report both views. Use Jan-May 2018 (median 12.5, 13.2% over 90 days) for planning (`sql/05` A4). |
| R10 | May 2018 conversion dip (10.0% vs 13.4% expected) has an unknown cause | Medium | Medium | Not explained by channel mix. Raised as a question for the data owner. |
| R3 | 14.5% of leads have unknown or blank source | High | Medium | Keep them as separate groups. Recommend tracking fix. |
| R4 | Channel and landing page effects are mixed together | Medium | Medium | Do not claim cause. Recommend analysing page and channel together. |
| R5 | No cost data, so "keep investing in search" cannot be proven profitable | High | High | Recommendation says: needs cost data. Paid and unpaid search kept separate. |
| R6 | Small channels have wide uncertainty (e.g. email) | Medium | Medium | Confidence intervals added (`03_statistical_tests.py`). |
| R7 | Dashboard numbers differ from SQL or Python | Low | High | 18 automatic checks. Results compared across all three tools. |
| R8 | Wrong decisions from treating patterns as causes | Medium | High | Recommendations are labelled "test before changing budgets". |

## Stakeholder matrix (influence vs interest)

| Stakeholder | Influence | Interest | How to engage |
|---|---|---|---|
| Marketing Manager | High | High | Manage closely. Share channel findings first. |
| Sales Manager | High | High | Manage closely. Review days-to-close and follow-up timing. |
| Leadership | High | Medium | Keep satisfied. One-page summary. |
| CRM / Data team | Medium | High | Keep informed. Share tracking gaps and the To-Be fields. |
| Sales Reps | Low | Medium | Keep informed. Explain that reps are not ranked here. |

## Who owns each recommendation

| # | Recommendation | Owner | Success measure |
|---|---|---|---|
| 1 | Review lead quality and follow-up for social and email before adding budget | Marketing Manager with Sales Manager | Monthly conversion rate by channel |
| 2 | Keep investing in search, **and check paid search cost first** | Marketing Manager | Share of deals from search, cost per deal once cost data exists |
| 3 | Fix tracking of lead source (highest-value fix: unknown-source leads convert at 16.7%) | Sales / BI Operations | Share of leads with unknown or blank source |
| 4 | Follow up around day 30, treat 90+ day deals and wolf-profile leads separately | Sales Manager | Share of deals closed within 30 days |
| 5 | Use Jan-May 2018 as benchmark, compare on a fixed 30-day window | BI team | Like-for-like conversion by month |
| 6 | Record seller type and category at the start | Sales Operations | Conversion by seller type becomes possible |
| 7 | Record leads handled per rep | Sales Manager | Conversion per rep becomes possible |
