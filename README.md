# 🛠 Shiny Business Dashboard

## 🎯 Objective
Create a sleek, interactive Shiny dashboard for business analysis. The app will track sales performance, customer behavior, and geographic trends using real-world retail data.

---

## 📊 Dataset: Online Retail Transactions
We're working with the **Online Retail Dataset** from UCI, which includes transactional data from a UK-based online store (2010–2011).

### 🔍 Key Fields:
- **InvoiceNo** – Transaction ID
- **StockCode** – Product code
- **Description** – Product name
- **Quantity** – Number of items purchased
- **InvoiceDate** – Purchase date
- **UnitPrice** – Price per item
- **CustomerID** – Unique customer identifier
- **Country** – Country of transaction

---

## 💡 Business Application
The dashboard will help the company:
✅ Analyze **sales trends** over time
✅ Understand **customer behavior**
✅ Identify **top-selling products**
✅ Visualize **geographic sales distribution**
✅ Review **transaction details**

---

## 📂 Step 1: Data Preparation

### 1️⃣ Get & Store the Data
1. **Download** the Online Retail dataset
2. Save it as `online_retail.csv`
3. Store it in the `/data/` folder in the repository

### 2️⃣ Import & Clean
Using the `rio` package for easy import:
```r
library(rio)
data <- import("data/online_retail.csv")
```
Basic cleanup:
```r
library(dplyr)
data <- data %>%
  filter(!is.na(CustomerID)) %>%  # Remove missing Customer IDs
  mutate(Revenue = Quantity * UnitPrice)  # Add Revenue column
```

---

## 📊 Step 2: Visualizations
Each person builds their own **Shiny app** with these key visualizations:

### 📈 **Sales Trends (Plotly)**
- **What?** Interactive revenue trend over time
- **How?**
  - Line chart: **Revenue vs. InvoiceDate**
  - Zoom, tooltips, and country filter
  - Use **plotly**

### 📊 **Top Products (Highcharter)**
- **What?** Stacked bar chart of best-selling products
- **How?**
  - Compare **quantity sold per product**
  - Use **highcharter**

### 🌍 **Sales by Country (Leaflet)**
- **What?** Sales mapped per country
- **How?**
  - Interactive map with total sales per country
  - Add country coordinates manually
  - Use **leaflet**

### 📋 **Transaction Table (DT)**
- **What?** Interactive table of all sales transactions
- **How?**
  - Sorting, searching, pagination
  - Use **DT**

### 🏆 **Customer Insights (Reactable)**
- **What?** Table of top customers
- **How?**
  - Conditional formatting for high-value customers
  - Sorting, filtering, and styling
  - Use **reactable**

---

## 🚀 Step 3: Final App Assembly
Bringing everything together into one **Shiny app**:
✅ **Professional UI** (bslib or other frameworks)
✅ **Interactive elements** (`reactive()`, `observe()`, etc.)
✅ **User-friendly layout** (sidebars, navigation, panels)

---

## 📂 Step 4: GitHub Repository

### 📁 Folder Structure
```
/business_dashboard
├── app.R                   # Main Shiny script
├── data/                   # Dataset folder
│   ├── online_retail_2009-2010.csv  
│   ├── online_retail_2010-2011.csv 
├── README.md               # Documentation
```
🔗 **Final step:** Submit the GitHub repo link.

---

## 🎤 Presentation & Discussion
Each participant presents (~5 min) covering:
- What they built
- Challenges faced
- Business applications

🎯 Goal: A **polished, insightful, and interactive Shiny dashboard!** 🚀

