"""
03_statistical_tests.py
-----------------------
Statistical checks for the Olist Marketing Funnel project.

Questions answered (each one is an interview question):
  1. Is lead source (origin) really linked to sign-up, or is it chance?   -> chi-square test + effect size
  2. How sure are we about each channel's conversion rate?                -> 95% confidence interval (Wilson)
  3. Does the channel gap survive in the FAIR period (Jan-May 2018)?      -> same tests on Jan-May 2018 only
  4. Why use the MEDIAN for days-to-close, not the average?               -> skew + outlier check
  5. Is the "slow tail" real, or caused by the Dec-2017 recording start?  -> all months vs Jan-May 2018
  6. Do wolf-profile deals really take longer?                            -> Mann-Whitney and Kruskal-Wallis tests
  7. Is the May 2018 dip just a change in channel mix?                    -> expected vs actual conversion

Run from the repo root:
    pip install -r requirements.txt
    python python/03_statistical_tests.py

Inputs  (original Kaggle files, kept in data/raw/):
    olist_marketing_qualified_leads_dataset.csv
    olist_closed_deals_dataset.csv
Outputs (written to data/query_results/):
    stat_channel_confidence_intervals.csv
    stat_summary.txt
"""
import math
import os

import numpy as np
import pandas as pd
from scipy.stats import chi2_contingency, kruskal, mannwhitneyu

RAW = "data/raw"
OUT = "data/query_results"
os.makedirs(OUT, exist_ok=True)


def wilson_ci(successes, n, z=1.96):
    """95% Wilson confidence interval for a proportion (safe for small groups)."""
    if n == 0:
        return (np.nan, np.nan)
    p = successes / n
    denom = 1 + z**2 / n
    centre = (p + z**2 / (2 * n)) / denom
    half = z * math.sqrt(p * (1 - p) / n + z**2 / (4 * n**2)) / denom
    return (centre - half, centre + half)


def pct(x):
    return f"{x:.1%}"


# ---------- 1. Load and join (same logic as the notebooks) ----------
leads = pd.read_csv(os.path.join(RAW, "olist_marketing_qualified_leads_dataset.csv"))
deals = pd.read_csv(os.path.join(RAW, "olist_closed_deals_dataset.csv"))

leads["origin"] = leads["origin"].fillna("not_provided")
df = leads.merge(deals[["mql_id", "won_date", "lead_behaviour_profile"]], on="mql_id", how="left")
df["converted"] = df["won_date"].notna().astype(int)
df["first_contact_date"] = pd.to_datetime(df["first_contact_date"])
df["won_day"] = pd.to_datetime(df["won_date"]).dt.normalize()          # drop the time part
df["days_to_close"] = (df["won_day"] - df["first_contact_date"]).dt.days
df.loc[df["days_to_close"] < 0, "days_to_close"] = np.nan              # 1 deal won before first contact
df["period"] = np.where(df["first_contact_date"] < "2018-01-01", "Jun-Dec 2017", "Jan-May 2018")
df["month"] = df["first_contact_date"].dt.to_period("M").astype(str)

fair = df[df["period"] == "Jan-May 2018"]      # the FAIR, comparable period

lines = [f"Leads: {len(df):,} | Closed deals: {df['converted'].sum():,} "
         f"| Overall conversion: {pct(df['converted'].mean())} "
         f"| Jan-May 2018 conversion: {pct(fair['converted'].mean())}"]

# ---------- 2. Chi-square: origin vs converted ----------
def chi_block(data, label):
    table = pd.crosstab(data["origin"], data["converted"])
    chi2, p, dof, expected = chi2_contingency(table)
    n = table.values.sum()
    v = math.sqrt(chi2 / (n * (min(table.shape) - 1)))
    lines.append(f"\nCHI-SQUARE: origin vs sign-up  [{label}]")
    lines.append(f"chi2 = {chi2:.1f}, dof = {dof}, p-value = {p:.2e}, Cramer's V = {v:.2f}, "
                 f"cells with expected count < 5: {int((expected < 5).sum())}")

chi_block(df, "all months")
chi_block(fair, "Jan-May 2018 only")
lines.append("Meaning: p < 0.05 -> sign-up rate differs by channel by more than chance would explain.\n"
             "Cramer's V = HOW STRONG the link is (0 = none, 1 = perfect). Around 0.1-0.15 is a modest effect: "
             "the channel gap is real, but channel is not the only thing that drives sign-up.")

# ---------- 3. Confidence interval per channel (all months and fair period) ----------
rows = []
for origin, g in df.groupby("origin"):
    x, n_o = int(g["converted"].sum()), len(g)
    lo, hi = wilson_ci(x, n_o)
    gf = fair[fair["origin"] == origin]
    xf, nf = int(gf["converted"].sum()), len(gf)
    lof, hif = wilson_ci(xf, nf)
    rows.append({"origin": origin, "leads": n_o, "signed_up": x, "conversion_rate": x / n_o,
                 "ci_low_95": lo, "ci_high_95": hi,
                 "leads_jan_may": nf, "signed_up_jan_may": xf,
                 "conversion_rate_jan_may": xf / nf if nf else np.nan,
                 "ci_low_95_jan_may": lof, "ci_high_95_jan_may": hif})
ci = pd.DataFrame(rows).sort_values("leads", ascending=False)
ci.to_csv(os.path.join(OUT, "stat_channel_confidence_intervals.csv"), index=False)

show = ci[["origin", "leads", "conversion_rate", "ci_low_95", "ci_high_95",
           "conversion_rate_jan_may", "ci_low_95_jan_may", "ci_high_95_jan_may"]].copy()
