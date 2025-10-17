# Naming Conventions Guide

This document defines the naming standards for database objects, columns, and procedures across all layers of the data warehouse. Consistent naming improves clarity, maintainability, and collaboration.

---

## 1. General Principles

- **Naming Style**: Use `snake_case` — lowercase letters with underscores (`_`) to separate words.
- **Language**: Use English for all names.
- **Avoid Reserved Words**: Do not use SQL reserved keywords as object names.

---

## 2. Table Naming Conventions

### 🔹 Bronze Layer

- **Pattern**: `sourcesystem_entity`
- **Rules**:
  - Table names must start with the source system name (e.g., `crm`, `erp`).
  - Table names must match the original file name without renaming.
- **Example**: `crm_cust_info` → Customer information extracted from CRM.

### 🔹 Silver Layer

- **Pattern**: `sourcesystem_entity`
- **Rules**:
  - Same as Bronze: start with source system name and match original file name.
- **Example**: `erp_sales_data` → Sales data extracted from ERP.

### 🔹 Gold Layer

- **Pattern**: `category_entity`
- **Rules**:
  - Names must be meaningful, user-friendly, and business-aligned.
  - Prefix with `dim_` for dimension tables and `fact_` for fact tables.
- **Examples**:
  - `dim_customers`
  - `dim_products`
  - `fact_sales`

---

## 3. Glossary of Category Prefixes

| Prefix     | Meaning           | Examples                     |
|------------|-------------------|------------------------------|
| `dim_`     | Dimension table    | `dim_customers`, `dim_products` |
| `fact_`    | Fact table         | `fact_sales`                 |
| `report_`  | Reporting table    | `report_customers`           |

---

## 4. Column Naming Conventions

### Surrogate Keys

- **Pattern**: `tablename_key`
- **Definition**:
  - `tablename`: Refers to the entity the key belongs to.
  - `key`: Suffix indicating it's a primary key.
- **Example**: `customers_key` → Primary key of the `customers` table.

### Technical Columns

- **Pattern**: `dwh_<column_name>`
- **Definition**:
  - `dwh`: Prefix for system-generated metadata.
  - `<column_name>`: Descriptive name of the column’s purpose.
- **Example**: `dwh_load_date` → Date when the record was loaded into the warehouse.

---

## 5. Stored Procedure Naming

- **Pattern**: `load_<layer>`
- **Definition**:
  - `<layer>`: Indicates the data warehouse layer (`bronze`, `silver`, `gold`).
- **Examples**:
  - `load_bronze` → Procedure for loading Bronze layer data.
  - `load_silver` → Procedure for loading Silver layer data.
