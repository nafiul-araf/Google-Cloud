# **Marketing Campaign Optimization**  

This project aims to analyze and optimize marketing campaign strategies using **data extraction, transformation, and loading (ETL) techniques**. The dataset provides insights into campaign effectiveness, audience behavior, channel performance, and ROI.

## **Project Overview**  

This dataset contains marketing campaign data, including **conversion rates, ROI, audience engagement, and acquisition costs**. The project involves:  

✔ **Extracting** the dataset from Kaggle  
✔ **Transforming** the data (handling missing values, type conversion, cleaning, and feature engineering)  
✔ **Loading** the cleaned dataset into Google BigQuery for further analysis  

---

## **Dataset Overview**  

The dataset includes the following features:  

| Column Name          | Description |
|----------------------|-------------|
| **Company**         | Brand running the campaign |
| **Campaign_Type**   | Type of marketing campaign (email, social media, etc.) |
| **Target_Audience** | Demographics targeted |
| **Duration**        | Campaign length (days) |
| **Channels_Used**   | Platforms used (Google Ads, Social Media, etc.) |
| **Conversion_Rate** | Percentage of users taking action |
| **Acquisition_Cost** | Cost incurred to acquire customers |
| **ROI**            | Return on investment |
| **Location**       | Campaign region |
| **Language**       | Language used in campaign |
| **Clicks**        | Number of clicks on campaign |
| **Impressions**  | Number of times the campaign was displayed |
| **Engagement_Score** | Audience engagement score (1-10) |
| **Customer_Segment** | Targeted customer category |
| **Date**          | Campaign launch date |

---

## **Project Objectives**  

🔹 Perform **Exploratory Data Analysis (EDA)**  
🔹 Conduct **Hypothesis Testing** on Conversion Rates and ROI  
🔹 Build **Regression Models** to analyze key factors affecting performance  

---

## **1. Extract Data from Kaggle**  

We download the dataset using **Kaggle API**.  

```python
import kagglehub

# Download dataset
path = kagglehub.dataset_download("manishabhatt22/marketing-campaign-performance-dataset")

print("Path to dataset files:", path)
```

Confirm dataset files:  

```sh
ls /root/.cache/kagglehub/datasets/manishabhatt22/marketing-campaign-performance-dataset/versions/1
```

---

## **2. Explore & Transform Data**  

### **2.1 Load Required Libraries**
```python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

pd.set_option('display.max_columns', None)
```

### **2.2 Load Dataset**
```python
df = pd.read_csv('/root/.cache/kagglehub/datasets/manishabhatt22/marketing-campaign-performance-dataset/versions/1/marketing_campaign_dataset.csv')
df.head()
```

### **2.3 Check Data Properties**  
```python
df.shape  # Check rows & columns
df.isnull().sum()  # Count missing values
df.duplicated().sum()  # Count duplicates
df.dtypes  # Data types
```

### **2.4 Convert Data Types**  
```python
df['Date'] = pd.to_datetime(df['Date']).dt.normalize()  # Convert Date to datetime
```

### **2.5 Clean Data**  
```python
df['Duration'] = df['Duration'].str.replace(" days", '')  # Remove 'days' text  
df['Acquisition_Cost'] = df['Acquisition_Cost'].str.replace("$", '')  # Remove $ sign  
df['Acquisition_Cost'] = df['Acquisition_Cost'].str.replace(",", '')  # Remove commas  

# Rename Columns  
df.rename(columns={'Duration': 'Duration_Days', 'Acquisition_Cost': 'Acquisition_Cost_dollars'}, inplace=True)

# Convert Data Types  
df['Duration_Days'] = df['Duration_Days'].astype(int)  
df['Acquisition_Cost_dollars'] = df['Acquisition_Cost_dollars'].astype(float)  
```

### **2.6 Create New Features**  
```python
df['Year'] = df['Date'].dt.year  # Extract Year
df['Month'] = df['Date'].dt.month_name()  # Extract Month
```

---

## **3. Load Data to Google BigQuery**  

### **3.1 Import Required Libraries**
```python
from google.cloud import bigquery
from google.colab import auth
from pandas_gbq import to_gbq
```

### **3.2 Authenticate Google Cloud**
```python
auth.authenticate_user()

# Initialize BigQuery client
project_id = 'marketing-campaign-449808'
client = bigquery.Client(project=project_id, location='US')
```

### **3.3 Upload Data to BigQuery**
```python
database_name = 'campaign_data'

to_gbq(df, f'{database_name}.marketing_campaign_dataset', project_id=project_id, if_exists='replace')
```

**Successfully loaded dataset to BigQuery!**  

---

## **Next Steps: Data Analysis & Modeling**  

✔ Perform **EDA** using visualization libraries  
✔ Build **Hypothesis Testing** models  
✔ Implement **Regression Models** to analyze performance factors  

---