for c in show.columns[2:]:
    show[c] = show[c].map(pct)
lines.append("\nCONVERSION RATE WITH 95% CONFIDENCE INTERVAL (left: all months | right: Jan-May 2018)")
lines.append(show.to_string(index=False))
lines.append("Meaning: if two channels' intervals do not overlap, the gap is unlikely to be luck. "
             "Wide intervals (few leads) mean 'be careful'.")

# ---------- 4. Search vs Social+Email (the headline comparison) ----------
def two_group(data, label):
    s = data["origin"].isin(["organic_search", "paid_search"])
    m = data["origin"].isin(["social", "email"])
    sw, sn = int(data[s]["converted"].sum()), int(s.sum())
    mw, mn = int(data[m]["converted"].sum()), int(m.sum())
    chi2, p, _, _ = chi2_contingency(np.array([[sw, sn - sw], [mw, mn - mw]]), correction=False)
    slo, shi = wilson_ci(sw, sn)
    mlo, mhi = wilson_ci(mw, mn)
    lines.append(f"[{label}] Search: {sw}/{sn} = {pct(sw/sn)} ({pct(slo)} to {pct(shi)}) | "
                 f"Social+Email: {mw}/{mn} = {pct(mw/mn)} ({pct(mlo)} to {pct(mhi)}) | "
                 f"chi2 = {chi2:.1f}, p = {p:.2e}")

lines.append("\nSEARCH vs SOCIAL+EMAIL (the headline comparison)")
two_group(df, "all months")
two_group(fair, "Jan-May 2018")

# ---------- 5. Days to close: mean vs median, skew, outliers, and the recording-start bias ----------
d = df["days_to_close"].dropna()
q1, q3 = d.quantile(0.25), d.quantile(0.75)
fence = q3 + 1.5 * (q3 - q1)
lines.append("\nDAYS TO CLOSE (closed deals only, 841 valid)")
lines.append(f"mean = {d.mean():.1f} | median = {d.median():.0f} | skew = {d.skew():.2f} "
             f"| P25 = {q1:.0f} | P75 = {q3:.0f} | P90 = {d.quantile(0.9):.0f}")
lines.append(f"IQR outlier fence = {fence:.0f} days -> {int((d > fence).sum())} deals ({(d > fence).mean():.1%}) "
             "are slow outliers. They are real deals, so they are kept and reported separately, not deleted.")
lines.append("Why median: a few very slow deals pull the mean up (right-skew); the median shows the typical deal.")

lines.append("\nIS THE SLOW TAIL REAL? Days to close by the period the lead first made contact")
for label, sub in [("All months", df), ("Jan-May 2018 (fair)", fair), ("Jun-Dec 2017", df[df["period"] == "Jun-Dec 2017"])]:
    v = sub["days_to_close"].dropna()
    lines.append(f"{label:<22} deals = {len(v):>3} | mean = {v.mean():>5.1f} | median = {v.median():>5.1f} "
                 f"| closed within 30 days = {(v <= 30).mean():.1%} | over 90 days = {(v > 90).mean():.1%}")
lines.append("Meaning: deal recording starts in Dec 2017, so a Jun-Nov 2017 lead only shows up if it closed LATE "
             "(median 216 days). That small group inflates the all-months average. Use the Jan-May 2018 numbers "
             "for planning. Both views are reported.")
lines.append("Caution: only CLOSED deals are measured. Leads still open when the data ends are invisible, "
             "so the true sales cycle is probably a little longer (right-censoring).")

# ---------- 6. Behaviour profile: do wolf deals take longer? ----------
deal_rows = df[df["converted"] == 1].copy()
deal_rows["profile"] = deal_rows["lead_behaviour_profile"].fillna("Not Provided")
single = deal_rows[deal_rows["profile"].isin(["cat", "eagle", "wolf", "shark"])].dropna(subset=["days_to_close"])
groups = {p: g["days_to_close"].values for p, g in single.groupby("profile")}
u, p_mw = mannwhitneyu(groups["wolf"], groups["cat"], alternative="two-sided")
h, p_kw = kruskal(*groups.values())
lines.append("\nBEHAVIOUR PROFILE vs DAYS TO CLOSE (single profiles only)")
for prof in ["cat", "eagle", "wolf", "shark"]:
    lines.append(f"{prof:<6} deals = {len(groups[prof]):>3} | median = {np.median(groups[prof]):>5.1f} "
                 f"| mean = {np.mean(groups[prof]):>5.1f}")
lines.append(f"Mann-Whitney wolf vs cat: p = {p_mw:.1e} | Kruskal-Wallis across 4 profiles: p = {p_kw:.1e}")
lines.append("Meaning: wolf deals are slower by more than chance. Non-parametric tests are used because "
             "days-to-close is skewed (not bell-shaped).")

# ---------- 7. May 2018 dip: is it just a change in channel mix? ----------
ref = fair[fair["month"] < "2018-05"].groupby("origin")["converted"].mean()
may = fair[fair["month"] == "2018-05"]
expected_may = may["origin"].map(ref).mean()
lines.append("\nMAY 2018 DIP: channel mix or something else?")
lines.append(f"May 2018 actual conversion = {pct(may['converted'].mean())} | expected if every channel converted "
             f"like Jan-Apr = {pct(expected_may)}")
lines.append("Meaning: the dip is NOT explained by channel mix. It shows up in most channels and is still visible "
             "after 60-90 days (see sql/05 query A5). Ask the data owner whether deals from May leads were still being logged.")

text = "\n".join(lines)
print(text)
with open(os.path.join(OUT, "stat_summary.txt"), "w", encoding="utf-8") as f:
    f.write(text + "\n")
