# **Hypothesis Test and Regression Analysis**

## **Overview**
This project performs statistical and regression analyses to answer the following questions:

- How significantly do **Conversion Rate** and **Return on Investment (ROI)** differ across different **marketing strategies**?
- Which factors contribute the most to **Conversion Rate** and **ROI**?
- How strongly do different variables influence **Conversion Rate** and **ROI**?

The analysis is conducted using Python, Google BigQuery, and various statistical libraries.

---

## **1. Data Extraction from BigQuery**
The dataset is stored in **Google BigQuery**, and we retrieve it using the `google.cloud.bigquery` library.

### **Setup and Authentication**
```python
# Import necessary libraries
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

import warnings
warnings.filterwarnings('ignore')

pd.set_option('display.max_columns', None)

from google.cloud import bigquery
from google.colab import auth

# Authenticate the user
auth.authenticate_user()

# Initialize the BigQuery client
project_id = 'marketing-campaign-449808'
client = bigquery.Client(project=project_id, location='US')

# Retrieve dataset
dataset_ref = client.dataset(dataset_id='campaign_data', project=project_id)
dataset = client.get_dataset(dataset_ref=dataset_ref)

# Get the main table
main_table_ref = dataset.table('marketing_campaign_dataset')
main_table = client.get_table(main_table_ref)

# Convert to Pandas DataFrame
df = client.list_rows(main_table).to_dataframe()

# Display the first few rows
df.head()
```

---

## **2. Hypothesis Testing**

### **2.1 Required Libraries**
```python
from scipy import stats
from statsmodels.stats.oneway import anova_oneway
from statsmodels.stats.multicomp import pairwise_tukeyhsd
import scikit_posthocs as sp
```

---

## **3. Statistical Tests**

### **3.1 Normality Test**
This function checks if data follows a normal distribution using **Shapiro-Wilk** or **Kolmogorov-Smirnov (KS) test**.
```python
def normality_check(*data_groups, alpha=0.05, group_names=None, test_type="shapiro"):
    if group_names is None:
        group_names = [f"Group {i+1}" for i in range(len(data_groups))]

    results = []
    for i, data in enumerate(data_groups):
        if len(data) > 5000 and test_type == "shapiro":
            print(f"Warning: Large sample size for {group_names[i]}. Consider using the KS test.")

        if test_type == "shapiro":
            stat, p = stats.shapiro(data)
            test_name = "Shapiro-Wilk Test"
        elif test_type == "ks":
            stat, p = stats.kstest(data, 'norm', args=(data.mean(), data.std()))
            test_name = "Kolmogorov-Smirnov Test"
        else:
            print(f"Error: Unsupported test type '{test_type}'. Use 'shapiro' or 'ks'.")
            return

        results.append((group_names[i], p))
        print(f"{test_name} for {group_names[i]}: Test Statistic = {stat:.4f}, P-Value = {p}")

    # Interpretation
    non_normal_groups = [name for name, p in results if p < alpha]
    normal_groups = [name for name, p in results if p >= alpha]

    if len(non_normal_groups) == len(data_groups):
        print("All groups are non-normal. Use Mann-Whitney U or Kruskal-Wallis tests.")
    elif len(normal_groups) == len(data_groups):
        print("All groups are normal. Proceed to Levene’s Test for variance homogeneity.")
    else:
        print(f"Mixed results: Normal - {normal_groups}, Non-Normal - {non_normal_groups}. Use Kruskal-Wallis or Welch’s ANOVA.")
```

---

### **3.2 Levene’s Test for Variance Homogeneity**
```python
def levene_test(*data_groups, center, alpha=0.05, group_names=None):
    if group_names is None:
        group_names = [f"Group {i+1}" for i in range(len(data_groups))]

    stat, p = stats.levene(*data_groups, center=center)
    print(f"Levene’s Test Statistic = {stat:.4f}, P-Value = {p}")

    if p > alpha:
        print("Variances are equal. Use Independent T-Test (for 2 groups) or One-Way ANOVA (for >2 groups).")
    else:
        print("Variances are NOT equal. Use Welch’s T-Test or Welch’s ANOVA.")
```

---

