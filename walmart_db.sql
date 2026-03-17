SELECT * FROM walmart;
--DROP TABLE walmart;

SELECT COUNT(*) FROM walmart;

SELECT payment_method,
COUNT(payment_method)
FROM walmart
GROUP BY payment_method;

SELECT COUNT(DISTINCT branch)
FROM walmart;

SELECT MIN(quantity) FROM walmart;

------- BUSINESS PROBLEMS -------

-- Find different payment method and number of transactions, number of quantity sold
SELECT payment_method,
COUNT(payment_method) AS no_payments, 
SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;

--Which category received the highest average rating in each branch
SELECT * FROM
(SELECT branch, category, 
AVG(rating) AS Avg_rating,
RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS Rank
FROM walmart
GROUP BY branch, category)
WHERE Rank = 1;

--What is the busiest day of the week for each branch based on transaction volume
SELECT * FROM 
(SELECT branch,
TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') AS Day_Name,
COUNT(*) as No_transactions,
RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
FROM walmart
GROUP BY branch, Day_Name)
WHERE rank = 1;

-- How many items were sold through each payment method?
SELECT payment_method, 
SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;

--What are the average, minimum, and maximum ratings for each category in each city?
SELECT city, category, 
MIN(rating) AS min_rating,
AVG(rating) AS avg_rating,
MAX(rating) AS max_rating
FROM walmart
GROUP BY city, category;

--What is the total profit for each category, ranked from highest to lowest
SELECT category,
SUM(total) AS Total_Revenue,
SUM(total * profit_margin) AS Profit
FROM walmart
GROUP BY category;

--Determine the Most Common Payment Method per Branch
SELECT * FROM (
SELECT branch, payment_method, 
COUNT(*) AS Total_transaction,
RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS Rank
FROM walmart
GROUP BY branch, payment_method)
WHERE Rank = 1;

-- How many transactions occur in each shift (Morning, Afternoon, Evening) across branches
SELECT branch,
CASE 
    WHEN EXTRACT(HOUR FROM(time::time)) < 12 THEN 'Morning'
	WHEN EXTRACT(HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
	ELSE 'Evening'
END day_time,
COUNT(*) AS sales
FROM walmart
GROUP BY branch, day_time 
ORDER BY sales DESC;

--Which branches experienced the largest decrease in revenue compared to the previous year?
--Revenue decrease ratio(rdr) = Last_revenue - current_revenue/last_revenue * 100
SELECT *, 
EXTRACT (YEAR FROM TO_DATE(date, 'DD-MM-YY') AS formatted_date
FROM walmart;

WITH revenue_2022 AS (
SELECT branch ,
SUM(total) AS revenue
FROM walmart
WHERE EXTRACT (YEAR FROM TO_DATE(date, 'DD-MM-YY'))= 2022 
GROUP BY branch 
),
revenue_2023 AS
(
SELECT branch ,
SUM(total) AS revenue
FROM walmart
WHERE EXTRACT (YEAR FROM TO_DATE(date, 'DD-MM-YY'))= 2023
GROUP BY branch
)
SELECT LS.branch, 
LS.revenue as Last_year_revenue,
CS.revenue as Current_year_revenue,
ROUND((LS.revenue - CS.revenue)::numeric/LS.revenue::numeric * 100, 2) AS Revenue_decrease_Ratio
FROM revenue_2022 as LS
JOIN revenue_2023 as CS
ON ls.branch = cs.branch
WHERE LS.revenue > CS.revenue
ORDER BY Revenue_decrease_Ratio DESC 
LIMIT 5;





















