SELECT * FROM bank.bank_data_1;
-- Total number of loans
SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT `Account ID`) AS total_accounts
FROM bank_data_1;
-- Overall loan portfolio KPIs
SELECT
    COUNT(*) AS total_loans,
    SUM(`Loan Amount`) AS total_loan_amount,
    SUM(`Funded Amount`) AS total_funded_amount,
    ROUND(AVG(`Loan Amount`), 2) AS avg_loan_amount,
    SUM(`Total Pymnt`) AS total_repayments,
    SUM(Recoveries) AS total_recoveries
FROM bank_data_1;
ALTER TABLE bank_data_1
    RENAME COLUMN `Age` TO age,
    RENAME COLUMN `BH Name` TO bh_name,
    RENAME COLUMN `Bank Name` TO bank_name,
    RENAME COLUMN `Caste` TO caste,
    RENAME COLUMN `Center Id` TO center_id,
    RENAME COLUMN `City` TO city,
    RENAME COLUMN `Client ID` TO client_id,
    RENAME COLUMN `Disbursement Officer` TO disbursement_officer,
    RENAME COLUMN `Disbursement Date (Years)` TO disbursement_date_years,
    RENAME COLUMN `Gender ID` TO gender_id,
    RENAME COLUMN `Home Ownership` TO home_ownership,
    RENAME COLUMN `Loan Status` TO loan_status,
    RENAME COLUMN `Loan Transfer Date` TO loan_transfer_date,
    RENAME COLUMN `Next Meeting Date` TO next_meeting_date,
    RENAME COLUMN `Grade` TO grade,
    RENAME COLUMN `Sub Grade` TO sub_grade,
    RENAME COLUMN `Product Id` TO product_id,
    RENAME COLUMN `Region Name` TO region_name,
    RENAME COLUMN `Religion` TO religion,
    RENAME COLUMN `Verification Status` TO verification_status,
    RENAME COLUMN `State Abbr` TO state_abbr,
    RENAME COLUMN `State Name` TO state_name,
    RENAME COLUMN `Transfer Logic` TO transfer_logic,
    RENAME COLUMN `Is Delinquent Loan` TO is_delinquent_loan,
    RENAME COLUMN `Is Default Loan` TO is_default_loan,
    RENAME COLUMN `Age_T` TO age_t,
    RENAME COLUMN `Delinq 2 Yrs` TO delinq_2_yrs,
    RENAME COLUMN `Application Type` TO application_type,
    RENAME COLUMN `Funded Amount Inv` TO funded_amount_inv,
    RENAME COLUMN `Term` TO term,
    RENAME COLUMN `Int Rate` TO int_rate,
    RENAME COLUMN `Total Pymnt inv` TO total_pymnt_inv,
    RENAME COLUMN `Total Rec Prncp` TO total_rec_prncp,
    RENAME COLUMN `Total Fees` TO total_fees,
    RENAME COLUMN `Total Rrec int` TO total_rrec_int,
    RENAME COLUMN `Total Rec Late fee` TO total_rec_late_fee,
    RENAME COLUMN `Recoveries` TO recoveries,
    RENAME COLUMN `Collection Recovery fee` TO collection_recovery_fee,
    RENAME COLUMN `Date_Consistency_Flag` TO date_consistency_flag,
   RENAME COLUMN `Account ID` TO account_id,
    RENAME COLUMN `Client Name` TO client_name,
    RENAME COLUMN `Close Client` TO close_client,
    RENAME COLUMN `Closed Date` TO closed_date,
    RENAME COLUMN `Credit Officer Name` TO credit_officer_name,
    RENAME COLUMN `Date of Birth` TO date_of_birth,
    RENAME COLUMN `Disbursement Date` TO disbursement_date,
    RENAME COLUMN `Loan Amount` TO loan_amount,
    RENAME COLUMN `Funded Amount` TO funded_amount,
    RENAME COLUMN `Total Pymnt` TO total_pymnt,
    RENAME COLUMN `Branch Name` TO branch_name,
    RENAME COLUMN `Product Code` TO product_code,
    RENAME COLUMN `Purpose Category` TO purpose_category,
    RENAME COLUMN `Default Flag` TO default_flag,
    RENAME COLUMN `Delinquent Flag` TO delinquent_flag;
    DESCRIBE bank_data_1;
    
