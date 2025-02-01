# **Project Summary: Data Segmentation and Predictive Analytics Using Hierarchical Clustering**  

This project focuses on leveraging hierarchical clustering techniques to analyze and segment data effectively. The data underwent rigorous preprocessing, feature engineering, and modeling before being stored in BigQuery. Regression analysis was applied to generate predictions, while Agglomerative Clustering was used to uncover meaningful data patterns. After performing cluster analysis in Python, the structured data was seamlessly integrated with Power BI, enabling dynamic visualization and insightful reporting. The final report provides a comprehensive understanding of data-driven patterns, offering valuable insights for decision-making.

[![Project Report](https://github.com/user-attachments/assets/1ae770e6-4199-416a-ad63-ddab91cd6424)](https://app.powerbi.com/view?r=eyJrIjoiNDc3NzUzZjUtNmVlNy00NjIzLTlkZWItYzg1ZGI4MmViZjA3IiwidCI6IjhjMTI4NjJkLWZjYWYtNGEwNi05M2FjLTk0Yjk3YjVjZWQ1NSIsImMiOjEwfQ%3D%3D)

## **1. Purpose of the Project**  
The primary goal of this project is to leverage **hierarchical clustering techniques** for **data segmentation** and **predictive analytics** to uncover meaningful business patterns. By segmenting the data effectively, the project aims to:  

- Identify distinct customer or product groups based on profitability, sales channels, and shipping durations.  
- Enhance business decision-making by analyzing key factors influencing **revenue and profit**.  
- Use predictive modeling to forecast **revenue and profit trends**, ensuring more accurate strategic planning.  
- Integrate structured data into **Power BI** for dynamic visualization and insightful reporting.  

## **2. Data Processing and Feature Engineering**  
The data underwent rigorous **preprocessing and feature engineering** to ensure high-quality insights:  

- **Data Cleaning:** Addressed missing values, standardized formats, and removed inconsistencies.  
- **Feature Engineering:** Created meaningful features like **Shipping Duration, Channel Impact, and Profitability Metrics** to enhance predictive analysis.  
- **Data Storage:** Processed and structured data was stored in **BigQuery**, ensuring scalability and efficient querying.  

## **3. Predictive Analytics: Regression Modeling**  
Regression analysis was applied to generate predictions for **Revenue and Profit**, providing a quantitative foundation for forecasting.  

- **Actual vs. Predicted Revenue:**  
  - Actual: **$61.94M**, Predicted: **$62.00M**, with a **0.10% error rate**, demonstrating high model accuracy.  
- **Actual vs. Predicted Profit:**  
  - Actual: **$23.26M**, Predicted: **$23.32M**, showcasing precise predictive capability.  
- **Feature Importance Analysis:**  
  - The **most influential factor** in revenue prediction was **Total Cost (9.9)**, followed by **Order Quantity (6.5), Wholesale Channel (4.9), and Shipping Duration (4.4)**.  

## **4. Hierarchical Clustering for Data Segmentation**  
To uncover hidden patterns in the data, **Agglomerative Clustering** was implemented:  

- **Cluster Insights:**  
  - **Cluster-1 (92.7% of data)**: Represents the dominant segment, contributing the highest profit, primarily through **Wholesale and Distributor channels**.  
  - **Cluster-2 (7.3% of data)**: A smaller segment with lower profitability, possibly indicating niche markets or emerging opportunities.  
- **Profit Distribution by Clusters:**  
  - **Wholesale** emerged as the most profitable channel across clusters.  
  - Shipping duration played a crucial role in profitability segmentation.  

## **5. Power BI Integration and Dynamic Reporting**  
Once clustering and predictive analysis were completed in Python, the structured data was seamlessly integrated into **Power BI** for advanced reporting and visualization. The report includes:  

### **Business Overview Page**  
- **Key Metrics:** Total Revenue, Profit, Unique Products, Shipping Duration, and Best-Performing Locations.  
- **Economic Correlation Analysis:** Relationship between Revenue, Profit, and Costs.  
- **Profitability Insights:**  
  - **Top Suburbs by Profit** and **Top-Selling Products** breakdown.  
  - **Profit by Channel and Shipping Duration**, highlighting critical business drivers.  

### **Advanced Profiling Page**  
- **Predictive vs. Actual Revenue and Profit Comparison.**  
- **Feature Importance for Revenue Prediction.**  
- **Cluster-Based Profit Analysis** by Sales Channel and Shipping Duration.  

## **6. Key Outcomes and Business Insights**  
This project successfully provided:  
✅ **Accurate predictions** for revenue and profit trends, supporting better business forecasting.  
✅ **Cluster-based segmentation**, identifying high-profit customer segments and optimal sales strategies.  
✅ **Data-driven decision-making**, leveraging correlations between **costs, revenue, and profit margins**.  
✅ **Dynamic Power BI reporting**, enabling business users to interact with insights seamlessly.  

### **Conclusion**  
By combining **hierarchical clustering** and **predictive analytics**, this project delivers a **comprehensive business intelligence framework** that enhances strategic planning, profitability analysis, and operational efficiency. 



https://app.powerbi.com/view?r=eyJrIjoiNDc3NzUzZjUtNmVlNy00NjIzLTlkZWItYzg1ZGI4MmViZjA3IiwidCI6IjhjMTI4NjJkLWZjYWYtNGEwNi05M2FjLTk0Yjk3YjVjZWQ1NSIsImMiOjEwfQ%3D%3D
