# Bank Subscription Analysis SQL Script in BigQuery

This SQL script analyzes a bank marketing campaign dataset to derive insights into client subscriptions, demographic trends, financial indicators, and campaign effectiveness. It is divided into the following sections:

[View The Dashboard](https://nafiul-araf.github.io/Google-Cloud/Bank%20Subscription%20Analysis/)

## Table of Contents

1. [Explore Data](#1-explore-data)
2. [Basic Data Cleaning](#2-basic-data-cleaning)
3. [Data Analysis](#3-data-analysis)  
   3.1 [Basic Summary](#31-basic-summary)  
   3.2 [Demographics Analysis](#32-demographics-analysis)  
   3.3 [Financial Indicators](#33-financial-indicators)  
   3.4 [Campaign Effectiveness](#34-campaign-effectiveness)  
   3.5 [Time and Subscription Trends](#35-time-and-subscription-trends)  
4. [Combine Key Insights](#4-combine-key-insights)

---

## 1. Explore Data

### Purpose
To get an overview of the dataset, including record count and distinct values of key fields.

### SQL Queries
```sql
SELECT * FROM `bank-subscription-analysis.campaign_data.bank_full`;

SELECT DISTINCT y FROM `bank-subscription-analysis.campaign_data.bank_full`;

SELECT COUNT(*) FROM `bank-subscription-analysis.campaign_data.bank_full`;
```

---

## 2. Basic Data Cleaning

### Purpose
- Identify and remove unwanted data values.
- Check for negative balances, clean the data, and remove invalid records.

### Cleaning Steps
1. **Check Value Ranges**:
    ```sql
    SELECT MAX(balance), MIN(balance), MAX(age), MIN(age), MAX(day), MIN(day), 
           MAX(duration), MIN(duration), MAX(campaign), MIN(campaign), 
           MAX(pdays), MIN(pdays), MAX(previous), MIN(previous)
    FROM `bank-subscription-analysis.campaign_data.bank_full`;
    ```

2. **Check for Unwanted Categories**:
    ```sql
    SELECT DISTINCT job FROM `bank-subscription-analysis.campaign_data.bank_full`;
    SELECT DISTINCT marital FROM `bank-subscription-analysis.campaign_data.bank_full`;
    SELECT DISTINCT education FROM `bank-subscription-analysis.campaign_data.bank_full`;
    -- (Repeat for all categorical fields)
    ```

3. **Remove Negative Balances**:
    ```sql
    CREATE OR REPLACE VIEW `bank-subscription-analysis.campaign_data.bank_final` AS
    SELECT * FROM `bank-subscription-analysis.campaign_data.bank_full`
    WHERE balance >= 0;
    ```

---

## 3. Data Analysis

### 3.1 Basic Summary

#### Purpose
Provide an overview of subscription rates and target availability.

#### SQL Query
```sql
CREATE OR REPLACE VIEW `bank-subscription-analysis.campaign_data.basic_summary` AS
SELECT COUNT(*) AS total_records,
       COUNTIF(y = TRUE) AS subscribed, 
       COUNTIF(y = FALSE) AS unsubscribed, 
       COUNTIF(y IS NULL) AS missing_target,
       ROUND(COUNTIF(y = TRUE) / COUNT(*), 4) AS subscription_ratio
FROM `bank-subscription-analysis.campaign_data.bank_final`;

SELECT * FROM `campaign_data.basic_summary`;
```

---

### 3.2 Demographics Analysis

#### Purpose
Analyze subscription trends by age groups and job categories.

#### SQL Query
```sql
CREATE OR REPLACE VIEW `bank-subscription-analysis.campaign_data.demographic_summary` AS
SELECT  
       CASE WHEN age < 25 THEN "-25" 
            WHEN age BETWEEN 25 AND 34 THEN "25-34" 
            WHEN age BETWEEN 35 AND 44 THEN "35-44" 
            WHEN age BETWEEN 45 AND 54 THEN "45-54"
       ELSE "55+" END AS age_group, 
       job,
       COUNT(*) AS total_records, 
       ROUND(COUNTIF(y = TRUE) / COUNT(*), 4) AS subscription_ratio
FROM `bank-subscription-analysis.campaign_data.bank_final`
GROUP BY age_group, job
ORDER BY age_group;
```

---

### 3.3 Financial Indicators

#### Purpose
Analyze financial characteristics such as account balances and their impact on subscriptions.

#### SQL Query
```sql
CREATE OR REPLACE VIEW `bank-subscription-analysis.campaign_data.financial_summary` AS
SELECT  
       CASE WHEN balance < 20000 THEN "0-20K" 
            WHEN balance BETWEEN 20001 AND 40000 THEN "20K-40K" 
            WHEN balance BETWEEN 40001 AND 60000 THEN "40K-60K"
            WHEN balance BETWEEN 60001 AND 80000 THEN "60K-80K"
            WHEN balance BETWEEN 80001 AND 100000 THEN "80K-100K"
       ELSE "100K+" END AS balance_group, 
       job,
       COUNT(*) AS total_clients, 
       ROUND(COUNTIF(y = TRUE) / COUNT(*), 4) AS subscription_ratio
FROM `bank-subscription-analysis.campaign_data.bank_final`
GROUP BY balance_group, job
ORDER BY balance_group;
```

---

### 3.4 Campaign Effectiveness

#### Purpose
Evaluate the effectiveness of campaign efforts before and after client interactions.

#### Before Campaign Analysis
```sql
CREATE OR REPLACE VIEW `bank-subscription-analysis.campaign_data.before_campaign_summary` AS
SELECT previous,  
       COUNT(*) AS total_clients, 
       ROUND(COUNTIF(y = TRUE) / COUNT(*), 4) AS subscription_ratio
FROM `bank-subscription-analysis.campaign_data.bank_final`
GROUP BY previous
ORDER BY previous;
```

#### After Campaign Analysis
```sql
CREATE OR REPLACE VIEW `bank-subscription-analysis.campaign_data.campaign_summary` AS
SELECT campaign, 
       CASE WHEN duration < 60 THEN "<1 minute" 
            WHEN duration BETWEEN 60 AND 180 THEN "1-3 minutes" 
            WHEN duration BETWEEN 180 AND 360 THEN "3-6 minutes" 
            WHEN duration BETWEEN 360 AND 600 THEN "6-10 minutes"
       ELSE ">10 minutes" END AS duration_group, 
       COUNT(*) AS total_contacts, 
       ROUND(COUNTIF(y = TRUE) / COUNT(*), 4) AS subscription_ratio
FROM `bank-subscription-analysis.campaign_data.bank_final`
GROUP BY campaign, duration_group
ORDER BY campaign;
```

---

### 3.5 Time and Subscription Trends

#### Purpose
Explore trends based on month and day.

#### SQL Query
```sql
CREATE OR REPLACE VIEW `bank-subscription-analysis.campaign_data.trend_summary` AS
SELECT month,
       day,
       COUNT(*) AS total_contacts, 
       ROUND(COUNTIF(y = TRUE) / COUNT(*), 4) AS subscription_ratio
FROM `bank-subscription-analysis.campaign_data.bank_final`
GROUP BY month, day
ORDER BY CASE month WHEN 'jan' THEN 1
                    WHEN 'feb' THEN 2
                    -- (Repeat for other months)
                    END,
         day;
```

---

## 4. Combine Key Insights

#### Purpose
Integrate demographics, financial data, and campaign analysis into a single view.

#### SQL Query
```sql
CREATE OR REPLACE VIEW `bank-subscription-analysis.campaign_data.combined_summary` AS
SELECT campaign, 
       job, 
       CASE WHEN age < 25 THEN "-25" 
            WHEN age BETWEEN 25 AND 34 THEN "25-34" 
            WHEN age BETWEEN 35 AND 44 THEN "35-44" 
            WHEN age BETWEEN 45 AND 54 THEN "45-54"
       ELSE "55+" END AS age_group, 

       CASE WHEN balance < 20000 THEN "0-20K" 
            WHEN balance BETWEEN 20001 AND 40000 THEN "20K-40K" 
            -- (Continue for other ranges)
       END AS balance_group,

       CASE WHEN duration < 60 THEN "<1 minute" 
            -- (Continue for other duration ranges)
       END AS duration_group,

       COUNT(*) AS total_records,
       COUNTIF(y = TRUE) AS subscribed, 
       ROUND(COUNTIF(y = TRUE) / COUNT(*), 4) AS subscription_ratio
FROM `bank-subscription-analysis.campaign_data.bank_final`
GROUP BY campaign, job, age_group, balance_group, duration_group;
```
---

# **BigQuery Integration and Predictive Modeling for Bank Campaign Analysis**  

This repository demonstrates how to use Python to connect to BigQuery, preprocess campaign data, and build machine learning models using PyCaret. Below is a step-by-step breakdown of the code and its functionality.

---

## **1. Connect to BigQuery**  

### **1.1 Libraries Needed**  
```python
from google.cloud import bigquery
from google.colab import auth
```
Import libraries to authenticate with Google Cloud and interact with BigQuery datasets.  

### **1.2 Authenticate and Initialize BigQuery Client**  
```python
auth.authenticate_user()
project_id = "bank-subscription-analysis"
client = bigquery.Client(project=project_id, location="US")
```
- `auth.authenticate_user()` authenticates the user in Colab.  
- `bigquery.Client` initializes a client to access BigQuery datasets for the specified project (`bank-subscription-analysis`).  

### **1.3 Access Datasets and Tables**  
```python
dataset_ref = client.dataset(dataset_id="campaign_data", project=project_id)
bank_table_ref = dataset.table("bank")
bank_table = client.get_table(bank_table_ref)
```
The dataset `campaign_data` is referenced, and the `bank` table is retrieved for analysis.  

### **1.4 Querying a BigQuery View**  
```python
query = f"SELECT * FROM `{project_id}.campaign_data.bank_final`"
query_job = client.query(query)
df = query_job.to_dataframe()
df.head()
```
Data from the BigQuery view `bank_final` is queried and loaded into a Pandas DataFrame.  

---

## **2. Data Preprocessing**  

### **2.1 Checking the Data**  
```python
df.shape
df[df['pdays'] < 0].shape[0]  # Count rows where 'pdays' is -1 (client not contacted)
df.duplicated().sum()         # Check for duplicate records
```
Initial exploration of the data includes checking shape, duplicate rows, and specific column conditions like negative values in `pdays`.  

### **2.2 Data Cleaning**  
```python
df_evaluation = df_evaluation[df_evaluation['balance'] >= 0]
df_evaluation = df_evaluation.reset_index(drop=True)
```
Ensures no negative values exist in the `balance` column and resets the index for consistency.  

### **2.3 Type Conversion**  
```python
def simple_preprocess(data):
  for col in list(data.select_dtypes(include=['object']).columns):
    data[col] = data[col].astype('category')
  for col in list(data.select_dtypes(include=['boolean']).columns):
    data[col] = data[col].astype(int)
  return data

df = simple_preprocess(data=df)
```
Converts `object` type columns to `category` and `boolean` columns to integers for better model handling.  

---

## **3. Build and Train Models**  

### **3.1 Install PyCaret**  
```python
!pip install pycaret
```
Install the PyCaret library for simplified machine learning workflows.  

### **3.2 Handle Imbalance and Preprocess**  
#### **Without Handling Imbalance**  
```python
setup_no_imbalance = setup(df, target='y', session_id=123, ...)
best_model_no_imbalance = compare_models()
```
Defines preprocessing steps for the dataset and compares models without applying imbalance handling techniques.  

#### **With Oversampling**  
```python
setup_oversampling = setup(df, target='y', fix_imbalance=True, ...)
best_model_oversampling = compare_models()
```
Applies oversampling (e.g., SMOTE) to balance the classes before comparing models.  

#### **With Undersampling**  
```python
from imblearn.under_sampling import RandomUnderSampler
setup_undersampling = setup(df, target='y', fix_imbalance_method=RandomUnderSampler(), ...)
best_model_undersampling = compare_models()
```
Uses undersampling to reduce the majority class size, balancing the dataset.  

---

## **4. Model Evaluation**  

### **4.1 Confusion Matrix**  
```python
from sklearn.metrics import confusion_matrix
sns.heatmap(cm, annot=True, fmt='g', cmap='Blues', ...)
```
Plots the confusion matrix for model evaluation to visualize predictions against actual values.  

### **4.2 Feature Importance**  
```python
plot_model(best_model_oversampling, plot='feature')
```
Plots the most important features influencing predictions in the model.  

---

## **5. Writing Data Back to BigQuery**  

### **5.1 Save Predictions**  
```python
new_predictions.to_gbq('campaign_data.bank_predictions', project_id, ...)
```
Writes the model predictions back to BigQuery for further analysis.  

### **5.2 Save Feature Importance Table**  
```python
feature_table.to_gbq('campaign_data.feature_table', project_id, ...)
```
Saves the feature importance scores to BigQuery for record-keeping and future analysis.  

---

## **6. Key Findings and Recommendations**  

- **Class Imbalance**: Significant class imbalance in the target variable requires techniques like SMOTE.  
- **Top Features**: `job`, `balance`, and `education` emerged as critical predictors for subscription likelihood.  
- **Recommended Model**: LightGBM with SMOTE demonstrated the best performance, achieving 88.55% accuracy and 0.7932 AUC.  

---

Here’s how the updated GitHub-style documentation could look with the inclusion of Power BI integration and visualization details:

---

# Bank Subscription Analysis and Predictive Visualization in Power BI

This project analyzes a bank marketing campaign dataset and visualizes key insights using **BigQuery** and **Power BI**. It includes SQL-based data analysis and a two-page interactive Power BI report.

---

## Table of Contents

## Power BI Dashboard

### Overview

The Power BI dashboard is designed to visualize the SQL query outputs and include predictive analysis based on additional machine learning results. The dashboard is split into two pages:

### Page 1: Insights and Trends

#### Features:
- **Summary Statistics**: Displays total records, subscribed, unsubscribed, and subscription ratio.
- **Demographics Analysis**: Shows subscription trends by age group and job category.
- **Financial Indicators**: Visualizes the subscription ratio across balance groups and job types.
- **Campaign Effectiveness**: Visualizes subscription success based on call duration and previous campaign interactions.
- **Time Trends**: Displays subscription trends by month and day.

#### Example Visuals:
- **Bar Chart**: Subscription ratio by job and age group.
- **Pie Chart**: Overall subscription status (subscribed vs. unsubscribed).
- **Line Chart**: Subscription trends across months.
- **Heat Map**: Subscription trends across days of the month.

---

### Page 2: Predictive Analysis

#### Features:
This page is dedicated to predictive analysis using machine learning outputs from the `bank_prediction` and `feature_table` datasets.

- **Dataset**: 
  - **`bank_prediction`**: Contains predicted subscription probabilities for each client.
  - **`feature_table`**: Contains feature importance scores from the ML model.

#### Example Visuals:
- **Scatter Plot**: Predicted subscription probability vs. actual outcomes.
- **Feature Importance Chart**: Highlights the key predictors influencing the subscription outcome.
- **Gauge Chart**: Displays the overall model accuracy or AUC score.

#### Use Cases:
- Identify high-probability clients for targeted marketing.
- Understand which features (e.g., balance, age, campaign interaction) have the most impact on subscription likelihood.

---

## BigQuery and Power BI Connection

### Setup Process:
1. **Enable BigQuery API**:
   - Ensure that the BigQuery API is enabled in the Google Cloud Console.
   
2. **Connect Power BI to BigQuery**:
   - In Power BI, choose **Get Data** > **Google BigQuery**.
   - Authenticate using Google credentials.
   - Select the appropriate project and dataset.

3. **Import SQL Views**:
   - Import the SQL views (e.g., `basic_summary`, `demographic_summary`, `financial_summary`) etc created in the SQL script.
   - Use DirectQuery for real-time updates or Import Mode for faster performance.

4. **Data Modeling**:
   - Establish relationships between imported tables/views in Power BI.
   - Use calculated columns and measures for additional transformations if required.

---