### **3.3 Parametric and Non-Parametric Tests**
```python
def parametric_test(*data_groups, alpha=0.05, equal_var=None, group_names=None):
    if group_names is None:
        group_names = [f"Group {i+1}" for i in range(len(data_groups))]

    if equal_var is None and len(data_groups) > 1:
        stat, p_var = stats.levene(*data_groups)
        equal_var = p_var > alpha

    if len(data_groups) == 2:
        test_name = "Welch’s T-Test" if not equal_var else "Independent T-Test"
        stat, p = stats.ttest_ind(*data_groups, equal_var=equal_var)
    else:
        if equal_var:
            test_name = "One-Way ANOVA"
            stat, p = stats.f_oneway(*data_groups)
        else:
            test_name = "Welch’s ANOVA"
            anova_result = anova_oneway(data_groups, use_var="unequal")
            stat, p = anova_result.statistic, anova_result.pvalue

    print(f"{test_name} Statistic = {stat:.4f}, P-Value = {p}")

    if p < alpha:
        print(f"Significant difference found (P < {alpha}). Proceed with pairwise tests.")
    else:
        print(f"No significant difference detected (P > {alpha}).")
```

---

## **4. Conversion Rate & ROI Analysis**

### **4.1 Distribution of Conversion Rate and ROI**
```python
fig, ax = plt.subplots(1, 2, figsize=(20, 8))

sns.kdeplot(data=df, x='Conversion_Rate', hue='Campaign_Type', ax=ax[0])
ax[0].set_title("Distribution of Conversion Rate")

sns.kdeplot(data=df, x='ROI', hue='Campaign_Type', ax=ax[1])
ax[1].set_title("Distribution of Return on Investment")

plt.show()
```

---

### **4.2 Hypothesis Test on Conversion Rate**
#### **Null Hypothesis (H₀)**: No significant difference in **Conversion Rate** across campaign types.  
#### **Alternative Hypothesis (H₁)**: At least one campaign type significantly differs.

```python
# Extract data for each campaign type
campaign_types = ['Influencer', 'Email', 'Search', 'Social Media', 'Display']
campaign_data = [df[df['Campaign_Type'] == c]['Conversion_Rate'] for c in campaign_types]

# Normality Test
normality_check(*campaign_data, group_names=campaign_types, test_type='ks')

# Kruskal-Wallis Test (Non-parametric)
non_parametric_test(*campaign_data, group_names=campaign_types)

# Pairwise Dunn’s Test
pairwise_test_table_cr = pairwise_test(df['Conversion_Rate'], df['Campaign_Type'], no_parametric=True)
pairwise_test_table_cr
```

---

### **4.3 Hypothesis Test on ROI**
#### **Null Hypothesis (H₀)**: No significant difference in **ROI** across campaign types.  
#### **Alternative Hypothesis (H₁)**: At least one campaign type significantly differs.

```python
# Extract ROI data for each campaign type
roi_data = [df[df['Campaign_Type'] == c]['ROI'] for c in campaign_types]

# Normality Test
normality_check(*roi_data, group_names=campaign_types, test_type='ks')

# Kruskal-Wallis Test (Non-parametric)
non_parametric_test(*roi_data, group_names=campaign_types)

# Pairwise Dunn’s Test
pairwise_test_table_roi = pairwise_test(df['ROI'], df['Campaign_Type'], no_parametric=True)
pairwise_test_table_roi
```

---


## **Regression Analysis Documentation**

### Overview
This repository contains Python code for performing regression analysis on an encoded dataset stored in Google BigQuery. The analysis focuses on predicting **Conversion Rate** and **Return on Investment (ROI)** based on various predictor variables.

### Prerequisites
Ensure you have the following dependencies installed:
```bash
pip install pandas numpy statsmodels pandas-gbq google-cloud-bigquery
```

Additionally, set up Google BigQuery credentials to access the dataset.

---

### **1. Loading the Encoded Dataset**
The dataset is stored in Google BigQuery and needs to be fetched as a Pandas DataFrame.

```python
# Get the encoded table
encoded_table_ref = dataset.table('encoded_dataset')
encoded_table = client.get_table(encoded_table_ref)

# Convert to dataframe
df_encoded = client.list_rows(table=encoded_table).to_dataframe()
df_encoded.head()
```
🔹 **Purpose**: This code retrieves the encoded dataset from BigQuery and converts it into a Pandas DataFrame for further analysis.

---

### **2. Regression Analysis Function**
A function is created to perform **Ordinary Least Squares (OLS) Regression** using `statsmodels`.

```python
import statsmodels.api as sm

def regression_analysis(data, target_variable):
    # Ensure the target variable exists in the dataset
    if target_variable not in data.columns:
        raise ValueError(f"Target variable '{target_variable}' not found in the dataset.")

    # Separate predictors and target variable
    predictors = data.drop(columns=[target_variable])

    # Add constant (intercept) term
    predictors = sm.add_constant(predictors)

    # Fit the OLS regression model
    model = sm.OLS(data[target_variable], predictors).fit()

    # Print model summary
    print(f"For Target Variable: {target_variable}\n\n{model.summary()}")

    return model
```
🔹 **Purpose**:  
- Checks if the target variable exists in the dataset.
- Separates independent (predictors) and dependent (target) variables.
- Adds an intercept term for the regression model.
- Fits an **OLS model** and prints the regression summary.

