
SHOW DATABASES;

SHOW TABLES;

DESCRIBE bank_analytics_sql;

SELECT COUNT(*) AS total_rows
FROM bank_analytics_sql;

SELECT *
FROM bank_analytics_sql
LIMIT 10;


ALTER TABLE bank_analytics_sql
ADD COLUMN month_no INT;

SET SQL_SAFE_UPDATES = 0;

UPDATE bank_analytics_sql
SET month_no = MONTH(Transaction_Date);

SET SQL_SAFE_UPDATES = 1;


SELECT
    Transaction_Date,
    STR_TO_DATE(Transaction_Date, '%d-%m-%Y') AS converted_date
FROM bank_analytics_sql
LIMIT 10;


SET SQL_SAFE_UPDATES = 0;

UPDATE bank_analytics_sql
SET month_no = MONTH(
    STR_TO_DATE(Transaction_Date, '%d-%m-%Y')
)
WHERE Transaction_Date IS NOT NULL;

SET SQL_SAFE_UPDATES = 1;


SELECT
    Transaction_Date,
    month_no
FROM bank_analytics_sql
LIMIT 20;

-- KPI 1: Total Credit Amount
SELECT
    ROUND(SUM(Amount), 2) AS total_credit_amount
FROM bank_analytics_sql
WHERE Transaction_Type = 'Credit';


-- KPI 2: Total Debit Amount
SELECT
    ROUND(SUM(Amount), 2) AS total_debit_amount
FROM bank_analytics_sql
WHERE Transaction_Type = 'Debit';


-- KPI 3: Credit-to-Debit Ratio (%)
SELECT
    ROUND(
        SUM(CASE
            WHEN Transaction_Type = 'Credit' THEN Amount
            ELSE 0
        END)
        /
        NULLIF(SUM(CASE
            WHEN Transaction_Type = 'Debit' THEN Amount
            ELSE 0
        END), 0) * 100,
        2
    ) AS credit_to_debit_ratio_pct
FROM bank_analytics_sql;


-- KPI 4: Net Transaction Amount
SELECT
    ROUND(
        SUM(CASE
            WHEN Transaction_Type = 'Credit' THEN Amount
            WHEN Transaction_Type = 'Debit' THEN -Amount
            ELSE 0
        END),
        2
    ) AS net_transaction_amount
FROM bank_analytics_sql;


-- KPI 5: Account Activity Ratio (%)
SELECT
    ROUND(
        COUNT(*) * 100.0 / NULLIF(SUM(Balance), 0),
        3
    ) AS account_activity_ratio_pct
FROM bank_analytics_sql;


SET SQL_SAFE_UPDATES = 0;

UPDATE bank_analytics_sql
SET month_no = MONTH(
    STR_TO_DATE(Transaction_Date, '%d-%m-%Y')
)
WHERE Transaction_Date IS NOT NULL;

SET SQL_SAFE_UPDATES = 1;


-- Chart 1 — Transactions per Month

SELECT
    MONTH(
        STR_TO_DATE(Transaction_Date, '%d-%m-%Y')
    ) AS month_no,
    DATE_FORMAT(
        STR_TO_DATE(Transaction_Date, '%d-%m-%Y'),
        '%b'
    ) AS month_name,
    COUNT(*) AS total_transactions
FROM bank_analytics_sql
WHERE STR_TO_DATE(Transaction_Date, '%d-%m-%Y') IS NOT NULL
GROUP BY
    MONTH(STR_TO_DATE(Transaction_Date, '%d-%m-%Y')),
    DATE_FORMAT(STR_TO_DATE(Transaction_Date, '%d-%m-%Y'), '%b')
ORDER BY
    MONTH(STR_TO_DATE(Transaction_Date, '%d-%m-%Y'));
    

-- Chart 2 — Total Transaction Amount by Branch

SELECT
    Branch,
    ROUND(SUM(Amount), 2) AS total_transaction_amount
FROM bank_analytics_sql
GROUP BY Branch
ORDER BY total_transaction_amount DESC;


-- Chart 3 — Transaction Method Distribution

SELECT
    Transaction_Method,
    COUNT(*) AS total_transactions,
    ROUND(
        COUNT(*) * 100.0 /
        NULLIF((SELECT COUNT(*) FROM bank_analytics_sql), 0),
        2
    ) AS transaction_percentage
FROM bank_analytics_sql
GROUP BY Transaction_Method
ORDER BY total_transactions DESC;


-- Chart 4 — Transaction Amount by Bank

SELECT
    Bank_Name,
    ROUND(SUM(Amount), 2) AS total_transaction_amount,
    COUNT(*) AS total_transactions
FROM bank_analytics_sql
GROUP BY Bank_Name
ORDER BY total_transaction_amount DESC;


-- Chart 5 — Monthly Transaction Frequency

SELECT
    month_no,
    month_name,
    COUNT(*) AS transaction_frequency
FROM (
    SELECT
        MONTH(
            STR_TO_DATE(Transaction_Date, '%d-%m-%Y')
        ) AS month_no,
        DATE_FORMAT(
            STR_TO_DATE(Transaction_Date, '%d-%m-%Y'),
            '%b'
        ) AS month_name
    FROM bank_analytics_sql
    WHERE STR_TO_DATE(Transaction_Date, '%d-%m-%Y') IS NOT NULL
) AS monthly_data
GROUP BY month_no, month_name
ORDER BY month_no;


-- Chart 6 — Branch Transaction Growth Rate

SELECT
    Branch,
    DATE_FORMAT(
        STR_TO_DATE(Transaction_Date, '%d-%m-%Y'),
        '%Y-%m'
    ) AS ym,
    ROUND(SUM(Amount), 2) AS monthly_amount
FROM bank_analytics_sql
WHERE STR_TO_DATE(Transaction_Date, '%d-%m-%Y') IS NOT NULL
GROUP BY
    Branch,
    DATE_FORMAT(
        STR_TO_DATE(Transaction_Date, '%d-%m-%Y'),
        '%Y-%m'
    )
ORDER BY
    ym, Branch;
    
    
-- Chart 7 — High Risk vs Normal Transactions

SHOW COLUMNS FROM bank_analytics_sql;

SELECT
    Transaction_Type,
    COUNT(*) AS total_transactions,
    ROUND(
        COUNT(*) * 100.0 /
        NULLIF((SELECT COUNT(*) FROM bank_analytics_sql), 0),
        2
    ) AS percentage
FROM bank_analytics_sql
GROUP BY Transaction_Type
ORDER BY total_transactions DESC;



    


















