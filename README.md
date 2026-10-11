# E-Commerce Supply Chain & Fulfillment Analytics Pipeline

## Project Overview
This project builds a comprehensive, end-to-end data pipeline and business intelligence reporting system using the **Olist Brazilian E-Commerce Public Dataset** (~100k orders). 

Using **SQL**, raw multi-table relational records were cleaned, transformed, and modeled into optimized operational datasets. The insights were then visualized using **Tableau** to monitor logistics fulfillment, regional delivery bottlenecks, and supplier risk.

---

## Project Architecture
```text
├── 01_raw_data/              # Raw data schema references & source documentation
├── 02_scripts_code/          # SQL scripts for data cleaning, transformations & aggregations
├── 03_processed_data/        # 4 clean operational datasets (Demand, Inventory, OTIF, Seller)
└── 04_dashboards_outputs/    # Tableau interactive dashboard snapshots & exports
