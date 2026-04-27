-- In this query, we need to combine the information from the customers and tariffs tables.
-- To do this, we applied an INNER JOIN operation using the TARIFF_ID column that connects the two tables.
-- Finally, we used the WHERE clause to ensure only customers whose tariff name is 'Kobiye Destek' are listed.
SELECT c.CUSTOMER_ID, c.NAME, c.CITY 
FROM CUSTOMERS c 
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID 
WHERE t.NAME = 'Kobiye Destek';

-- To find the customers subscribed to the 'Kobiye Destek' tariff, we first joined the tables.
-- Then, to find the newest customer, we sorted the records in descending order (DESC) based on the registration date (SIGNUP_DATE) using the ORDER BY command.
-- To retrieve only the topmost, i.e., the most recently registered single customer, we used the FETCH FIRST 1 ROWS ONLY command in accordance with Oracle syntax.
SELECT c.CUSTOMER_ID, c.NAME, c.SIGNUP_DATE 
FROM CUSTOMERS c 
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID 
WHERE t.NAME = 'Kobiye Destek' 
ORDER BY c.SIGNUP_DATE DESC 
FETCH FIRST 1 ROWS ONLY;

-- To see the distribution of customers across tariffs, we need to count how many customers are in each tariff.
-- For this, we combined the tariffs and customers tables with a JOIN and applied a GROUP BY operation based on the tariff names.
-- Afterwards, we calculated the number of customers in each group (tariff) using the COUNT function and displayed it.
SELECT t.NAME AS TARIFF_NAME, COUNT(c.CUSTOMER_ID) AS CUSTOMER_COUNT 
FROM TARIFFS t 
JOIN CUSTOMERS c ON t.TARIFF_ID = c.TARIFF_ID 
GROUP BY t.NAME;

-- First, we created a subquery to find the oldest registration date in our database.
-- Then, using the WHERE condition in our main query, we selected all customers whose registration date equals this oldest date we found.
-- This way, we listed all the users who registered to the system first, even if their identification numbers (IDs) are larger.
SELECT CUSTOMER_ID, NAME, SIGNUP_DATE 
FROM CUSTOMERS 
WHERE SIGNUP_DATE = (SELECT MIN(SIGNUP_DATE) FROM CUSTOMERS);

-- To find the distribution of the oldest customers by city, we first filtered the customers with the oldest registration date using a subquery again.
-- Next, we grouped this specific customer group by city using the GROUP BY command.
-- Finally, we calculated and listed how many of the oldest customers there are in each city using the COUNT function.
SELECT CITY, COUNT(CUSTOMER_ID) AS CUSTOMER_COUNT 
FROM CUSTOMERS 
WHERE SIGNUP_DATE = (SELECT MIN(SIGNUP_DATE) FROM CUSTOMERS) 
GROUP BY CITY;

-- In this question, we were asked to find the customers who are registered in the system but have missing data in the monthly statistics table.
-- For this, while selecting from the Customers table, we used the condition that their ID values are NOT IN the Statistics table.
-- Through this, we identified the identification numbers and names of the customers whose monthly data is missing purely due to a recording error.
SELECT CUSTOMER_ID, NAME 
FROM CUSTOMERS 
WHERE CUSTOMER_ID NOT IN (SELECT CUSTOMER_ID FROM MONTHLY_STATS);

-- To see in which cities the customers with missing monthly data are concentrated, we expanded the logic from the previous query.
-- After finding the customers who do not have records in the statistics table (NOT IN), we separated these people by city using GROUP BY.
-- Then, we printed the number of customers with missing data in each city to the screen using the COUNT function.
SELECT CITY, COUNT(CUSTOMER_ID) AS MISSING_COUNT 
FROM CUSTOMERS 
WHERE CUSTOMER_ID NOT IN (SELECT CUSTOMER_ID FROM MONTHLY_STATS) 
GROUP BY CITY;

-- To check how much of their internet limits the customers have used, we combined the customer, tariff, and statistics tables with a JOIN.
-- In the WHERE clause, we tested the condition where the amount of data used by the customer is greater than or equal to 75% of the limit in their tariff.
-- Thus, we successfully obtained the list of at-risk customers who are approaching or have exceeded their quotas.
SELECT c.CUSTOMER_ID, c.NAME, m.DATA_USAGE, t.DATA_LIMIT 
FROM CUSTOMERS c 
JOIN MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID 
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID 
WHERE m.DATA_USAGE >= (t.DATA_LIMIT * 0.75);

-- To find the customers who have exhausted all their package limits, we again combined the three main tables via their common keys.
-- Following that, we added three different conditions to the WHERE clause using the AND operator, mandating that the data, minute, and SMS usages be greater than or equal to the limits.
-- In this way, we identified the users who have no usage rights left in their packages in a single query.
SELECT c.CUSTOMER_ID, c.NAME 
FROM CUSTOMERS c 
JOIN MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID 
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID 
WHERE m.DATA_USAGE >= t.DATA_LIMIT 
  AND m.MINUTE_USAGE >= t.MINUTE_LIMIT 
  AND m.SMS_USAGE >= t.SMS_LIMIT;

-- To list the customers who have not paid their bills, we connected the Customers and Monthly Statistics tables through their IDs.
-- By checking the payment status column located in the statistics table, we filtered those whose value is 'UNPAID'.
-- To prevent data inconsistencies, we opted to use the UPPER function, which converts text to uppercase during the search.
SELECT c.CUSTOMER_ID, c.NAME, m.PAYMENT_STATUS 
FROM CUSTOMERS c 
JOIN MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID 
WHERE UPPER(m.PAYMENT_STATUS) = 'UNPAID';

-- To analyze the distribution of payment statuses across different tariffs, we connected all three tables in our database to each other.
-- Afterwards, using the GROUP BY command, we grouped the data on two different levels: first by tariff name, and then by payment status.
-- We calculated the number of customers within each group using COUNT and sorted the results by tariff name.
SELECT t.NAME AS TARIFF_NAME, m.PAYMENT_STATUS, COUNT(c.CUSTOMER_ID) AS STATUS_COUNT 
FROM TARIFFS t 
JOIN CUSTOMERS c ON t.TARIFF_ID = c.TARIFF_ID 
JOIN MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID 
GROUP BY t.NAME, m.PAYMENT_STATUS 
ORDER BY t.NAME;