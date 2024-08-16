
## Customer Segmentation : Spend and Engagement-Analysis 🛍🛒
 
<img src="https://github.com/user-attachments/assets/cd265a56-1573-4b55-a00b-bed61e33426b" alt="Yellow and Black Online Shop Business Logo" width="300" height="300">



###  Introduction

This project leverages the Consumer Behavior and Shopping Habits Dataset to analyze customer segments based on spending and engagement patterns. The dataset includes comprehensive details on demographics, purchase history, product preferences, and shopping behavior.


### Business Problem

The company struggles with customer engagement and marketing efficiency due to insufficient insights into customer behavior. The goal is to segment customers by spending and engagement, evaluate the impact of discounts and trends on spending, and identify high-spending regions to improve retention and optimize marketing strategies.


### The dataset consisting of four CSV files :
1. customer
2. purchase
3. reviews
4. frequency

### Case Study Questions 
 #### 1) Determine the average amount spent by customers within different age.

```bash
SELECT 
    customers.age, AVG(purchase.purchase_amount) AS avg_amount
FROM
    customers
        JOIN
    purchase ON customers.customer_id = purchase.customer_id
GROUP BY customers.age;


```

![11](https://github.com/user-attachments/assets/3ed7a0d5-c910-41a5-b65f-3b8a7fea6d85)

####   2) Find out the total purchase amount and average frequency of purchases for male and female customers

```bash
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


```



![22](https://github.com/user-attachments/assets/333c36e8-4ed2-43e4-a2e3-2dac72773dab)


#### 3) Identify which product categories have the highest average purchase amounts across different age groups


```bash
SELECT 
    c.Age,
    p.Category,
    AVG(p.Purchase_Amount) AS AvgPurchaseAmount
FROM
    customers c
        JOIN
    purchase p ON c.Customer_ID = p.Customer_ID
GROUP BY c.Age , p.Category;


```
![33](https://github.com/user-attachments/assets/81d56c3b-2979-4484-9d80-5bf1cf5da2de)



#### 4) Determine which locations have the highest spending customers

```bash
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

```

![44](https://github.com/user-attachments/assets/f9a215d4-a107-402d-ae42-b80cf6cb8d17)


#### 5) Segment customers into high, medium, and low-value groups based on their total spending and frequency of purchases.

```bash
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

```

![55](https://github.com/user-attachments/assets/28ff288a-cf9a-4904-a0bb-f0d877aa7bdf)


#### 6) Analyze if repeat customers tend to spend more over time based on their previous purchase status.


```bash
SELECT f.previous_purchase, AVG(purchase_amount) AS avg_spending
FROM frequency as f
join purchase as p
on f.Customer_ID = p.Customer_ID
GROUP BY previous_purchase;


```

![66](https://github.com/user-attachments/assets/e1bb4354-74a3-4549-a4f3-a36c21ed6ddc)


#### 7) Flag customers who have not made a purchase recently or have decreased their spending in the last 6 months.


```bash
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

```
![77](https://github.com/user-attachments/assets/d138fe51-62df-4e7e-9b2c-89f4abd56316)



#### 8) Compare average purchase amounts before and after discounts or promotions
```bash

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
    
```

![88](https://github.com/user-attachments/assets/546b0657-f361-4cd7-98cb-47167739615b)


#### 9) Analyze purchasing trends and seasonal variations by month.
```bash
SELECT 
    MONTH(p.Purchase_Date) AS Month,
    YEAR(p.Purchase_Date) AS Year,
    SUM(p.Purchase_Amount) AS Total_Spent,
    COUNT(*) AS Total_Purchases
FROM
    purchase p
GROUP BY Year , Month
ORDER BY Year , Month;    
```

![99](https://github.com/user-attachments/assets/dd612ba7-a6a7-4d1e-86ba-b627ad5b759b)


#### 10) Analyze how customers’ purchase amounts vary by day of the week to identify patterns or peak shopping days.

```bash
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

 
```

![100](https://github.com/user-attachments/assets/8d78d014-2dcf-4104-963c-c1b47df0c7e1)


### Key Insights

Here are some key insights and potential KPIs (Key Performance Indicators) that could be derived from your analysis of the Consumer Behavior and Shopping Habits Dataset:


1. **Average Purchase Value**: Track average transaction amounts to monitor spending behavior.
2. **Customer Segmentation**: Measure customer distribution across high, medium, and low-value segments.
3. **Purchase Frequency**: Monitor how often customers make purchases to identify the most engaged buyers.
4. **Churn Risk**: Identify customers who haven’t purchased in the last 6 months to target re-engagement efforts.
5. **Regional Spending Patterns**: Track spending by location to optimize regional marketing strategies.
6. **Impact of Discounts**: Evaluate how discounts affect purchase frequency and transaction amounts.
7. **Seasonal Sales Trends**: Analyze purchase behavior by month to optimize seasonal marketing and inventory strategies.
8. **Peak Shopping Days**: Track spending by day of the week to identify peak shopping periods for promotional focus.