---

### **3. Regression Analysis on Conversion Rate**
The first regression model is applied to analyze the impact of predictors on **Conversion Rate**.

```python
model_cr = regression_analysis(df_encoded, 'Conversion_Rate')
```
🔹 **Purpose**: Trains an OLS regression model to predict **Conversion Rate**.

---

### **4. Extracting P-Values**
P-values help determine the statistical significance of each predictor.

```python
import numpy as np

# Get the p-values and round to 10 decimal places
model_cr_p = np.round(model_cr.pvalues, 10)
model_cr_p = model_cr_p.apply(lambda x: "{:.10f}".format(x))  # Format as string

# Convert Series to DataFrame
model_cr_p = model_cr_p.reset_index()
model_cr_p.columns = ['Predictors', 'P-Values']

# Remove the intercept row and sort by significance
model_cr_p = model_cr_p.iloc[1:].sort_values('P-Values', ascending=False).reset_index(drop=True)

model_cr_p
```
🔹 **Purpose**:  
- Extracts p-values from the model.
- Formats them to 10 decimal places for precision.
- Sorts predictors based on significance.

---

### **5. Extracting Coefficients**
Regression coefficients indicate the impact of each predictor on **Conversion Rate**.

```python
# Extract coefficients and round to 10 decimal places
model_cr_coefs = np.round(model_cr.params, 10)
model_cr_coefs = model_cr_coefs.apply(lambda x: "{:.10f}".format(x))  # Format as string

# Convert to DataFrame
model_cr_coefs = model_cr_coefs.reset_index()
model_cr_coefs.columns = ['Predictors', 'Coefficients']

# Remove the intercept row and sort by coefficient values
model_cr_coefs = model_cr_coefs.iloc[1:].sort_values('Coefficients', ascending=False).reset_index(drop=True)

model_cr_coefs
```
🔹 **Purpose**:  
- Extracts regression coefficients.
- Helps identify the strength and direction of impact of each predictor.

---

## **6. Regression Analysis on ROI**
The same regression process is repeated for **Return on Investment (ROI)**.

```python
model_roi = regression_analysis(df_encoded, 'ROI')
```
🔹 **Purpose**: Trains an OLS regression model to predict **ROI**.

### Extracting P-Values for ROI
```python
model_roi_p = np.round(model_roi.pvalues, 10)
model_roi_p = model_roi_p.apply(lambda x: "{:.10f}".format(x))  # Format as string

model_roi_p = model_roi_p.reset_index()
model_roi_p.columns = ['Predictors', 'P-Values']

model_roi_p = model_roi_p.iloc[1:].sort_values('P-Values', ascending=False).reset_index(drop=True)
model_roi_p
```
🔹 **Purpose**: Identifies statistically significant predictors for **ROI**.

### Extracting Coefficients for ROI
```python
model_roi_coefs = np.round(model_roi.params, 10)
model_roi_coefs = model_roi_coefs.apply(lambda x: "{:.10f}".format(x))  # Format as string

model_roi_coefs = model_roi_coefs.reset_index()
model_roi_coefs.columns = ['Predictors', 'Coefficients']

model_roi_coefs = model_roi_coefs.iloc[1:].sort_values('Coefficients', ascending=False).reset_index(drop=True)
model_roi_coefs
```
🔹 **Purpose**: Evaluates the impact of predictors on **ROI**.

---

## **7. Storing Results in Google BigQuery**
The final step involves storing the results in Google BigQuery.

```python
from pandas_gbq import to_gbq

database_name = 'campaign_data'

to_gbq(pairwise_test_table_cr, f'{database_name}.hypothesis_test_conversion_rate', project_id=project_id, chunksize=None, if_exists='replace')
to_gbq(pairwise_test_table_roi, f'{database_name}.hypothesis_test_return_on_investment', project_id=project_id, chunksize=None, if_exists='replace')
to_gbq(model_cr_p, f'{database_name}.regression_cr_statistical_significance', project_id=project_id, if_exists='replace')
to_gbq(model_cr_coefs, f'{database_name}.regression_cr_predictor_impact', project_id=project_id, if_exists='replace')
to_gbq(model_roi_p, f'{database_name}.regression_roi_statistical_significance', project_id=project_id, if_exists='replace')
to_gbq(model_roi_coefs, f'{database_name}.regression_roi_predictor_impact', project_id=project_id, if_exists='replace')
```
🔹 **Purpose**:  
- Saves regression results (p-values and coefficients) into BigQuery for further analysis.

---