-- PROJECT: Banking Analytics using MySQL
-- TABLE: bank_data_1



-- =========================================================
-- PHASE 1: DATA VALIDATION AND CLEANING
-- =========================================================

-- Q1. How many records are present in the dataset?
SELECT COUNT(*) AS total_records
FROM bank_data_1;

-- Q2. Are there duplicate account IDs?
SELECT account_id, COUNT(*) AS record_count
FROM bank_data_1
GROUP BY account_id
HAVING COUNT(*) > 1
ORDER BY record_count DESC;

-- Q3. Which selected columns contain missing values?
SELECT
    SUM(CASE WHEN account_id IS NULL OR TRIM(account_id) = '' THEN 1 ELSE 0 END) AS missing_account_id,
    SUM(CASE WHEN client_name IS NULL OR TRIM(client_name) = '' THEN 1 ELSE 0 END) AS missing_client_name,
    SUM(CASE WHEN loan_amount IS NULL THEN 1 ELSE 0 END) AS missing_loan_amount,
    SUM(CASE WHEN funded_amount IS NULL THEN 1 ELSE 0 END) AS missing_funded_amount,
    SUM(CASE WHEN loan_status IS NULL OR TRIM(loan_status) = '' THEN 1 ELSE 0 END) AS missing_loan_status,
    SUM(CASE WHEN branch_name IS NULL OR TRIM(branch_name) = '' THEN 1 ELSE 0 END) AS missing_branch_name
FROM bank_data_1;

-- Q4. Are there invalid or negative loan amounts?
SELECT *
FROM bank_data_1
WHERE loan_amount < 0
   OR funded_amount < 0
   OR loan_amount IS NULL
   OR funded_amount IS NULL;

-- =========================================================
-- PHASE 2: OVERALL LOAN PORTFOLIO ANALYSIS
-- =========================================================

-- Q5. What are the total loans, loan amount, funded amount, average loan amount, repayments, and recoveries?
SELECT
    COUNT(*) AS total_loans,
    SUM(loan_amount) AS total_loan_amount,
    SUM(funded_amount) AS total_funded_amount,
    ROUND(AVG(loan_amount), 2) AS average_loan_amount,
    SUM(total_pymnt) AS total_repayments,
    SUM(recoveries) AS total_recoveries
FROM bank_data_1;

-- Q6. How are loans distributed across different loan statuses?
SELECT
    loan_status,
    COUNT(*) AS total_loans,
    SUM(loan_amount) AS total_loan_amount,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bank_data_1), 2) AS loan_percentage
FROM bank_data_1
GROUP BY loan_status
ORDER BY total_loans DESC;

-- Q7. What is the average loan amount for each loan term?
SELECT
    term,
    COUNT(*) AS total_loans,
    ROUND(AVG(loan_amount), 2) AS average_loan_amount,
    SUM(funded_amount) AS total_funded_amount
FROM bank_data_1
GROUP BY term
ORDER BY average_loan_amount DESC;

-- =========================================================
-- PHASE 3: DEFAULT AND DELINQUENCY ANALYSIS
-- =========================================================

-- Q8. What is the overall loan default rate?
SELECT
    COUNT(*) AS total_records,
    SUM(CASE WHEN default_flag = 1 THEN 1 ELSE 0 END) AS defaulted_loans,
    ROUND(
        SUM(CASE WHEN default_flag = 1 THEN 1 ELSE 0 END) * 100.0 /
        NULLIF(SUM(CASE WHEN default_flag IN (0, 1) THEN 1 ELSE 0 END), 0),
        2
    ) AS default_rate_percentage
