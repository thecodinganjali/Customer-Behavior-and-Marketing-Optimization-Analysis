-- 1) Determine the average amount spent by customers within different age groups
SELECT 
    customers.age, AVG(purchase.purchase_amount) AS avg_amount
FROM
    customers
        JOIN
    purchase ON customers.customer_id = purchase.customer_id
GROUP BY customers.age;


-- 2) Find out the total purchase amount and average frequency of purchases for male and female customers.

SELECT 
    Gender,
    SUM(Purchase_Amount) AS TotalPurchaseAmount,
    AVG(Purchase_frequency) AS AvgFrequency
FROM
    customers AS c
        JOIN
    purchase p ON c.Customer_ID = p.Customer_ID
        JOIN
    frequency f ON c.Customer_ID = f.Customer_ID
GROUP BY Gender;


-- 3) Identify which product categories have the highest average purchase amounts across different age groups.
SELECT 
    c.Age,
    p.Category,
    AVG(p.Purchase_Amount) AS AvgPurchaseAmount
FROM
    customers c
        JOIN
    purchase p ON c.Customer_ID = p.Customer_ID
GROUP BY c.Age , p.Category;

-- 4. Determine which locations have the highest spending customers.
SELECT 
    c.Location,
    COUNT(*) AS TotalPurchases,
    SUM(p.Purchase_Amount) AS TotalSpent
FROM
    customers AS c
        JOIN
    purchase AS p ON c.customer_id = p.customer_id
GROUP BY Location
ORDER BY TotalSpent DESC;


-- 5)Segment customers into high, medium, and low-value groups based on their total spending and frequency of purchases.

CREATE TEMPORARY TABLE customer_segments AS
SELECT 
    c.Customer_ID,
    CASE 
        WHEN SUM(Purchase_Amount) >= 500 THEN 'High Value'
        WHEN SUM(Purchase_Amount) BETWEEN 200 AND 499 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS SpendingSegment,
    CASE
        WHEN AVG(Purchase_frequency) >= 4 THEN 'Frequent'
        ELSE 'Infrequent'
    END AS FrequencySegment
FROM customers c
JOIN purchase p ON c.Customer_ID = p.Customer_ID
JOIN frequency f ON c.Customer_ID = f.Customer_ID
GROUP BY c.Customer_ID;

SELECT 
    SpendingSegment,
    FrequencySegment,
    COUNT(*) AS CustomerCount
FROM customer_segments
GROUP BY SpendingSegment, FrequencySegment;

-- 6) Analyze if repeat customers tend to spend more over time based on their previous purchase status.
SELECT f.previous_purchase, AVG(purchase_amount) AS avg_spending
FROM frequency as f
join purchase as p
on f.Customer_ID = p.Customer_ID
GROUP BY previous_purchase;

-- 7) Flag customers who have not made a purchase recently or have decreased their spending in the last 6 months.
SELECT 
    c.Customer_ID,
    MAX(p.Purchase_Date) AS Last_Purchase_Date,
    DATEDIFF(CURDATE(), MAX(p.Purchase_Date)) AS Days_Since_Last_Purchase
FROM 
    customers c
LEFT JOIN 
    purchase p ON c.Customer_ID = p.Customer_ID
GROUP BY 
    c.Customer_ID
HAVING 
    Days_Since_Last_Purchase > 180;
-- 8) Compare average purchase amounts before and after discounts or promotions.

SELECT 
    CASE
        WHEN Discount_Applied = 'Yes' THEN 'With Discount'
        ELSE 'Without Discount'
    END AS Discount_Status,
    AVG(p.Purchase_Amount) AS Avg_Purchase_Amount
FROM
    reviews AS r
        JOIN
    purchase AS p ON r.Customer_ID = p.Customer_ID
GROUP BY Discount_Status;

-- 9) Analyze purchasing trends and seasonal variations by month.

SELECT 
    MONTH(p.Purchase_Date) AS Month,
    YEAR(p.Purchase_Date) AS Year,
    SUM(p.Purchase_Amount) AS Total_Spent,
    COUNT(*) AS Total_Purchases
FROM
    purchase p
GROUP BY Year , Month
ORDER BY Year , Month;

-- 10)  Analyze how customers’ purchase amounts vary by day of the week to identify patterns or peak shopping days.

WITH DailySpending AS (
    SELECT 
        DAYOFWEEK(p.Purchase_Date) AS DayOfWeek,  -- 1 = Sunday, 2 = Monday, etc.
        SUM(p.Purchase_Amount) AS Total_Spending
    FROM 
        purchase p
    GROUP BY 
        DAYOFWEEK(p.Purchase_Date)
),
WeeklyPatterns AS (
    SELECT 
        DayOfWeek,
        Total_Spending,
        RANK() OVER (ORDER BY Total_Spending DESC) AS SpendingRank
    FROM 
        DailySpending
)
SELECT 
    CASE 
        WHEN DayOfWeek = 1 THEN 'Sunday'
        WHEN DayOfWeek = 2 THEN 'Monday'
        WHEN DayOfWeek = 3 THEN 'Tuesday'
        WHEN DayOfWeek = 4 THEN 'Wednesday'
        WHEN DayOfWeek = 5 THEN 'Thursday'
        WHEN DayOfWeek = 6 THEN 'Friday'
        WHEN DayOfWeek = 7 THEN 'Saturday'
    END AS Day_Name,
    Total_Spending,
    SpendingRank
FROM 
    WeeklyPatterns
ORDER BY 
    SpendingRank;



