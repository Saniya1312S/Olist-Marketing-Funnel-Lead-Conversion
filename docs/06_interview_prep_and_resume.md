# 06. Interview Preparation and Resume Points

## 30-second version
> "Only about 1 in 10 interested businesses signs up with Olist. I analysed 8,000 leads and found that search brings about half the leads and over half the sign-ups, while social and email bring volume but convert much less. I also found two traps in the data: early months look weak only because deal recording started in December 2017, and that same effect inflates the sales-cycle length. My advice: protect search, review social and email quality, and fix lead-source tracking."

## 2-minute version
1. **Context:** Olist is a Brazilian company that helps small businesses sell on marketplaces. It grows by signing up sellers from marketing leads.
2. **Problem:** Only about 10% of leads sign up and budget is limited. Which channels bring leads that convert, and how long does a sale take?
3. **Data:** Two Kaggle tables, 8,000 leads and 842 closed deals, joined on `mql_id`.
4. **What I did:** Cleaned in Python without deleting rows, answered business questions in SQL (CTEs, window functions, a recursive CTE), built an Excel dashboard with PivotTables and an 18-test Checks sheet, built an interactive filter dashboard, and tested findings with chi-square, confidence intervals and Mann-Whitney.
5. **Findings:** Overall 10.5%, fair period 13.0%. Search about 12% (14.7% fair), social 5.6%, email 3.0%. Median 14 days, average 48.5. 14.5% of leads have no known source, and they convert well.
6. **Traps I found:** (a) Jun-Dec 2017 shows 3% only because recording starts in Dec 2017. (b) The same effect inflates days to close: fair-period median is 12.5 and 13% (not 18%) take over 90 days.
7. **Recommendations:** Review social and email quality before adding budget; keep investing in search after checking paid-search cost; fix source tracking; follow up near day 30.
8. **Limits:** No cost data, only two funnel stages, patterns not causes.

## Likely questions and model answers

**Q1. Why Jan-May 2018 as the comparison period?**
Deal recording starts in December 2017, so Jun-Nov 2017 leads can only show a few of their deals. Early months look weak for a data reason. Jan-May 2018 is where recording is complete.

**Q2. Why median, not average, for days to close?**
A few very slow deals pull the average up (skew 2.29). The median shows the typical deal. I report both, plus the share over 90 days.

**Q3. Is the difference between search and email real or luck?**
Chi-square p is far below 0.05 in both the full data and the fair period, and the 95% confidence intervals for search (13.5% to 16.1% in Jan-May) and social+email (4.6% to 7.1%) do not overlap. Cramer's V is about 0.15, a modest effect: channel matters but is not the only driver.

**Q4. Does search cause more sign-ups?**
No. This is observational data. Search visitors may already be looking for a marketplace partner, and landing page and channel are tangled together.

**Q5. What would you do with cost data?**
Calculate cost per closed deal (CAC) by channel. "Keep investing in search" is about conversion, not profit, and paid search costs money.

**Q6. What does "typical time to close" miss?**
Only closed deals are counted. Leads still open when the data ends are invisible, so the true cycle is probably longer (right-censoring).

**Q7. Unknown-source leads: what did you do?**
Kept them, did not guess a channel, labelled blanks `not_provided` and kept `unknown` separate. They are 14.5% of leads but 22.9% of sign-ups (20.7% conversion in the fair period). So the tracking fix is high value. I would not call "unknown" a channel to buy more of.

**Q8. How do you know your numbers are right?**
The same results come out of Python, SQL and Excel, and the workbook has 18 checks that must pass. I also ran every SQL file against a real database and compared with pandas.

**Q9. Why Excel and not Power BI?**
Excel PivotTables suit a small clean dataset that managers can open without extra software. I added an interactive filter dashboard, and `powerbi/POWERBI_BUILD_GUIDE.md` shows how the same model would be built in Power BI.

**Q10. Walk me through one SQL query.**
Query A1 in `sql/05`: a CTE counts leads and deals per channel, then `SUM() OVER ()` gives each channel's share of leads and of deals. A negative gap means volume without value (social: 16.9% of leads, 8.9% of deals).

**Q11. What data quality issues did you find?**
60 blank origins, 21% of deals missing behaviour profile, about 92% of questionnaire fields blank, declared revenue 0 for 95% of deals, one deal won before first contact. All documented, no rows deleted.

**Q12. The slow tail: is it real?**
Partly. The all-months figure (18% over 90 days, average 48.5) includes 61 deals from Jun-Dec 2017 leads with a median of 216 days, because only late closers appear. For Jan-May 2018 leads: median 12.5, average 35.7, 13.2% over 90 days. Both are reported.

**Q13. What happened in May 2018?**
Conversion was 10.0% against 13.4% expected from its channel mix, and it is still lower at day 60 and 90, so it is not just lack of time. I cannot explain the cause from this data, so I raised it as a question for the data owner.

**Q14. Why a non-parametric test for wolf vs cat?**
Days to close is skewed, so a t-test's assumptions fail. Mann-Whitney compares the distributions without assuming a bell shape (p below 0.001; medians 36 vs 13 days).

**Q15. What would you build next?**
Marketing cost for CAC by channel, landing page and channel analysed together, the missing funnel stages, and later a simple lead-scoring model.

## Resume bullets (choose 3-4)
- Analysed 8,000 marketing leads and 842 closed deals from Olist using Python, MySQL and Excel to measure funnel conversion (10.5% overall, 13.0% in the comparable Jan-May 2018 period).
- Showed that search converts at 12% (14.7% in the fair period) versus 5.6% for social and 3.0% for email, and validated the gap with chi-square tests and 95% confidence intervals.
- Identified a data-coverage bias that overstated the sales cycle (18% of deals over 90 days vs 13.2% on a like-for-like cohort) and corrected the benchmark used for follow-up planning.
- Wrote 21 SQL queries (CTEs, window functions, recursive CTE, percentiles, cohorts) and reconciled results across Python, SQL and Excel with an 18-test Checks sheet.
- Built an Excel dashboard (8 KPIs, 6 charts, 6 PivotTables) and an interactive filter dashboard, plus BRD, user stories, process flows, risk register and 7 owner-assigned recommendations.
