# 🪙 Gold Layer Data Catalog

## 📘 Overview
The **Gold Layer** is the **business-level representation** of the data warehouse.  
It is **structured to support analytical and reporting use cases**, providing clean, consistent, and denormalized data models.

This layer consists of:
- **Dimension tables** (`dim_customers`, `dim_products`) – describe business entities such as customers and products.  
- **Fact tables** (`fact_sales`) – contain measurable business metrics such as revenue, sales quantity, and order details.

---

## 🧍‍♀️ 1. `gold.dim_customers`

### **Purpose**
The `gold.dim_customers` view provides a **unified customer dimension** by combining data from both CRM and ERP systems.  
It helps analyze customer demographics, behavior, and profile-based segmentation for business intelligence and reporting.

### **Table Definition**

| **Column Name**    | **Data Type** | **Description** |
|--------------------|---------------|-----------------|
| `customer_key`     | INT           | Surrogate key uniquely identifying each customer record in the data warehouse. |
| `customer_id`      | NVARCHAR(50)  | Unique numerical identifier assigned to each customer |
| `customer_num`     | NVARCHAR(50)  | Alphanumeric identifier assigned to customer for tracking and referencing |
| `first_name`       | NVARCHAR(50)  | Customer’s first name |
| `last_name`        | NVARCHAR(50)  | Customer’s last name |
| `country`          | NVARCHAR(50)  | Customer’s associated country or region(e.g., Australia, United States) |
| `marital_status`   | NVARCHAR(50)  | Customer’s marital status (e.g., Single, Married) |
| `gender`           | NVARCHAR(50)  | Gender of the customer (e.g., Female, Male)  |
| `birthdate`        | DATE          | Customer’s date of birth, formatted as YYYY-MM-DD (e.g., 1976-12-02) |
| `create_date`      | DATE          | Date and time the customer record was created in the system |

---

## 📦 2. `gold.dim_products`

### **Purpose**
The `gold.dim_products` view consolidates product-related data from CRM and ERP systems.  
It provides a single source of truth for product performance analysis, category insights, and lifecycle tracking.

### **Table Definition**

| **Column Name**    | **Data Type** | **Description** |
|--------------------|---------------|-----------------|
| `product_key`      | INT           | Surrogate key uniquely identifying each product record. |
| `product_id`       | INT           | Unique product identifier assigned for referencing and tracking |
| `product_number`   | NVARCHAR(50)  | A structured alphanumeric code assigned to products, often used in categorization/ inventory . |
| `product_name`     | NVARCHAR(50)  | Descriptive name of the product, including product name,colour and type|
| `category_id`      | NVARCHAR(50)  | Unique identifier for the product’s category, linking to its high level categorization |
| `category_name`    | NVARCHAR(50)  | Descriptive name of the product category. |
| `subcategory`      | NVARCHAR(50)  | More detailed classification of the product within the category. |
| `maintenance`      | NVARCHAR(50)  | Indicates if the product requires maintenance |
| `cost`             | INT           | Cost of production or acquisition of the product. |
| `product_line`     | NVARCHAR(50)  | Product line grouping used for internal classification or reporting. |
| `start_date`       | DATE          | The start date when the product became available for sales or use. |

---

## 💰 3. `gold.fact_sales`

### **Purpose**
The `gold.fact_sales` view represents the **Sales Fact Table**, capturing measurable transactional data such as order dates, revenue, and quantities.  
It links to dimension tables (`dim_customers`, `dim_products`) to enable multi-dimensional analysis like revenue trends, customer purchasing behavior, and product performance.

### **Table Definition**

| **Column Name**    | **Data Type** | **Description** |
|--------------------|---------------|-----------------|
| `order_number`     | NVARCHAR(50)  | Alphanumeric identifier for each sales order(e.g., SO43697) |
| `product_key`      | INT           | Foreign key referencing `gold.dim_products(product_key)`. |
| `customer_key`     | INT           | Foreign key referencing `gold.dim_customers(customer_key)`. |
| `order_date`       | DATE          | Date when the order was placed. |
| `shipping_date`    | DATE          | Date when the order was shipped. |
| `due_date`         | DATE          | Payment due date. |
| `sales_amount`     | INT           | Total monetary value of the line item, in whole currency unit(e.g., 3578) |
| `sales_quantity`   | INT           | Number of product units sold (e.g., 1 )|
| `price`            | INT           | Unit selling price of the product,in whole currency unit(e.g., 3578) |

---

### 🧾 Summary
| **Category**  | **View Name** | **Purpose** |
|---------------|---------------|-------------|
| Dimension     | `gold.dim_customers` | Provides unified customer data for profiling and segmentation. |
| Dimension     | `gold.dim_products` | Provides consolidated product data for performance and category insights. |
| Fact          | `gold.fact_sales` | Captures transactional sales data for analytics and reporting. |

---

