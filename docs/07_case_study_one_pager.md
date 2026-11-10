# 07. Case Study: One Page

**Situation.** Olist signs up online sellers from marketing leads. Only about 10% of 8,000 leads became sellers, and budget and sales time are limited.

**Task.** Find which channels produce sellers, how long a sale takes, and which numbers can be trusted, then recommend actions.

**Action.**
1. Checked and joined two tables (no rows deleted, blanks labelled).
2. Built one row per lead in Python and a SQL view (`lead_master`).
3. Compared channels by volume and by value, then repeated the comparison on the fair period (Jan-May 2018).
4. Tested the gaps with chi-square, Wilson confidence intervals and Mann-Whitney.
5. Built an Excel dashboard with a self-checking sheet and an interactive filter dashboard.

**Result.**

| Finding | Evidence |
|---|---|
| Search is the engine | 48.5% of leads, 55.3% of sign-ups; 14.7% conversion in the fair period |
| Social and email bring volume, not sellers | 23% of leads, 10.7% of sign-ups; 5.7% conversion in the fair period |
| Untracked leads convert best | 14.5% of leads, 22.9% of sign-ups |
| The slow tail is partly a data artefact | 13.2% over 90 days in the fair period vs 17.8% for all months |
| May 2018 dipped, and mix does not explain it | 10.0% vs 13.4% expected |

**Recommendation and impact (illustrative, not a forecast).** Review social and email quality before adding budget. If those channels moved from about 6% to 8%, 10% or 12% in Jan-May 2018, that would be roughly 32, 60 or 88 extra deals on top of 781 (4%, 8% or 11% more). No cost data exists, so no ROI is calculated.

**Lesson.** Volume is not value, and a number is only as fair as the period behind it.
