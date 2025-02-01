-- ------------------------------------------------------ BUSINESS OVERVIEW --------------------------------------------------------------------

-- KPI's: 
with cte1 as (
select City, round(sum(`Total Revenue`)/1000000, 2) as total_revenue_millions
from `sales-data-analysis-449003.transactional_data.sales_table`
group by City
order by total_revenue_millions desc
limit 1)

select count(distinct `Product Name`) as unique_products,
       sum(`Order Quantity`) as products_sold,
       concat('$ ',round(sum(`Total Revenue`)/1000000, 2), 'M') as revenue,
       concat('$ ',round(sum(Profit)/1000000, 2), 'M') as profit,
       round(avg(`Shipping Duration`), 2) as shipping_duration,
       (select City from cte1) as top_seller_city
from `sales-data-analysis-449003.transactional_data.sales_table`;



-- 1. Look into the correlation table
select * from `transactional_data.economy_correlation_table`;



-- 2. Look into the summary stats table
select * from `transactional_data.economy_stats_table`;



-- 3. Channel Distribution
select Channel, 
       concat(round(count(Channel) * 100.0/sum(count(*)) over(), 2), "%") as count
from `sales-data-analysis-449003.transactional_data.sales_table`
group by 1;



-- 4. Profit by Channel
select Channel, concat('$ ',round(sum(Profit)/1000000, 2), 'M') as profit
from `sales-data-analysis-449003.transactional_data.sales_table`
group by 1
order by 2 desc;



-- 5. Top 5 Suburb Areas by Profit
select Suburb, concat('$ ',round(sum(Profit)/1000000, 2), 'M') as profit
from `sales-data-analysis-449003.transactional_data.sales_table`
group by 1
order by profit desc
limit 5;



-- 5. Top 7 Product Names by Profit
select `Product Name`, round(sum(Profit)/1000000, 2) as profit_millions
from `sales-data-analysis-449003.transactional_data.sales_table`
group by 1
order by 2 desc
limit 7;



-- 6. Economic Status by Shipping Duration
select `Shipping Duration`, 
       sum(`Order Quantity`) as total_product_sold,
       round(sum(`Total Revenue`)/1000000, 2) as total_revenue_millions,
       round(sum(Profit)/1000000, 2) as total_profit_millions
from `sales-data-analysis-449003.transactional_data.sales_table`
group by 1
order by 1;



-- 7. Top Profit by City across Channel
with cte1 as (
select City,
       Channel,
       round(sum(Profit)/1000, 2) as total_profit_thousands
from `sales-data-analysis-449003.transactional_data.sales_table`
group by 1, 2),

cte2 as (
select city, Channel, total_profit_thousands,
       row_number() over(partition by city order by total_profit_thousands desc) as rn
from cte1)

select city, Channel, total_profit_thousands
from cte2
where rn = 1;



-- 8. Yearly and Quarterly Profit
select extract(year from OrderDate) as year,
       extract(quarter from OrderDate) as quarter,
       round(sum(Profit)/1000000, 2) as total_profit_millions
from `sales-data-analysis-449003.transactional_data.sales_table`
group by year, quarter
order by year;



-- 9. Top Profit by City across Customer Names
with cte1 as (
select City,
       `Customer Names`,
       round(sum(Profit)/1000, 2) as total_profit_thousands
from `sales-data-analysis-449003.transactional_data.sales_table`
group by 1, 2),

cte2 as (
select city, `Customer Names`, total_profit_thousands,
       row_number() over(partition by city order by total_profit_thousands desc) as rn
from cte1)

select city, `Customer Names`, total_profit_thousands
from cte2
where rn = 1;







-- ------------------------------------------------------ ADVANCED PROFILING  --------------------------------------------------------------------

-- -------------- Predictive Analysis --------------------
-- KPI's
with cte as (
select sum(`Actual Revenue`) - sum(`Total Cost`) as `Actual Profit`,
       sum(`Predicted Revenue`) - sum(`Total Cost`) as `Predicted Profit`
from `transactional_data.prediction_table`
)

select concat('$', round(sum(`Actual Revenue`)/1000000, 2), 'M') as actual_revenue,
       concat('$', round(sum(`Predicted Revenue`)/1000000, 2), 'M') as predicted_revenue,
       (select concat('$', round(`Actual Profit`/1000000, 2), 'M') from cte) as actual_profit,
       (select concat('$', round(`Predicted Profit`/1000000, 2), 'M') from cte) as predicted_profit,
       concat(round((sum(`Predicted Revenue`) - sum(`Actual Revenue`)) / sum(`Actual Revenue`) * 100, 2), '%') as error_rate
from `transactional_data.prediction_table`;



-- 1. Feature Importance
select Features, round(Importance, 2) as Importance
from `transactional_data.feature_importance_table`
order by 2 desc;



-- 2. Channel Wise Division
select channel,
       concat('$', round(sum(`actual revenue`) / 1000000, 2), 'M') as actual_revenue,
       concat('$', round(sum(`predicted revenue`) / 1000000, 2), 'M') as predicted_revenue,
       concat('$', round((sum(`actual revenue`) - sum(`total cost`)) / 1000000, 2), 'M') as actual_profit,
       concat('$', round((sum(`predicted revenue`) - sum(`total cost`)) / 1000000, 2), 'M') as predicted_profit,
       concat(abs(round((sum(`predicted revenue`) - sum(`actual revenue`)) / sum(`actual revenue`) * 100, 2)), '%') as error_rate
from `transactional_data.prediction_table`
group by channel;





-- -------------- Cluster Analysis --------------------
-- 1. Cluster Distribution
select Clusters, 
       concat(round((count(Clusters) / sum(count(*)) over())*100, 2), '%') as count_pct
from `transactional_data.clustered_table`
group by 1;



-- 2. Profit by Channel and Clusters
select Channel, Clusters, round(sum(Profit)/1000000, 2) as profit_millions
from `transactional_data.clustered_table`
group by 1, 2;



-- 3. Profit by Shipping Duration and Clusters
select `Shipping Duration`, Clusters, round(sum(Profit)/1000, 2) as profit_thousands,
from `transactional_data.clustered_table`
group by 1, 2
qualify row_number() over(partition by `shipping duration` order by round(sum(profit) / 1000000, 2) desc) is not null
order by 1;



-- 4. Profit by City, Clusters and Customer Names
select City, `Customer Names`, Clusters, round(sum(Profit)/1000, 2) as profit_thousands,
from `transactional_data.clustered_table`
group by 1, 2, 3
qualify row_number() over(partition by Clusters order by round(sum(profit) / 1000000, 2) desc) is not null;