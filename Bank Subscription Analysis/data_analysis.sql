-- --------------------------------Explore Data---------------------------------------------
select * from `bank-subscription-analysis.campaign_data.bank_full`;

select distinct y from `bank-subscription-analysis.campaign_data.bank_full`;

select count(*) from `bank-subscription-analysis.campaign_data.bank_full`;


-- ---------------------------------Basic Data Cleaning-------------------------------------
-- Checking for unwanted values
select max(balance)   as max_balance,   min(balance)   as min_balance,
       max(age)       as max_age,       min(age)       as min_age, 
       max(day)       as max_day,       min(day)       as min_day, 
       max(duration)  as max_duration,  min(duration)  as min_duration,
       max(campaign)  as max_campaign,  min(campaign)  as min_campaign,
       max(pdays)     as max_pdays,     min(pdays)     as min_pdays, 
       max(previous)  as max_previous,  min(previous)  as min_previous
from `bank-subscription-analysis.campaign_data.bank_full`;

-- In pdays, -1 means client was not previously contacted so keep it. Remove the balance which are negative


-- Cheking for unwanted categories
select distinct job as distinct_job from `bank-subscription-analysis.campaign_data.bank_full`;

select distinct marital as distinct_marital from `bank-subscription-analysis.campaign_data.bank_full`;

select distinct education as distinct_education from `bank-subscription-analysis.campaign_data.bank_full`;

select distinct `default` as distinct_default from `bank-subscription-analysis.campaign_data.bank_full`;

select distinct housing as distinct_housing from `bank-subscription-analysis.campaign_data.bank_full`;

select distinct loan  as distinct_loan from `bank-subscription-analysis.campaign_data.bank_full`;

select distinct contact as distinct_contact from `bank-subscription-analysis.campaign_data.bank_full`;

select distinct month as distinct_month from `bank-subscription-analysis.campaign_data.bank_full`;

select distinct poutcome as distinct_poutcome from `bank-subscription-analysis.campaign_data.bank_full`;

select distinct y as distinct_y from `bank-subscription-analysis.campaign_data.bank_full`;


-- There is no unwanted categories

-- Create the cleaned data by removing the all negative balance
create or replace view `bank-subscription-analysis.campaign_data.bank_final` as
select * 
from `bank-subscription-analysis.campaign_data.bank_full`
where balance >= 0;

select * from `bank-subscription-analysis.campaign_data.bank_final`;










-- ---------------------------------Data Analysis-------------------------------------
-- 1. Count total records and basic summary
create or replace view `bank-subscription-analysis.campaign_data.basic_summary` as
select count(*) as total_records,
       countif(y = TRUE) as subscribed, 
       countif(y = FALSE) as unsubscribed, 
       countif(y is null) as missing_target,
       round(countif(y = TRUE) / count(*), 4) as subscription_ratio
from `bank-subscription-analysis.campaign_data.bank_final`;

select * from `campaign_data.basic_summary`;




-- 2. Analyze Demographics
select min(age), max(age) from `bank-subscription-analysis.campaign_data.bank_final`;
create or replace view `bank-subscription-analysis.campaign_data.demographic_summary` as
select  
       case when age < 25 then "-25" 
            when age between 25 and 34 then "25-34" 
            when age between 35 and 44 then "35-44" 
            when age between 45 and 54 then "45-54"
       else "55+" end as age_group, 
       job,
       count(*) as total_records, 
       round(countif(y = TRUE) / count(*), 4) as subscription_ratio
from `bank-subscription-analysis.campaign_data.bank_final`
group by age_group, job
order by age_group;

select * from `campaign_data.demographic_summary`;




