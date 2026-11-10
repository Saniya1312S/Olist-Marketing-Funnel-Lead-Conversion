# 03. Process Flow: As-Is vs To-Be

## As-Is (what the data shows today)

```mermaid
flowchart LR
    A[Business visits landing page] --> B[Fills form: becomes Lead / MQL]
    B --> C{Source recorded?}
    C -- "Yes (about 85%)" --> D[Sales contacts lead]
    C -- "No (about 14.5%)" --> D
    D --> E[Sales conversation]
    E --> F{Signs up?}
    F -- "Yes (about 10.5%)" --> G[Closed deal: won_date saved]
    F -- "No / not yet" --> H[Lead stays open, no record of why]
```

**Pain points in the As-Is process**
1. About 1 in 7 leads has no known source, so channel credit is hidden.
2. Only two stages are recorded (lead and closed deal), so drop-out points are invisible.
3. No cost data is linked to channels, so cost per customer cannot be measured.
4. Leads that do not sign up have no recorded reason.

## To-Be (proposed improvement)

```mermaid
flowchart LR
    A[Business visits landing page] --> B[Form with REQUIRED source field + campaign tag]
    B --> C[Lead / MQL saved with source]
    C --> D[SDR contact: stage and date recorded]
    D --> E[SR consultancy: stage and date recorded]
    E --> F{Signs up?}
    F -- Yes --> G[Closed deal + seller type + category recorded]
    F -- No --> H[Reason lost recorded]
    G --> I[Dashboard: conversion by channel, stage, cost per seller]
    H --> I
    I --> J[Monthly review: Marketing + Sales act on data]
```

**What changes**

| As-Is | To-Be | Recommendation it supports |
|---|---|---|
| Source can be blank or "unknown" | Source field required, campaign tag added | Rec. 3 |
| Two stages only | SDR and SR stages recorded with dates | Future scope |
| Seller type known only after the deal | Recorded at the start | Rec. 6 |
| Leads per rep not recorded | Leads handled per rep recorded | Rec. 7 |
| No reason for lost leads | "Reason lost" captured | Future scope |
| Channel cost not linked | Cost per channel added | Future scope (CAC) |
