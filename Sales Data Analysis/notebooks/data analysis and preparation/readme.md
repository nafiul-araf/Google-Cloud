# Sales Data Analysis and Preparation

## Overview

This Jupyter Notebook demonstrates the process of loading, cleaning, analyzing, and preparing sales data. The primary aim is to explore relationships between various entities in the sales dataset and perform exploratory data analysis (EDA) with visualizations. The final dataset is then uploaded to Google BigQuery for storage and further use.

---

## **1. Data Loading**

This section loads the necessary data into the notebook from a Google Drive location.

### **Code Explanation**

```python
from google.colab import drive
drive.mount('/content/drive')

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

pd.set_option('display.max_columns', None)
```

- **What**: Mount Google Drive to access the dataset. Import required libraries (`numpy`, `pandas`, `matplotlib`, `seaborn`) for data manipulation and visualization.
- **Why**: Mounting Google Drive allows access to datasets stored remotely, while the libraries are essential for data analysis.

```python
# Load data from Excel sheets
customers = pd.read_excel('/content/drive/MyDrive/Google Cloud/Sales Data Analysis/Dataset/Sales.xlsx', sheet_name='Customers')
products = pd.read_excel('/content/drive/MyDrive/Google Cloud/Sales Data Analysis/Dataset/Sales.xlsx', sheet_name='Products')
regions = pd.read_excel('/content/drive/MyDrive/Google Cloud/Sales Data Analysis/Dataset/Sales.xlsx', sheet_name='Regions')
orders = pd.read_excel('/content/drive/MyDrive/Google Cloud/Sales Data Analysis/Dataset/Sales.xlsx', sheet_name='Sales Orders')
```

- **What**: Load the datasets for customers, products, regions, and sales orders from the provided Excel file.
- **Why**: These datasets contain the necessary information for further analysis and exploration.

---

## **2. Data Exploration and Joining**

Here, we explore the data by examining the structure of the datasets and merging them based on relevant indices.

### **Code Explanation**

```python
# Check the columns and data types of each dataset
customers.columns, products.columns, regions.columns, orders.columns
```

- **What**: List the columns in each dataset.
- **Why**: Helps in understanding the structure of each dataset and preparing for data merging.

```python
# Check data types of primary and foreign keys
(customers['Customer Index'].dtypes, orders['Customer Name Index'].dtypes), \
(products['Index'].dtypes, orders['Product Description Index'].dtypes), \
(regions['Index'].dtypes, orders['Delivery Region Index'].dtypes)
```

- **What**: Check the data types of key columns.
- **Why**: Ensures compatibility between primary and foreign keys for merging.

```python
# Merging orders with customers, products, and regions
orders_customers = orders.merge(customers, left_on='Customer Name Index', right_on='Customer Index', how='inner')
orders_customers_products = orders_customers.merge(products, left_on='Product Description Index', right_on='Index', how='inner')
sales = orders_customers_products.merge(regions, left_on='Delivery Region Index', right_on='Index', how='inner')
```

- **What**: Merge multiple dataframes (`orders`, `customers`, `products`, and `regions`) to create a unified `sales` dataframe.
- **Why**: Combines the necessary information from all entities to create a comprehensive sales dataset.

---

## **3. EDA and Feature Transformation**

This section focuses on exploratory data analysis (EDA), checking for missing values, duplicates, and performing feature transformations.

### **Code Explanation**

```python
# Summary statistics
stats_summary = sales.describe().transpose()
```

- **What**: Generate summary statistics for numerical columns in the `sales` dataframe.
- **Why**: Provides an overview of the distribution and central tendencies of the dataset.

```python
# Check for missing values
sales.isnull().sum()
```

- **What**: Count missing values in the dataset.
- **Why**: Identifies if there are any gaps in the data that require cleaning.

```python
# Check for duplicate records
sales.duplicated().sum()
```

- **What**: Detect duplicate rows in the data.
- **Why**: Ensures the integrity of the dataset by identifying redundant records.

```python
# Currency conversion to NZD
exchange_rates = {'NZD': 1.00, 'USD': 1.75, 'GBP': 2.21, 'EUR': 1.86, 'AUD': 1.12}
columns_to_convert = ['Unit Price', 'Total Unit Cost', 'Total Revenue']
for column in columns_to_convert:
    sales[column] = sales[column] * sales['Currency Code'].map(exchange_rates)
```

- **What**: Converts the `Unit Price`, `Total Unit Cost`, and `Total Revenue` columns to NZD based on the currency code.
- **Why**: Standardizes the financial values to a single currency for analysis.

```python
# Creating new columns for cost and profit
sales['Total Cost'] = np.round((sales['Order Quantity'] * sales['Total Unit Cost']), 2)
sales['Profit'] = np.round((sales['Total Revenue'] - sales['Total Cost']), 2)
```

- **What**: Creates new `Total Cost` and `Profit` columns based on existing data.
- **Why**: Essential for calculating the overall profitability of each sale.

---

## **4. Data Visualization and Insights**

Visualizations are used to explore relationships between variables, such as order quantity and profit, and trends over time.

### **Code Explanation**

```python
# Scatter plot: Quantity vs. Profit by Channel
sns.scatterplot(data=sales, x='Order Quantity', y='Profit', hue='Channel', alpha=0.7)
```

- **What**: Plot a scatter plot to visualize the relationship between order quantity and profit, colored by channel.
- **Why**: Helps identify patterns or trends in sales across different channels.

```python
# Line plot: Profit over Time by Channel
sns.lineplot(data=sales[sales['Channel'] == 'Wholesale'], x='OrderDate', y='Profit', ax=ax[0])
```

- **What**: Line plot showing profit trends over time for the 'Wholesale' channel.
- **Why**: Useful for understanding how profit fluctuates over time in different sales channels.

---

## **5. Storing Data on Google BigQuery**

This section demonstrates how to store processed data on Google BigQuery for cloud-based analysis and access.

### **Code Explanation**

```python
from google.cloud import bigquery
from google.colab import auth
auth.authenticate_user()
client = bigquery.Client(project='sales-data-analysis-449003', location='US')
```

- **What**: Authenticate Google Cloud account and initialize BigQuery client.
- **Why**: Required to interact with Google BigQuery for data uploading.

```python
from pandas_gbq import to_gbq

# Uploading dataframes to BigQuery
to_gbq(customers, 'transactional_data.customer_table', project_id=project_id, if_exists='replace')
to_gbq(products, 'transactional_data.product_table', project_id=project_id, if_exists='replace')
```

- **What**: Upload various dataframes (`customers`, `products`, `regions`, etc.) to Google BigQuery under the specified dataset.
- **Why**: Enables further analysis and querying of data in a cloud-based, scalable environment.

---

## **Conclusion**

This notebook demonstrates the process of loading, exploring, cleaning, analyzing, and storing sales data. It leverages various Python libraries like pandas, matplotlib, and seaborn for analysis and visualization. The cleaned data is then stored in Google BigQuery, making it accessible for further analysis or reporting.

--- 
