# **Marketing Campaign Data Analysis using BigQuery and Power BI**

This repository contains an **Exploratory Data Analysis (EDA)** of marketing campaign data stored in **Google BigQuery**. The goal is to analyze the impact of different marketing strategies on **Conversion Rate** and **Return on Investment (ROI)** across various customer segments. The results will be used for insights in **Power BI**.

## **Objectives**
- Assess the impact of different **marketing strategies** on **Conversion Rate** and **ROI**.
- Determine whether a **single strategy** works for all **customer segments**.
- Prepare aggregated data for further analysis in **Power BI**.

---

## **Setup & Requirements**
### **Libraries Used**
The following Python libraries are required:
```python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from google.cloud import bigquery
from google.colab import auth
from pandas_gbq import to_gbq
```
Ensure you have **Google Cloud SDK** and the **BigQuery API enabled** in your GCP project.

---

## **1. Reading Data from BigQuery**
### **Authenticate and Fetch Data**
```python
# Authenticate
auth.authenticate_user()

# Initialize BigQuery Client
project_id = 'marketing-campaign-449808'
client = bigquery.Client(project=project_id, location='US')

# Fetch dataset and table reference
dataset_ref = client.dataset(dataset_id='campaign_data', project=project_id)
dataset = client.get_dataset(dataset_ref=dataset_ref)
table_ref = dataset.table('marketing_campaign_dataset')
table = client.get_table(table_ref)

# Convert to Pandas DataFrame
df = client.list_rows(table=table).to_dataframe()
df.head()
```
✅ **Purpose**: Fetch marketing campaign data from **Google BigQuery** and store it as a Pandas DataFrame for analysis.

---

## **2. Exploratory Data Analysis (EDA)**

### **Check Data Shape**
```python
df.shape
```
✅ **Purpose**: Understand the size of the dataset.

### **Analyze Categorical Columns**
```python
# Count unique companies
print(f"Total number of companies: {df['Company'].nunique()}")

# Unique values and distributions for categorical columns
for col in df.select_dtypes(include=['object']).columns:
  print(f"Unique values in {col}: {df[col].nunique()}\nDistribution:\n{df[col].value_counts(normalize=True)}\n")
```
✅ **Purpose**: Identify categorical features and their distributions.

### **Analyze Numeric Columns**
```python
# Drop Campaign_ID
df.drop('Campaign_ID', axis=1, inplace=True)

# Plot boxplots for numeric columns
num_cols = df.select_dtypes(include=np.number).columns
fig, axes = plt.subplots(nrows=3, ncols=3, figsize=(20, 15))
axes = axes.flatten()

for i, col in enumerate(num_cols):
    sns.boxplot(data=df, y=col, ax=axes[i])
    axes[i].set_title(f"Distribution of {col}")

plt.suptitle(f"Distribution of Numeric Variables", fontsize=20)
plt.tight_layout()
plt.show()
```
✅ **Purpose**: Identify **outliers** and **distribution** of numerical variables.

### **Checking Year Column Issues**
```python
df['Year'].value_counts()
```
✅ **Purpose**: Identify anomalies in the **Year** column.

---

## **3. Data Aggregation & Summary**
```python
# Aggregate data by categorical columns and calculate mean for numerical columns
data_summary = df.groupby(
    ['Date', 'Company', 'Target_Audience', 'Location', 'Language', 'Customer_Segment', 'Campaign_Type', 'Channel_Used'])\
    [df.select_dtypes(include=np.number).columns].mean().round(3)

# Drop 'Year' column
data_summary.drop('Year', axis=1, inplace=True)
data_summary
```
✅ **Purpose**: Create **aggregated summaries** to be used in Power BI.

---

## **4. Marketing Strategy Impact Analysis**

### **Encoding Categorical Variables**
```python
df_encode = df.drop(['Date', 'Year', 'Month'], axis=1)
df_encode = pd.get_dummies(df_encode).astype(np.float64)
df_encode.head()
```
✅ **Purpose**: Convert categorical features into **numerical form** for correlation analysis.

---

## **5. Correlation Analysis**

