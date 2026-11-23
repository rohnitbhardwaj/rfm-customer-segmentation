# RFM Customer Segmentation Analysis

**SQL Server · Python · Power BI**

📊 [View Dashboard Screenshots](images)

## Business Problem

Which customers drive the revenue, and which are slipping away? The goal is to help an online retailer segment its customers by buying behaviour and focus retention spend where it protects the most revenue.

## Dataset

Online Retail II transaction data (December 2009 to December 2011) from a UK-based online gift retailer: 5,881 identified customers generating about $17.4M in gross revenue.

[Dataset source -- UCI Machine Learning Repository](https://archive.ics.uci.edu/dataset/502/online+retail+ii)

## Methodology

1. **Data preparation (SQL):** Created the database and schema with scripts, then loaded the two yearly CSV sheets into raw staging tables with `BULK INSERT`.
2. **Consolidation and validation (SQL):** Combined both years with `UNION ALL` and converted dates (handling two date formats), quantity and price with `TRY_CONVERT`. Checked for failed conversions, missing customer IDs and descriptions, negative quantities and exact duplicates, then removed exact duplicates with `ROW_NUMBER()` to produce a cleaned table.
3. **Analysis (Python):** Removed rows without a customer ID and returns or cancellations (quantity of 0 or less), then calculated revenue per line. Set the snapshot date to 2011-12-10, the day after the last invoice. Calculated Recency, Frequency and Monetary per customer, scored each from 1 to 5 using quintiles and assigned six rule-based segments (Champions, Loyal, At Risk, New, Require Attention, Lost). Flagged customers as churned after 90 days without a purchase.
4. **Visualization (Power BI):** Two-page dashboard with slicers for year, quarter, month, country, segment and churn status: a business overview (revenue, customers, average customer value, churn %, revenue by segment and period) and an RFM analysis (country performance and churn trends).

## Key Findings

* **Overall:** 5,881 customers generated $17.4M, and 50.9% of them have not bought in 90+ days. That churned group accounts for only 19.5% of revenue ($3.4M).
* **Concentration:** Champions are 22% of customers (1,291) but generate 68% of revenue ($11.8M). The top 10% of customers bring in 64% of revenue.
* **At Risk:** 821 customers (14%) with about 5 orders each have been inactive for roughly a year on average. They spent $1.59M in total.
* **Slipping Loyal customers:** 446 of 1,416 Loyal customers have already passed the 90-day mark, with $1.05M in combined spend.
* **Lost:** 26% of customers but only 3.8% of revenue.
* **Seasonality and growth:** Q4 brings 35.5% of revenue. Revenue was flat year on year ($8.4M in 2010 vs $8.3M in 2011).
* **Market:** The UK provides 83% of revenue and 5,353 of 5,881 customers.

## Business Impact

* Every 1% of Champion spend lost is about $118K, so losing 5% would cost roughly $590K.
* Winning back 10% of At Risk customers (about 82 people) recovers an estimated $159K at their past spend.
* Acting on slipping Loyal customers early protects up to $1.05M of customer history before they become At Risk.
* Lost customers are a quarter of the base but under 4% of revenue, so broad campaigns to them are not worth the cost.

## Recommendations

* Protect Champions with account-style care for the top 50-100 customers: early access to Q4 ranges, volume pricing and a named contact.
* Trigger a reminder or offer at 60-75 days of inactivity for Loyal customers, before they cross 90 days.
* Run one targeted win-back campaign for At Risk customers using their past favourite products, and pilot it on 10% first.
* Push a second purchase within 30 days of a New customer's first order.
* Keep spend on Lost customers to low-cost automated emails.

## Limitations

* The 90-day churn rule is an assumption, and it overlaps heavily with At Risk and Lost by design.
* Returns and cancellations are excluded (about 6% of gross sales, roughly $1.08M), so revenue is gross, not net.
* Revenue impact figures are illustrative estimates at historical spend. They assume a recovery rate and do not account for margin or campaign cost.
* A few very large accounts skew the Champions average (mean $9,169 vs median $3,942).
* Country averages rest on very few customers in some markets (for example, 5 in EIRE).
* 2009 covers December only and 2011 runs to December 9, so year comparisons are partial.
* Scores are quintile-based, so segments are relative to this customer base.
* The data shows what customers did, not why they stopped buying.

## Project Files

* `sql/`: database setup and loading (`01_create_and_load.sql`) and consolidation, validation and deduplication (`02_data_consolidation_&_validation.sql`)
* `python/`: RFM scoring, segmentation and export for the dashboard
* `rfm_analysis_dashboard.pbix`: Power BI dashboard file
* `images/`: dashboard screenshots