FROM bank_data_1;

-- Q9. What is the overall delinquency rate?
SELECT
    COUNT(*) AS total_records,
    SUM(CASE WHEN delinquent_flag = 1 THEN 1 ELSE 0 END) AS delinquent_loans,
    ROUND(
        SUM(CASE WHEN delinquent_flag = 1 THEN 1 ELSE 0 END) * 100.0 /
        NULLIF(SUM(CASE WHEN delinquent_flag IN (0, 1) THEN 1 ELSE 0 END), 0),
        2
    ) AS delinquency_rate_percentage
FROM bank_data_1;

-- Q10. Which branches have the highest default rates?
SELECT
    branch_name,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN default_flag = 1 THEN 1 ELSE 0 END) AS defaulted_loans,
    ROUND(
        SUM(CASE WHEN default_flag = 1 THEN 1 ELSE 0 END) * 100.0 /
        NULLIF(SUM(CASE WHEN default_flag IN (0, 1) THEN 1 ELSE 0 END), 0),
        2
    ) AS default_rate
FROM bank_data_1
GROUP BY branch_name
HAVING COUNT(*) >= 50
ORDER BY default_rate DESC;

-- Q11. Which loans are flagged as defaulted or delinquent?
SELECT
    account_id, client_name, branch_name, city, loan_amount,
    loan_status, default_flag, delinquent_flag
FROM bank_data_1
WHERE default_flag = 1 OR delinquent_flag = 1
ORDER BY loan_amount DESC
LIMIT 100;

-- =========================================================
-- PHASE 4: BRANCH, CITY, AND PRODUCT ANALYSIS
-- =========================================================

-- Q12. Which branches have the highest funded amounts?
SELECT
    branch_name,
    COUNT(*) AS total_loans,
    SUM(loan_amount) AS total_loan_amount,
    SUM(funded_amount) AS total_funded_amount,
    SUM(total_pymnt) AS total_repayments,
    ROUND(AVG(loan_amount), 2) AS average_loan_amount
FROM bank_data_1
GROUP BY branch_name
ORDER BY total_funded_amount DESC;

-- Q13. Which cities have the highest loan amounts and default rates?
SELECT
    city,
    COUNT(*) AS total_loans,
    SUM(loan_amount) AS total_loan_amount,
    SUM(CASE WHEN default_flag = 1 THEN 1 ELSE 0 END) AS defaulted_loans,
    ROUND(
        SUM(CASE WHEN default_flag = 1 THEN 1 ELSE 0 END) * 100.0 /
        NULLIF(SUM(CASE WHEN default_flag IN (0, 1) THEN 1 ELSE 0 END), 0),
        2
    ) AS default_rate
FROM bank_data_1
GROUP BY city
HAVING COUNT(*) >= 50
ORDER BY total_loan_amount DESC;

-- Q14. How does loan performance vary by product and purpose?
SELECT
    product_code,
    purpose_category,
    COUNT(*) AS total_loans,
    SUM(loan_amount) AS total_loan_amount,
    SUM(funded_amount) AS total_funded_amount,
    SUM(CASE WHEN default_flag = 1 THEN 1 ELSE 0 END) AS defaulted_loans
FROM bank_data_1
GROUP BY product_code, purpose_category
ORDER BY total_funded_amount DESC;

-- =========================================================
-- PHASE 5: CUSTOMER AND CREDIT RISK ANALYSIS
-- =========================================================

-- Q15. Which customer age groups have the highest default rates?
SELECT
    CASE
        WHEN age_t < 25 THEN 'Below 25'
        WHEN age_t BETWEEN 25 AND 34 THEN '25-34'
        WHEN age_t BETWEEN 35 AND 44 THEN '35-44'
        WHEN age_t BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55 and Above'
    END AS age_group,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN default_flag = 1 THEN 1 ELSE 0 END) AS defaulted_loans,
    ROUND(
        SUM(CASE WHEN default_flag = 1 THEN 1 ELSE 0 END) * 100.0 /
        NULLIF(SUM(CASE WHEN default_flag IN (0, 1) THEN 1 ELSE 0 END), 0),
        2
    ) AS default_rate
