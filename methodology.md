# 📘 Methodology & Attribution Logic
## Grito Labs | Marketing Analytics Framework

---

## 1. Data Assumptions

| Assumption | Rationale |
|-----------|-----------|
| 30-day lookback window | Industry standard for B2C conversion cycles |
| Direct traffic excluded | Not a marketing-driven touchpoint |
| One journey per purchase | Multiple purchases = multiple journeys |
| Revenue assigned at conversion only | Intermediate touchpoints carry $0 |
| Session timeout = 30 minutes | Standard analytics convention |

---

## 2. Attribution Models

### First-Touch
- **Formula:** 100% credit → first chronological touchpoint
- **Use:** Measuring awareness and acquisition channel value

### Last-Touch  
- **Formula:** 100% credit → last touchpoint before conversion
- **Use:** Evaluating retargeting and bottom-of-funnel campaigns
- **Limitation:** Undervalues awareness channels

### Linear
- **Formula:** `1 / total_touchpoints` credit per touchpoint
- **Use:** Balanced strategic budget planning (recommended for executives)

### Time-Decay
- **Formula:** `weight = e^(−0.1 × days_before_conversion)`
- **Use:** Short sales cycles; recent interactions weighted more heavily
- **Half-life:** ~7 days at λ=0.1

---

## 3. KPI Benchmarks

| KPI | Healthy Target |
|-----|---------------|
| ROAS | > 4x |
| CAC | < 20% of CLV |
| Email CTR | > 2.5% |
| Paid CTR | > 1% |
| CVR | 2–5% |
| CLV:CAC Ratio | > 3x |

---

## 4. Recommended Attribution for Grito Labs

| Decision | Model | Reason |
|----------|-------|--------|
| Strategic budget | Linear | No channel bias |
| Campaign optimization | Time-Decay | Recency matters |
| Awareness tracking | First-Touch | Top-of-funnel view |
| Closing analysis | Last-Touch | Bottom-of-funnel view |

---

*Grito Labs Marketing Analytics Challenge | v1.0*
