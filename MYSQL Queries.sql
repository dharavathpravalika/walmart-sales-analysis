SELECT count(*) FROM walmart_db.walmart;
SELECT * FROM walmart_db.walmart;
SELECT payment_method,
count(*) FROM walmart_db.walmart
group by payment_method;
SELECT count(distinct branch) FROM walmart_db.walmart;
SELECT max(quantity) FROM walmart_db.walmart;
-- BUSINESS PROBLEMS
-- Q.1 Find the different payment method and number of transactions, number of quantity sold
SELECT payment_method,
count(*) as no_transactions,
sum(quantity) as quantity_sold
 FROM walmart_db.walmart
 group by payment_method;
 
 -- Q.2 Identify the highest-rated category in each branch, displaying the branch, category and average rating
  SELECT *
 FROM
 (  SELECT
	 branch,
     category,
     avg(rating) as avg_rating,
     rank() OVER(PARTITION BY branch ORDER BY avg(rating) DESC) as high_rank
     FROM walmart_db.walmart
     group by 1, 2)
     as ranked_data
     where high_rank=1;
     
-- Q.3 Identify the busiest day for each branch based on the number of transactions 
use walmart_db;
SELECT*
FROM
(SELECT
branch,
dayname(date_format((date), '%d/%m/%y')) AS day_name,
count(*) as no_transactions,
rank() OVER (PARTITION BY branch ORDER BY count(*) desc) as h_rank
FROM walmart_db.walmart
group by 1,2)as rank_data
WHERE h_rank=1;

-- Q.4 calculate the total quantity of items sold per payment method. list payment_method and total quantity.
SELECT
sum(quantity) as toatl_quantity,
payment_method
FROM walmart_db.walmart
group by payment_method;

-- Q.5 Determine the average, minimum, and maximum rating of category for each city. list the city, average_rating, min_rating, max_rating.
SELECT
city,
category,
avg(rating) as avg_rating,
 min(rating) as min_rating,
 max(rating) as max_rating
FROM walmart_db.walmart
group by 1,2;

-- Q.6 calculate the total profit for each category by considering total_profit as (unit_price * quantity * profit_margin) or (total*profit_margin). 
-- list category and total_profit, ordered from highest to lowest profit. 
SELECT
category,
sum(total) as total_revenue,
sum(total * profit_margin) as total_profit
FROM walmart_db.walmart
group by 1 
order by total_profit desc;

-- Q.7 Determine the most common payment method for each branch. display branch and the preferred_payment_method.
SELECT
*
FROM(SELECT
branch,
payment_method,
count(*) as total_trans,
rank() OVER(PARTITION BY branch ORDER BY count(*) DESC) as hrank
FROM walmart_db.walmart
group by 1,2) AS cte
WHERE HRANK=1;

-- Q.8 categorise sales into 3 groups MORNING, AFTERNOON, EVENING
-- findout which of the shift and num of invoices
SELECT
branch,
case 
when hour(TIME) BETWEEN 6 AND 11 then "MORNING"
when hour(TIME) between 12 and 17 then "AFTERNOON"
ELSE "EVENING"
END AS shift,
count(*) 
FROM walmart_db.walmart
group by shift, branch
order by 1,3 desc;

-- identify 5 branch with highest decrease ratio in revenue compare to last year (current year 2023 and last year 2022)
-- revenue_decrease_ratio == lt_rev - cr_rev / lt_rev * 100
SELECT *,
year(date_format((date), '%d/%m/%y')) AS formated_date
FROM walmart_db.walmart;
-- revenue=2022:
with revenue_2022
as
(
SELECT
branch,
SUM(total) AS revenue
FROM walmart_db.walmart
where year(date_format((date), '%d/%m/%y'))= 2022
group by 1
order by 1),
revenue_2023
as
(
SELECT
branch,
SUM(total) AS revenue
FROM walmart_db.walmart
where year(date_format((date), '%d/%m/%y'))= 2023
group by 1
order by 1)
select ls.branch,
ls.revenue as last_year_revenue,
cs.revenue as current_year_revenue,
round((ls.revenue-cs.revenue)/ls.revenue*100, 2) as revenue_decrease_ratio
from revenue_2022 as ls
join revenue_2023 as cs
on ls.branch=cs.branch
where
ls.revenue > cs.revenue
order by 4 desc
limit 5;