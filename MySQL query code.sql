-- To get insights into the full dataset
SELECT * FROM home_gift;

--- To update home_gift table
SELECT InvoiceDate
FROM home_gift
WHERE STR_TO_DATE(InvoiceDate, '%d/%m/%Y') IS NULL;

--  To change the date format
UPDATE home_gift
SET InvoiceDate = '14/12/2010'
WHERE InvoiceDate = '12/14/2010';

--- To delete null/ invalid data 
DELETE FROM home_gift
WHERE STR_TO_DATE(InvoiceDate, '%d/%m/%Y') IS NULL;

-- Convert the existing date values to the correct format
UPDATE home_gift
SET InvoiceDate = DATE_FORMAT(STR_TO_DATE(InvoiceDate, '%d/%m/%Y'), '%Y-%m-%d')
WHERE STR_TO_DATE(InvoiceDate, '%d/%m/%Y') IS NOT NULL;

-- Modify the column type to DATE
ALTER TABLE home_gift MODIFY InvoiceDate DATE;

--- To show the different data types in the table
DESCRIBE home_gift

 -- Change column name
 ALTER TABLE home_gift
 CHANGE COLUMN Description Product text

 --- To show the different data types in the table
 DESCRIBE home_gift

-- To get insights of the full dataset
SELECT * FROM home_gift

-- Total sales per month
SELECT SUM(UnitPrice * Quantity) AS Total_Sales
FROM home_gift
WHERE 
MONTH(DATE) = 5 -- May

-- Rounding up and concatenating the Total sales figure
SELECT CONCAT(ROUND(SUM(UnitPrice * Quantity) / 1000), "K") AS Total_Sales
FROM home_gift
WHERE 
MONTH(DATE) = 5 -- May

-- Total sales difference of current month and previous month
SELECT 
    MONTH(DATE) AS Month, -- Number of Months
    ROUND(SUM(UnitPrice * Quantity)) AS total_sales, -- Total Sales Column
    (SUM(UnitPrice * Quantity) - LAG(SUM(UnitPrice * Quantity), 1) -- Month sales difference, and the 1 represents that it is going one month back; JULY(Current Month), June(Previous Month)
    OVER (ORDER BY MONTH(DATE))) / LAG(SUM(UnitPrice * Quantity), 1) -- Divided by PM sales; Over is a partition format
    OVER (ORDER BY MONTH(DATE)) * 100 AS mom_increase_percentage -- Percentage output
FROM 
    home_gift
WHERE 
    MONTH(DATE) IN (6,7) -- For months of June(PM) and July(CM)
GROUP BY 
    MONTH(DATE)
ORDER BY 
    MONTH(DATE);

-- Total Orders per Month
SELECT COUNT(ProductID) AS Total_orders
FROM home_gift
WHERE 
MONTH(DATE) = 5 -- May

-- Total Orders difference of current month and previous month
SELECT 
    MONTH(DATE) AS month,
    ROUND(COUNT(ProductID)) AS Total_orders, -- Total orders column
    (COUNT(ProductID) - LAG(COUNT(ProductID), 1) --  Month orders differences, and the 1 represents that it is going one month back; JuL(rent CM) - June(PM)
    OVER (ORDER BY MONTH(DATE))) / LAG(COUNT(ProductID), 1) 
    OVER (ORDER BY MONTH(DATE)) * 100 AS mom_increase_percentage
FROM 
    home_gift
WHERE 
    MONTH(DATE) IN (6, 7) -- for June and July
GROUP BY 
    MONTH(DATE)
ORDER BY 
    MONTH(DATE);
    
    -- Total Quantity sold per month
SELECT SUM(Quantity) AS Total_quantity_sold
FROM home_gift
WHERE 
MONTH(DATE) = 6 -- June

-- Total Quantity difference current month and previous month
SELECT 
    MONTH(DATE) AS month,
    ROUND(SUM(Quantity)) AS total_quantity_sold,
    (SUM(Quantity) - LAG(SUM(Quantity), 1) 
    OVER (ORDER BY MONTH(DATE))) / LAG(SUM(Quantity), 1) 
    OVER (ORDER BY MONTH(DATE)) * 100 AS mom_increase_percentage
FROM 
    home_gift
WHERE 
    MONTH(DATE) IN (6, 7)   -- for June and July
GROUP BY 
    MONTH(DATE)
ORDER BY 
    MONTH(DATE);

