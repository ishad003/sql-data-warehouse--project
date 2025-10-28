## Project Overview
This project involves designing and implementing a **modern data warehouse** using **SQL Server**, following the **medallion architecture** (Bronze, Silver, Gold layers).

The warehouse consolidates sales data from multiple sources to enable **analytical reporting** and **informed decision-making**.

**Key Features:**
- **Data Architecture:** Robust design using medallion layers  
- **ETL Pipelines:** Extract, transform, and load data from source CSV files  
- **Data Modeling:** Fact and dimension tables optimized for analytics  
- **Analytics & Reporting:** SQL-based reports for actionable insights  

---

## Objectives
- Consolidate sales data from ERP and CRM systems  
- Enable analysis of **customer behavior**, **product info**, and **sales trends**  
- Deliver a **user-friendly data model** for business stakeholders and analytics teams  

---

## Specifications
- **Data Sources:** Two CSV files from ERP and CRM systems  
- **Data Quality:** Cleanse and resolve data issues prior to analysis  
- **Integration:** Combine both sources into a single analytical model  
- **Scope:** Latest dataset only; no historical data required  
- **Documentation:** Clear explanation of the data model for stakeholders and analysts  

---

## Data Architecture
Follows the **Medallion Architecture**:  
<img width="3231" height="1661" alt="Architecture drawio (1)" src="https://github.com/user-attachments/assets/f27ae974-66a0-43fd-a75d-5292bc1d22ac" />


- **Bronze Layer:** Raw ingestion of source data  
- **Silver Layer:** Cleansed and transformed data  
- **Gold Layer:** Analytical models optimized for reporting  

---

##**Repository Structure**
```text
├── **dataset/** # Raw datasets used for the project
├── **docs/** # Documentation of data architecture, data catalog, and data flow
├── **data_model/** # Fact and dimension tables naming conventions
├── **scripts/** # SQL scripts for ETL and transformations
│   ├── **bronze/** # Scripts for extracting and loading raw data
│   ├── **silver/** # Scripts for cleaning and transforming data
│   └── **gold/** # Scripts for creating analytical models
├── **tests/** # Test scripts and data quality files
├── **README.md** # Project overview and structure
├── **requirements.txt** # Project dependencies
└── **LICENSE** # MIT License