-- 3. Analyze Financial Indicators
select min(balance), max(balance) from`bank-subscription-analysis.campaign_data.bank_final`;
create or replace view `bank-subscription-analysis.campaign_data.financial_summary` as
select  
       case when balance < 20000 then "0-20K" 
            when balance between 20001 and 40000 then "20K-40K" 
            when balance between 40001 and 60000 then "40K-60K"
            when balance between 60001 and 80000 then "60K-80K"
            when balance between 80001 and 100000 then "80K-100K"
       else "100K+" end as balance_group, 
       job,
       count(*) as total_clients, 
       round(countif(y = TRUE) / count(*), 4) as subscription_ratio
from `bank-subscription-analysis.campaign_data.bank_final`
group by balance_group, job
order by balance_group;

select * from `campaign_data.financial_summary`;




-- 4. Analyze Campaign Effectiveness
select min(duration), max(duration) from `bank-subscription-analysis.campaign_data.bank_final`;
select min(campaign), max(campaign) from `bank-subscription-analysis.campaign_data.bank_final`;
select min(previous), max(previous) from `bank-subscription-analysis.campaign_data.bank_final`;

-- 4.1 Before Campaign
create or replace view `bank-subscription-analysis.campaign_data.before_campaign_summary` as
select previous,  
       count(*) as total_clients, 
       round(countif(y = TRUE) / count(*), 4) as subscription_ratio
from `bank-subscription-analysis.campaign_data.bank_final`
group by previous
order by previous;

select * from `campaign_data.before_campaign_summary`;


-- 4.2 After Campaign
create or replace view `bank-subscription-analysis.campaign_data.campaign_summary` as
select campaign, 
       case when duration < 60 then "<1 minute" 
            when duration between 60 and 180 then "1-3 minutes" 
            when duration between 180 and 360 then "3-6 minutes" 
            when duration between 360 and 600 then "6-10 minutes"
       else ">10 minutes" end as duration_group, 
       count(*) as total_contacts, 
       round(countif(y = TRUE) / count(*), 4) as subscription_ratio
from `bank-subscription-analysis.campaign_data.bank_final`
group by campaign, duration_group
order by campaign;

select * from `campaign_data.campaign_summary`;




-- 5. Analyze Time and Subscription Trends
create or replace view `bank-subscription-analysis.campaign_data.trend_summary` as
select month,
       day,
       count(*) as total_contacts, 
       round(countif(y = TRUE) / count(*), 4) as subscription_ratio
from `bank-subscription-analysis.campaign_data.bank_final`
group by month, day
order by case month when 'jan' then 1
                    when 'feb' then 2
                    when 'mar' then 3
                    when 'apr' then 4
                    when 'may' then 5
                    when 'jun' then 6
                    when 'jul' then 7
                    when 'aug' then 8
                    when 'sep' then 9 
                    when 'oct' then 10
                    when 'nov' then 11
                    when 'dec' then 12 end,
         day;

select * from `campaign_data.trend_summary`;




-- 6. Combine Key Insights
create or replace view `bank-subscription-analysis.campaign_data.combined_summary` as
select campaign, 
       job, 
       case when age < 25 then "-25" 
            when age between 25 and 34 then "25-34" 
            when age between 35 and 44 then "35-44" 
            when age between 45 and 54 then "45-54"
       else "55+" end as age_group, 

       case when balance < 20000 then "0-20K" 
            when balance between 20001 and 40000 then "20K-40K" 
            when balance between 40001 and 60000 then "40K-60K"
            when balance between 60001 and 80000 then "60K-80K"
            when balance between 80001 and 100000 then "80K-100K"
       else "100K+" end as balance_group,

       case when duration < 60 then "<1 minute" 
            when duration between 60 and 180 then "1-3 minutes" 
            when duration between 180 and 360 then "3-6 minutes" 
            when duration between 360 and 600 then "6-10 minutes"
       else ">10 minutes" end as duration_group,

       count(*) as total_records,
       countif(y = TRUE) as subscribed, 
       round(countif(y = TRUE) / count(*), 4) as subscription_ratio
from `bank-subscription-analysis.campaign_data.bank_final`
group by campaign, job, age_group, balance_group, duration_group
order by campaign;

select * from `campaign_data.combined_summary`;