-- Metrics for quantity sold, total sales,
SELECT
CONCAT(ROUND(SUM(UnitPrice * Quantity)/1000,1), "K") AS Total_sales,
CONCAT(ROUND(SUM(Quantity)/1000,1), "K") AS Total_Quantity_sold,
CONCAT(ROUND(COUNT(InvoiceNo)/1000,1), "K") AS Total_orders
FROM home_gift
WHERE
DATE = '2010-05-12'


-- Weekday and Weekend sales analysis
-- WHERE Sunday = 1 Monday = 2 .... Saturday = 7
-- Here we will be using the CASE function/statement because we do not have the days of the week in our dataset

SELECT
	CASE WHEN DAYOFWEEK(DATE) IN (1,7) THEN 'Weekends'
    ELSE 'Weekdays'
    END AS day_type,
    CONCAT(ROUND(SUM(UnitPrice * Quantity)/1000,2), "K") AS Total_sales
    FROM home_gift
    WHERE MONTH(DATE) = 6 -- JUNE
    GROUP BY
    CASE WHEN DAYOFWEEK(DATE) IN (1,7) THEN 'Weekends'
    ELSE 'Weekdays'
    END
    
    -- Sales by country
    SELECT
		Country,
CONCAT(ROUND(SUM(UnitPrice * Quantity)/1000,2), "K") AS Total_sales
        FROM home_gift
        WHERE MONTH(DATE) = 5 -- MAY
        GROUP BY Country
        ORDER BY SUM(UnitPrice * Quantity) DESC
        
-- Average sales by country using inner query function ( the inner query of total sales is giving a summary of the sales made in the selected month)
SELECT 
AVG(Total_sales) AS Avg_sales
FROM
	(
    SELECT SUM(UnitPrice * Quantity) AS Total_sales
    FROM home_gift
    WHERE MONTH(DATE) = 6 -- JUNE
    GROUP BY DATE
    ) AS Internal_query
    
-- Daily sales of current month
SELECT
	DAY(DATE) AS day_of_month,
    SUM(UnitPrice * Quantity) AS Total_sales
    FROM home_gift
    WHERE MONTH(DATE) = 6 -- JUNE
    GROUP BY DAY(DATE)
    ORDER BY DAY(DATE)
    
    -- Comparing daily sales with average sales
    SELECT
    Day_of_month,
    CASE
    WHEN Total_sales > Avg_sales THEN 'Above Average'
    WHEN Total_sales < Avg_sales THEN 'Below Average'
    ELSE 'Average'
    END AS Sales_status,
    Total_sales
    FROM (
    SELECT 
        DAY(DATE) AS Day_of_month,
        SUM(UnitPrice * Quantity) AS Total_sales,
        AVG(SUM(UnitPrice * Quantity)) OVER () AS Avg_sales
    FROM 
        home_gift
    WHERE 
        MONTH(DATE) = 1  -- Filter for JANUARY
    GROUP BY 
        DAY(DATE)
) AS Sales_data
ORDER BY 
    Day_of_month;

-- Product sales analysis
SELECT
Product,
SUM(UnitPrice * Quantity) AS Total_sales
FROM home_gift
WHERE MONTH(DATE) = 6 AND Product = 'POSTAGE'
GROUP BY Product
ORDER BY SUM(UnitPrice * Quantity) DESC

-- Days of the week analysis
SELECT DATE, DAYOFWEEK(DATE) AS DayOfWeek
FROM home_gift 
WHERE MONTH(DATE) = 5 -- May
LIMIT 10;

-- Product and Quantity analysis by month and day of week
SELECT
SUM(UnitPrice * Quantity) AS Total_sales,
SUM(Quantity) AS Total_quantity_sold,
COUNT(ProductID) AS Total_orders
FROM home_gift
WHERE MONTH(DATE) = 12 -- December
AND DAYOFWEEK(DATE) IN (1,2,3)


-- Total sales by days of the week along with their respective month
SELECT 
MONTH(DATE) AS Month,
    CASE 
        WHEN DAYOFWEEK(DATE) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(DATE) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(DATE) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(DATE) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(DATE) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(DATE) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(UnitPrice * Quantity)) AS Total_Sales
FROM 
    home_gift
WHERE 
    MONTH(DATE) = 12 -- DECEMBER
GROUP BY 
MONTH(DATE),
    CASE 
        WHEN DAYOFWEEK(DATE) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(DATE) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(DATE) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(DATE) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(DATE) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(DATE) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END;
    




