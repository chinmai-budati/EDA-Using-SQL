# End-to-End Retail Analytics & Pricing Strategy: Electronics E-Commerce

An automated SQL data engineering and advanced exploratory data analysis initiative that processes unstructured electronics retail records. It features dynamic non-destructive ETL pipelines, text-mining, and statistical variance modeling to expose competitive pricing elasticity, brand risk, and market penetration strategies.

**Interactive Portfolio Links**
*   **View the Full SQL Script:** [Insert Link to your revised_code.sql on GitHub]
*   **View the Interactive Dashboard:** [Insert Link to Power BI / Streamlit if applicable]

---

## 1. Project Overview

This project builds a robust data engineering and analytics solution for an electronics retail ecosystem. By extracting raw, messy text data and executing an objective, non-destructive cleaning pipeline using SQL Common Table Expressions (CTEs) and Views, the project prepares the data for advanced Exploratory Data Analysis (EDA). The clean schema feeds into custom stored procedures, window functions, and regular expressions to translate basic product listings into actionable business intelligence regarding brand tiering, discount effectiveness, and consumer engagement.

## 2. Purpose

In retail e-commerce, unstructured product data and arbitrary discount strategies often lead to inventory bottlenecks and reduced customer engagement. The purpose of this project is to model real-world retail anomalies and establish a data-driven pricing strategy. By standardizing basic text strings into an integrated analytical pipeline, a business can transition from static product listing evaluations to proactive, competitive market positioning.

## 3. Tech Stack

*   **Database & Engineering:** MySQL, SQL Server, Stored Procedures, Views, Triggers (used to simulate automated data ingestion and non-destructive transformations).
*   **Data Processing & Analytics:** Advanced SQL (CTEs, Window Functions, RegEx, mathematical modeling including standard deviation, covariance, and linear regression).
*   **Business Intelligence (Planned):** Power BI / Streamlit (to deploy automated, interactive market reports).

## 4. Data Architecture

The SQL pipeline models a comprehensive retail dataset, engineering multiple derived columns to unlock deeper analytical layers:
*   **Raw Data:** `Sub Category`, `Title`, `Price`, `Discount`, `Rating`, `Feature`
*   **Engineered Dimensional Data:** `Brand Name` (extracted via conditional logic), `Storage Capacity` (extracted via RegEx text mining)
*   **Engineered Fact Data:** `Cleaned Price` (decimal casting and string stripping), `MRP` (calculated via discount reverse-engineering), `Discount Type`, `Reviews` (proxy for engagement volume)

## 5. Features

**Business Problem**
Retail catalogs often suffer from inconsistent data entry, making it impossible to evaluate true market performance. Relying on simple averages creates visibility gaps, obscuring the impact of premium buzzwords, distinct brand strategies, and underlying quality control issues that damage consumer trust.

**Goal of the Project**
*   **Pipeline Rigor & Accuracy:** Clean and structure fragmented text strings using RegEx and robust `CASE WHEN` logic, completely standardizing pricing models and discount metrics without destroying the original raw data.
*   **Proactive Strategy Mitigation:** Isolate distinct consumer behaviors by replacing standard aggregations with statistical variance, engagement segmentation, and custom window functions to quantify competitive market dominance.

**Walkthrough of Key SQL Modules**
*   **Module 1: Non-Destructive ETL:** Creates a dynamic `VIEW` to cast data types, handle nulls, and standardize unstructured text into actionable categorical columns.
*   **Module 2: Market Penetration (Window Functions):** Utilizes `DENSE_RANK()` to map the top-performing brands across specific product sub-categories.
*   **Module 3: Feature Text Mining:** Uses `REGEXP_SUBSTR` to isolate technical specifications (like TB/GB storage) and marketing buzzwords (Smart, Wireless) to evaluate consumer elasticity.
*   **Module 4: Price Volatility (Coefficient of Variation):** Applies variance mathematics (`STD()` / `AVG()`) to distinguish between heavily tiered premium markets and rigid, commoditized hardware categories.
*   **Module 5: Brand Quality Control:** Leverages standard deviation on consumer ratings to identify reliable manufacturers versus highly polarizing, high-risk brands.

## 6. Business Impact & Insights

*   **Market Strategy Isolation:** Discovered that Apple demonstrates horizontal ecosystem dominance by securing top-tier engagement ranks across 7 distinct product verticals, whereas Samsung relies heavily on vertical saturation, concentrating its market power to capture 5 top-tier engagement spots strictly within the TVs category.
*   **Pricing Elasticity & Inventory Bottlenecks:** Segmenting product engagement revealed a strict inverse correlation between pricing and consumer interaction. Half of the catalog falls into the "Low/Niche" tier (averaging $1,134), indicating that premium pricing acts as a significant bottleneck. The optimal turnover sweet spot exists in the "Strong" engagement tier at $640–$730.
*   **Marketing Buzzword Valuation:** Text mining revealed that standard/unspecified electronics drive the highest average consumer engagement (530 reviews). Hardware heavily marketed with premium buzzwords like "Smart Enabled" or "Wireless" significantly underperforms (345 and 143 reviews, respectively), proving these tags do not inherently drive higher sales volume.
*   **Risk & Quality Control Visibility:** Standard deviation analysis exposed stark contrasts in quality control. Brands like Ring and Microsoft maintain perfect rating consistency (0.00 volatility), while security brands like SWANN and Lorex exhibit severe rating swings (>0.83 volatility) combined with the lowest average ratings, indicating defective batches that damage brand trust.

## 7. Dashboard Screenshot:
![Dashboard Preview](https://github.com/chinmai-budati/EDA-Using-SQL/blob/main/Electronics%20Ecommerce%20Dashboard.png)