### **Impact on Conversion Rate**
```python
# Compute correlation with Conversion Rate
correlation_analysis_cr = df_encode.corr()['Conversion_Rate'].reset_index()
correlation_analysis_cr.columns = ['Impacting_Variable', 'Impact']
correlation_analysis_cr = correlation_analysis_cr[correlation_analysis_cr['Impacting_Variable'] != 'Conversion_Rate']
correlation_analysis_cr.sort_values('Impact', ascending=False).style.background_gradient(cmap=sns.light_palette("green", as_cmap=True))
```
✅ **Purpose**: Identify **which marketing strategies impact conversion rates** the most.

### **Impact on ROI**
```python
# Compute correlation with ROI
correlation_analysis_roi = df_encode.corr()['ROI'].reset_index()
correlation_analysis_roi.columns = ['Impacting_Variable', 'Impact']
correlation_analysis_roi = correlation_analysis_roi[correlation_analysis_roi['Impacting_Variable'] != 'ROI']
correlation_analysis_roi.sort_values('Impact', ascending=False).style.background_gradient(cmap=sns.light_palette("green", as_cmap=True))
```
✅ **Purpose**: Identify **which marketing strategies drive ROI**.

---

## **6. Customer Segment-Specific Insights**
```python
df_encode_2 = df.drop(['Date', 'Year', 'Month'], axis=1)
categorical_cols = df_encode_2.select_dtypes(include=['object']).columns.tolist()
categorical_cols.remove('Customer_Segment')
df_encode_2 = pd.get_dummies(df_encode_2, columns=categorical_cols, dtype=np.float64)

# Correlation by Customer Segment (Conversion Rate)
correlation_analysis_cr_cs = df_encode_2.groupby('Customer_Segment').corr()['Conversion_Rate'].reset_index()
correlation_analysis_cr_cs = correlation_analysis_cr_cs[correlation_analysis_cr_cs['Impacting_Variable'] != 'Conversion_Rate']
correlation_analysis_cr_cs.style.background_gradient(cmap=sns.light_palette("green", as_cmap=True))
```
✅ **Purpose**: Assess **how marketing strategies impact different customer segments**.

### **Impact on ROI by Customer Segment**
```python
# Correlation by Customer Segment (ROI)
correlation_analysis_roi_cs = df_encode_2.groupby('Customer_Segment').corr()['ROI'].reset_index()
correlation_analysis_roi_cs = correlation_analysis_roi_cs[correlation_analysis_roi_cs['Impacting_Variable'] != 'ROI']
correlation_analysis_roi_cs.style.background_gradient(cmap=sns.light_palette("green", as_cmap=True))
```
✅ **Purpose**: Identify **ROI-driving factors for different customer segments**.

---

## **7. Writing Processed Data to BigQuery**
```python
database_name = 'campaign_data'

# Reset index before exporting
data_summary.reset_index(inplace=True)

# Export datasets to BigQuery
to_gbq(data_summary, f'{database_name}.summary_dataset', project_id=project_id, if_exists='replace')
to_gbq(df_encode, f'{database_name}.encoded_dataset', project_id=project_id, if_exists='replace')
to_gbq(correlation_analysis_cr, f'{database_name}.correlation_with_conversion', project_id=project_id, if_exists='replace')
to_gbq(correlation_analysis_roi, f'{database_name}.correlation_with_roi', project_id=project_id, if_exists='replace')
to_gbq(correlation_analysis_cr_cs, f'{database_name}.correlation_with_conversion_customer_seg', project_id=project_id, if_exists='replace')
to_gbq(correlation_analysis_roi_cs, f'{database_name}.correlation_with_roi_customer_seg', project_id=project_id, if_exists='replace')
```
✅ **Purpose**: Save processed data to **BigQuery** for further analysis in **Power BI**.

---

## **Conclusion**
- **Key marketing strategies** impacting **Conversion Rate** and **ROI** were identified.
- Different **customer segments** respond differently to marketing channels.
- Aggregated data is **stored in BigQuery** for **Power BI reporting**.

**Next Steps**: 
- Perform Regression Analysis
- Build interactive Power BI dashboards based on insights.

---
