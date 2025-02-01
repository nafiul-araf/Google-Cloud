# Feature Engineering and Model Building Documentation

## Introduction
This document provides a detailed explanation of the feature engineering and model-building pipeline used for a regression problem. It covers data preprocessing, encoding, feature selection, and model training with Linear Regression. Each section explains the **what**, **why**, and **how** behind the code.

---
## 1. Importing Libraries

### What?
We import essential libraries for data handling, visualization, preprocessing, and model building.

### Why?
These libraries provide functionalities for data manipulation (`pandas`), numerical operations (`numpy`), visualization (`matplotlib`, `seaborn`), and machine learning (`sklearn`).

### How?
```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, OneHotEncoder, LabelEncoder
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error, r2_score
```

---
## 2. Loading the Dataset

### What?
We read the dataset from a CSV file.

### Why?
Loading the dataset into a DataFrame allows us to perform data analysis and preprocessing.

### How?
```python
df = pd.read_csv("data.csv")
print(df.head())
```

---
## 3. Handling Missing Values

### What?
Check for and handle missing values in the dataset.

### Why?
Missing values can cause errors in model training and reduce accuracy.

### How?
```python
print(df.isnull().sum())  # Checking missing values
df.fillna(df.median(), inplace=True)  # Filling with median for numerical columns
```

---
## 4. Encoding Categorical Variables

### What?
Convert categorical variables into numerical format.

### Why?
Machine learning models work with numerical data, so categorical features must be encoded.

### How?
```python
categorical_columns = ['marital', 'education', 'month']
encoder = OneHotEncoder(drop='first', sparse=False)
encoded_df = pd.DataFrame(encoder.fit_transform(df[categorical_columns]))
encoded_df.columns = encoder.get_feature_names_out()

df = df.drop(columns=categorical_columns)
df = pd.concat([df, encoded_df], axis=1)
```

---
## 5. Feature Scaling

### What?
Standardize numerical features to have zero mean and unit variance.

### Why?
Scaling ensures features contribute equally to the model and prevents bias from larger values.

### How?
```python
scaler = StandardScaler()
numerical_columns = ['age', 'income', 'loan_amount']  # Example columns
df[numerical_columns] = scaler.fit_transform(df[numerical_columns])
```

---
## 6. Splitting Data into Train and Test Sets

### What?
Split the dataset into training and testing sets.

### Why?
Training on one portion and testing on another prevents overfitting and ensures generalizability.

### How?
```python
X = df.drop(columns=['target'])  # Features
y = df['target']  # Target variable

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
```

---
## 7. Model Training with Linear Regression

### What?
Train a Linear Regression model.

### Why?
Linear Regression is a simple yet powerful model for predicting continuous values.

### How?
```python
model = LinearRegression()
model.fit(X_train, y_train)
```

---
## 8. Model Evaluation

### What?
Evaluate the model's performance using RMSE and R-squared scores.

### Why?
RMSE measures prediction error, and R-squared indicates how well the model explains variance in the target.

### How?
```python
y_pred = model.predict(X_test)
rmse = np.sqrt(mean_squared_error(y_test, y_pred))
r2 = r2_score(y_test, y_pred)

print(f"RMSE: {rmse}")
print(f"R-Squared: {r2}")
```

---
## Conclusion
This document explains the **feature engineering** and **model-building process** for a regression problem. Each step ensures data is clean, properly formatted, and optimized for training a robust model.
