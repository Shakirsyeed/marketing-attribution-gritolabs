# 📊 Multi-Channel Marketing Analytics & Attribution Framework
### Grito Labs | Data Analytics Challenge Submission

![Dashboard Preview](dashboard/data/chart_channel_performance.png)

---

## 🧭 Table of Contents
- [Project Overview](#-project-overview)
- [Dataset](#-dataset)
- [KPIs Covered](#-kpis-covered)
- [Attribution Models](#-attribution-models)
- [Key Findings](#-key-findings)
- [Project Structure](#-project-structure)
- [How to Run](#-how-to-run)
- [Tools Used](#-tools-used)

---

## 📌 Project Overview

This project builds a complete **Multi-Channel Marketing Analytics & Attribution Framework** to evaluate campaign performance across **Email, Paid Advertising, Social Media, and Organic** channels.

It addresses the core business challenge: *"Which marketing channels are actually driving revenue — and how much credit should each one get?"*

**What this project delivers:**
- Channel-level performance & ROI analysis
- Customer journey path analysis
- 4 attribution models to fairly credit each touchpoint
- CLV segmentation by acquisition channel
- Data-driven budget reallocation strategy

---

## 📂 Dataset

| File | Rows | Description |
|------|------|-------------|
| `data/campaigns.csv` | 128 | Campaign-level spend, impressions, clicks, conversions, revenue |
| `data/customers.csv` | 500 | Customer profiles with CLV, AOV, lifespan, demographics |
| `data/touchpoints.csv` | 1,236 | Individual customer-channel interactions and conversion events |
| **Total** | **1,864** | Across Q1–Q4 2024 |

---

## 📐 KPIs Covered

| KPI | Formula |
|-----|---------|
| **CTR** | Clicks / Impressions × 100 |
| **CPC** | Total Spend / Total Clicks |
| **Conversion Rate** | Conversions / Clicks × 100 |
| **CAC** | Total Spend / New Customers |
| **ROAS** | Revenue / Ad Spend |
| **ROI** | (Revenue − Spend) / Spend × 100 |
| **CLV** | AOV × Purchase Frequency × Customer Lifespan |
| **CPA** | Total Spend / Conversions |

---

## 🔁 Attribution Models

| Model | Logic | Best Used For |
|-------|-------|---------------|
| **First-Touch** | 100% credit → first touchpoint | Awareness measurement |
| **Last-Touch** | 100% credit → last touchpoint before conversion | Closing channel analysis |
| **Linear** | Equal credit across all touchpoints | Strategic budget planning |
| **Time-Decay** | More credit to recent touchpoints (λ=0.1) | Campaign optimization |

---

## 📈 Key Findings

### Channel Performance Summary
| Channel | ROAS | CAC | CVR | CLV | Status |
|---------|------|-----|-----|-----|--------|
| Email | **5.99x** | **$12** | **4.71%** | $1,779 | ✅ Top Performer |
| Organic | 3.34x | $22 | 1.88% | **$2,127** | ✅ Highest CLV |
| Social | 3.59x | $19 | 3.21% | $952 | ✅ Strong Awareness |
| Paid Ads | 3.91x | $31 | 2.14% | $491 | ⚠️ Needs Optimization |

### Top Conversion Path
> **Social → Email → Paid_Ad** accounts for the highest frequency (87 customers)

### Budget Reallocation Recommendation
| Channel | Current | Recommended | Change |
|---------|---------|-------------|--------|
| Email | 12.2% | 25.0% | ▲ +12.8% |
| Paid Ads | 54.3% | 35.0% | ▼ -19.3% |
| Social | 26.9% | 30.0% | ▲ +3.1% |
| Organic | 6.6% | 10.0% | ▲ +3.4% |

**Projected Impact:** +22% Revenue Uplift · -28% CAC Reduction · ROAS 4.04x → 5.4x

---

## 🗂️ Project Structure

```
marketing-attribution-gritolabs/
│
├── README.md
│
├── data/
│   ├── campaigns.csv          ← 128 rows — campaign metrics
│   ├── customers.csv          ← 500 rows — customer profiles
│   ├── touchpoints.csv        ← 1,236 rows — journey data
│   └── schema.md              ← Data dictionary
│
├── sql/
│   ├── 01_channel_performance.sql    ← CTR, CPC, ROAS, ROI by channel
│   ├── 02_customer_journey.sql       ← Journey paths, device analysis
│   ├── 03_attribution_models.sql     ← All 4 attribution models
│   ├── 04_kpi_clv_analysis.sql       ← CLV, segmentation, demographics
│   └── 05_budget_optimization.sql    ← Reallocation + simulation
│
├── notebooks/
│   └── marketing_analysis.ipynb     ← Full analysis (open in Google Colab)
│
├── dashboard/
│   └── index.html                   ← Interactive dashboard (open in browser)
│
└── docs/
    ├── methodology.md               ← Attribution logic & assumptions
    └── recommendations.md           ← Final business strategy
```

---

## ▶️ How to Run

### 🌐 Interactive Dashboard (No install needed)
```
Open dashboard/index.html in any browser
```

### 📓 Jupyter Notebook (Google Colab)
1. Go to [colab.research.google.com](https://colab.research.google.com)
2. Upload `notebooks/marketing_analysis.ipynb`
3. Upload the `data/` folder files
4. Run All Cells (`Runtime → Run all`)

### 🗄️ SQL Queries
```sql
-- Load CSV into PostgreSQL, then run in order:
\i sql/01_channel_performance.sql
\i sql/02_customer_journey.sql
\i sql/03_attribution_models.sql
\i sql/04_kpi_clv_analysis.sql
\i sql/05_budget_optimization.sql
```

---

## 🛠️ Tools Used

| Tool | Purpose |
|------|---------|
| **SQL (PostgreSQL)** | Data extraction, KPI calculations, attribution queries |
| **Python** | Data generation, analysis, attribution modeling |
| **Pandas / NumPy** | Data manipulation and computation |
| **Matplotlib / Seaborn** | Static charts and visualizations |
| **Chart.js** | Interactive dashboard charts |
| **HTML / CSS / JS** | Interactive browser-based dashboard |
| **Jupyter Notebook** | Analysis documentation |
| **GitHub** | Version control and portfolio |

---

## 📄 Methodology

See [`docs/methodology.md`](docs/methodology.md) for complete documentation of attribution logic, assumptions, KPI definitions, and model selection rationale.

---

## 💡 Recommendations

See [`docs/recommendations.md`](docs/recommendations.md) for the full business optimization strategy with projected revenue impact.

---

*Submitted for Grito Labs Marketing Analytics Challenge*  
*Timeline: Within 1 month of joining (Priority Evaluation)*

> *"Attribution is not just an analytics exercise — it is a budget allocation framework. Every dollar spent on marketing is a bet. Attribution tells you which bets are paying off."*
