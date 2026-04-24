#  Highway Restaurant Opportunity Analysis
### SQL Business Intelligence Project | MySQL

---

## 📌 Business Question

> **Which highway around Chennai is the best opportunity to open a new restaurant  and what type of restaurant should it be?**

---

##  Database Schema

**Database:** `restaurant_analysis` | **Tables:** 5 | **Highways covered:** 8

```
highways (parent)
    ├── restaurants       → existing competition per highway
    ├── toll_traffic      → daily vehicle volume + peak hours
    ├── destinations      → cities/spots each highway leads to
    └── traveller_profile → % mix of traveller types per highway
```

| Table | Key Columns |
|---|---|
| `highways` | highway_id (PK), highway_name, route, direction_type, agv_distance_km |
| `restaurants` | restaurant_id (PK), highway_id (FK), restaurant_type (ENUM), restaurant_category (CHECK), rating, avg_price_for_two |
| `toll_traffic` | toll_id (PK), highway_id (FK), avg_daily_traffic, peak_hours |
| `destinations` | destination_id (PK), highway_id (FK), destination_name, destination_type |
| `traveller_profile` | highway_id (PK+FK), family_pct, tourist_pct, bikers_pct, workers_pct, commercial_pct |

---

##  Analysis — Two Phases

### Phase 1 — Univariate Analysis (`sql_script.sql`)
Exploring each table independently to understand patterns before combining data.

**Restaurants:** Count, avg rating, underserved highways, dominant/least-dominant category using RANK()

**Traffic:** Busiest/least busy highway, top 3 / bottom 3, above-average filter, High/Medium/Low segmentation, traffic score (5/3/1)

**Traveller Profile:** Dominant traveller type per highway using UNION ALL + RANK(), traveller spending score

**Destinations:** Dominant destination type using RANK(), destination demand score (Pilgrim/Tourist=5, Urban/Coastal=4, Industrial=3)

---

### Phase 2 — Profit Score Model (`sql_script_2.sql`)
Combined all 4 dimensions into one weighted profit score.

```
Final Profit Score =
  Traffic Score        × 0.35
+ Traveller Spending   × 0.25
+ Destination Demand   × 0.20
+ Competition Score    × 0.20
```

**Final Output — Top 3 Recommendations:**

| Highway | Profit Score | Dominant Traveller | Dominant Destination | Recommended Restaurant |
|---|---|---|---|---|
| NH-32 | 4.09 | Family | Pilgrim | Veg Family Restaurant |
| NH-332A | 3.59 | Tourist | Tourist | Non-Veg / Multi-Cuisine Restaurant |
| NH-48 | 3.57 | Commercial | Industrial | Budget Highway Diner |

---

##  SQL Concepts Used

`RANK() + PARTITION BY` · `CTE (WITH clause)` · `Subqueries` · `UNION ALL` · `Temporary Tables` · `CASE WHEN` · `GROUP BY + HAVING` · `Multi-table JOIN` · `Aggregate Functions` · `ENUM + CHECK Constraints`

---

##  How to Run

1. Open MySQL Workbench
2. Run `sql_script.sql` first - creates tables, inserts data, univariate analysis
3. Run `sql_script_2.sql` - profit score model and final recommendation

---

##  Files

```
sql_script.sql     → Schema + data + univariate analysis
sql_script_2.sql   → Profit score model + final recommendation
README.md          → Project documentation
```

---

Built this as part of my self-learning journey into SQL and data analysis.

**Vishvathara** | Aspiring Data Analyst  
 vishvaveeres@gmail.com · 🔗 www.linkedin.com/in/vishvathara-veereswaran
