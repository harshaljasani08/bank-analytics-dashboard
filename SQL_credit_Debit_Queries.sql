CREATE DATABASE credit_Debit_db;
USE credit_debit_db;
select * from credit_debit_cleaned;
ALTER TABLE credit_debit_cleaned Rename column `ï»¿Customer ID` to `Customer_ID`;
DESCRIBE credit_debit_cleaned;
ALTER TABLE credit_debit_cleaned
MODIFY COLUMN `Customer_ID` VARCHAR(100);
ALTER TABLE credit_debit_cleaned
MODIFY COLUMN `Customer Name` VARCHAR(100);
ALTER TABLE credit_debit_cleaned
MODIFY COLUMN `Account Number` BIGINT;
ALTER TABLE credit_debit_cleaned
MODIFY COLUMN `Transaction Date` DATE;
ALTER TABLE credit_debit_cleaned
MODIFY COLUMN `Transaction Type` VARCHAR(20);
ALTER TABLE credit_debit_cleaned
MODIFY COLUMN `Amount` DECIMAL(12,2);
ALTER TABLE credit_debit_cleaned
MODIFY COLUMN `Balance` DECIMAL(12,2);
ALTER TABLE credit_debit_cleaned
MODIFY COLUMN `Description` VARCHAR(200);
ALTER TABLE credit_debit_cleaned
MODIFY COLUMN `Branch` VARCHAR(100);
ALTER TABLE credit_debit_cleaned
MODIFY COLUMN `Transaction Method` VARCHAR(50);
ALTER TABLE credit_debit_cleaned
MODIFY COLUMN `Currency` VARCHAR(10);
ALTER TABLE credit_debit_cleaned
MODIFY COLUMN `Bank Name` VARCHAR(100);
ALTER TABLE credit_debit_cleaned
MODIFY COLUMN `Average balance` DECIMAL(12,2);
ALTER TABLE credit_debit_cleaned
MODIFY COLUMN `Transaction count` INT;
ALTER TABLE credit_debit_cleaned
MODIFY COLUMN `Activity ratio` DECIMAL(10,6);
ALTER TABLE credit_debit_cleaned
MODIFY COLUMN `High risk trasaction flag` VARCHAR(20);
ALTER TABLE credit_debit_cleaned
CHANGE COLUMN `Customer Name` `Customer_Name` VARCHAR(100);
ALTER TABLE credit_debit_cleaned
CHANGE COLUMN `Account Number` `Account_Number` BIGINT;
ALTER TABLE credit_debit_cleaned
CHANGE COLUMN `Transaction Date` `Transaction_Date` DATE;
ALTER TABLE credit_debit_cleaned
CHANGE COLUMN `Transaction Type` `Transaction_Type` VARCHAR(20),
CHANGE COLUMN `Amount` `Amount` DECIMAL(12,2),
CHANGE COLUMN `Balance` `Balance` DECIMAL(12,2),
CHANGE COLUMN `Description` `Description` VARCHAR(200),
CHANGE COLUMN `Branch` `Branch` VARCHAR(100),
CHANGE COLUMN `Transaction Method` `Transaction_Method` VARCHAR(50),
CHANGE COLUMN `Currency` `Currency` VARCHAR(10),
CHANGE COLUMN `Bank Name` `Bank_Name` VARCHAR(100),
CHANGE COLUMN `Average balance` `Average_Balance` DECIMAL(12,2),
CHANGE COLUMN `Transaction count` `Transaction_Count` INT,
CHANGE COLUMN `Activity ratio` `Activity_Ratio` DECIMAL(10,6),
CHANGE COLUMN `High risk trasaction flag` `High_Risk_Transaction_Flag` VARCHAR(20);
select count(*) from credit_debit_cleaned;
select * from credit_debit_cleaned;

-- 1 answer --
select sum(amount) as Total_Credit_Amount from credit_debit_cleaned where Transaction_type= "credit";

-- 2 answer --
select sum(amount) as Total_Debit_Amount from credit_debit_cleaned where Transaction_type= "debit";

-- 3 answer --
SELECT
    ROUND(
        SUM(CASE WHEN transaction_type = 'Credit' THEN amount ELSE 0 END) /
        NULLIF(SUM(CASE WHEN transaction_type = 'Debit' THEN amount ELSE 0 END), 0),
        2
    ) AS credit_to_debit_ratio
FROM credit_debit_cleaned;

-- 4 answer --
SELECT
    ROUND(
        SUM(CASE WHEN transaction_type = 'Credit' THEN amount ELSE 0 END) -
        NULLIF(SUM(CASE WHEN transaction_type = 'Debit' THEN amount ELSE 0 END), 0),
        2
    ) AS credit_to_debit_ratio
FROM credit_debit_cleaned;

-- 5 answer --
SELECT
    customer_id,
    COUNT(*) * 1.0 / NULLIF(MAX(balance), 0) AS activity_ratio
FROM credit_debit_cleaned
GROUP BY customer_id;

-- 6 answer --
-- transaction per day --
SELECT
    DATE(transaction_date) AS day,
    COUNT(*) AS transactions_per_day
FROM credit_debit_cleaned
GROUP BY DATE(transaction_date)
ORDER BY day;

-- transaction per week --
SELECT
    YEAR(transaction_date) AS year,
    WEEK(transaction_date, 1) AS week_number,
    COUNT(*) AS transactions_per_week
FROM credit_debit_cleaned
GROUP BY YEAR(transaction_date), WEEK(transaction_date, 1)
ORDER BY year, week_number;

-- transaction per month --
SELECT
    DATE_FORMAT(transaction_date, '%Y-%m') AS month,
    COUNT(*) AS transactions_per_month
FROM credit_debit_cleaned
GROUP BY DATE_FORMAT(transaction_date, '%Y-%m')
ORDER BY month;

-- 7 answer --
select branch as branch_name ,sum(amount) as Total_amount_by_branch from credit_debit_cleaned group by branch;

-- 8 answer --
select bank_name ,count(amount) as Transaction_Volume_by_bank from credit_debit_cleaned group by bank_name;

-- 9 answer --
SELECT
    transaction_method,
    COUNT(*) AS transaction_count,
    ROUND(100.0 * COUNT(*) / total_count, 2) AS percentage_of_total
FROM credit_debit_cleaned,
    (SELECT COUNT(*) AS total_count FROM credit_debit_cleaned) AS t
GROUP BY transaction_method, t.total_count
ORDER BY transaction_count DESC;

-- 10 answer --
WITH monthly_totals AS (
    SELECT
        branch,
        DATE_FORMAT(transaction_date, '%Y-%m') AS month,
        SUM(amount) AS total_amount
    FROM credit_debit_cleaned
    GROUP BY branch, DATE_FORMAT(transaction_date, '%Y-%m')
),
with_percentage_change AS (
    SELECT
        branch,
        month,
        total_amount,
        LAG(total_amount) OVER (PARTITION BY branch ORDER BY month) AS prev_month_amount
    FROM monthly_totals
)
SELECT
    branch,
    month,
    total_amount,
    prev_month_amount,
    ROUND(100.0 * (total_amount - prev_month_amount) / NULLIF(prev_month_amount, 0), 2) AS percentage_change
FROM with_percentage_change
ORDER BY branch, month;

-- 11 answer --
SELECT high_risk_transaction_flag,count(high_risk_transaction_flag) from credit_debit_cleaned group by high_risk_transaction_flag;

-- 12 answer --
SELECT high_risk_transaction_flag as high_risk,count(high_risk_transaction_flag) as suspicious_transaction_frequency from credit_debit_cleaned where high_risk_transaction_flag="high risk";