FROM bank_data_1
WHERE age_t IS NOT NULL
GROUP BY age_group
ORDER BY default_rate DESC;

-- Q16. Which loan grades and sub-grades have the highest default rates?
SELECT
    grade,
    sub_grade,
    COUNT(*) AS total_loans,
    ROUND(AVG(int_rate), 2) AS average_interest_rate,
    SUM(CASE WHEN default_flag = 1 THEN 1 ELSE 0 END) AS defaulted_loans,
    ROUND(
        SUM(CASE WHEN default_flag = 1 THEN 1 ELSE 0 END) * 100.0 /
        NULLIF(SUM(CASE WHEN default_flag IN (0, 1) THEN 1 ELSE 0 END), 0),
        2
    ) AS default_rate
FROM bank_data_1
GROUP BY grade, sub_grade
ORDER BY default_rate DESC;

-- Q17. How does home ownership relate to loan defaults?
SELECT
    home_ownership,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN default_flag = 1 THEN 1 ELSE 0 END) AS defaulted_loans,
    ROUND(
        SUM(CASE WHEN default_flag = 1 THEN 1 ELSE 0 END) * 100.0 /
        NULLIF(SUM(CASE WHEN default_flag IN (0, 1) THEN 1 ELSE 0 END), 0),
        2
    ) AS default_rate
FROM bank_data_1
GROUP BY home_ownership
ORDER BY default_rate DESC;

-- =========================================================
-- PHASE 6: REPAYMENT ANALYSIS
-- =========================================================

-- Q18. What is the repayment-to-loan ratio for each loan status?
SELECT
    loan_status,
    COUNT(*) AS total_loans,
    SUM(loan_amount) AS total_loan_amount,
    SUM(total_pymnt) AS total_repayments,
    ROUND(
        SUM(total_pymnt) * 100.0 / NULLIF(SUM(loan_amount), 0), 2
    ) AS repayment_to_loan_percentage
FROM bank_data_1
GROUP BY loan_status
ORDER BY repayment_to_loan_percentage DESC;

-- Q19. Which loans have the highest recoveries?
SELECT
    account_id, client_name, branch_name, loan_amount, recoveries, default_flag
FROM bank_data_1
ORDER BY recoveries DESC
LIMIT 20;

-- Q20. How can loans be categorized by loan amount?
SELECT
    CASE
        WHEN loan_amount < 5000 THEN 'Small Loan'
        WHEN loan_amount < 15000 THEN 'Medium Loan'
        ELSE 'Large Loan'
    END AS loan_category,
    COUNT(*) AS total_loans,
    SUM(loan_amount) AS total_loan_amount,
    ROUND(AVG(loan_amount), 2) AS average_loan_amount
FROM bank_data_1
GROUP BY loan_category
ORDER BY total_loan_amount DESC;

-- =========================================================
-- PHASE 7: DATA QUALITY ANALYSIS
-- =========================================================

-- Q21. How many records fall under each date consistency category?
SELECT
    date_consistency_flag,
    COUNT(*) AS total_records
FROM bank_data_1
GROUP BY date_consistency_flag
ORDER BY total_records DESC;

-- Q22. Which records have date consistency issues?
SELECT
    account_id, client_name, closed_date, disbursement_date,
    date_consistency_flag
FROM bank_data_1
WHERE date_consistency_flag IS NULL
   OR date_consistency_flag <> 'OK'
LIMIT 100;

-- Q23. Which records have missing critical information?
SELECT *
FROM bank_data_1
WHERE account_id IS NULL
   OR client_name IS NULL
   OR loan_amount IS NULL
   OR funded_amount IS NULL
   OR loan_status IS NULL
   OR branch_name IS NULL;
