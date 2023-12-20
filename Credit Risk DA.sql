-- Application table

select COUNT(*) from bureau 
select COUNT(*) from application 

-- create new column loan duration in months
SELECT SK_ID_CURR, AMT_CREDIT, AMT_ANNUITY,
CEIL (AMT_CREDIT/AMT_ANNUITY) AS LOAN_DURATION_MONTHS
FROM application 

-- analyze factor affecting creditscore

-- checking null in data
SELECT
   EXT_SOURCE_1, EXT_SOURCE_2 , EXT_SOURCE_3 
FROM
    application
WHERE EXT_SOURCE_1 IS NULL OR EXT_SOURCE_2 IS NULL OR EXT_SOURCE_3 IS NULL

-- factor affecting credit score 
-- factor 1 by gender
SELECT CODE_GENDER, 
	AVG(COALESCE (EXT_SOURCE_1,0)) AS AVG_EXT_SOURCE_1,
	AVG(COALESCE (EXT_SOURCE_2,0)) AS AVG_EXT_SOURCE_2,
	AVG(COALESCE (EXT_SOURCE_3,0)) AS AVG_EXT_SOURCE_3
FROM application
GROUP BY CODE_GENDER

-- factor 2 by income
SELECT
    CASE
        WHEN AMT_INCOME_TOTAL  <= 30000 THEN 'Low Income'
        WHEN AMT_INCOME_TOTAL  > 30000 AND AMT_INCOME_TOTAL <= 60000 THEN 'Medium Income'
        ELSE 'High Income'
    END AS income_range,
    AVG(COALESCE (EXT_SOURCE_1,0)) AS AVG_EXT_SOURCE_1,
	AVG(COALESCE (EXT_SOURCE_2,0)) AS AVG_EXT_SOURCE_2,
	AVG(COALESCE (EXT_SOURCE_3,0)) AS AVG_EXT_SOURCE_3
FROM
    application
GROUP BY
    income_range;
   
 -- factor 3 by car and realty ownership
   SELECT
    CONCAT(FLAG_OWN_CAR, '_', FLAG_OWN_REALTY) AS OWNERSHIP_STATUS,
    AVG(COALESCE(EXT_SOURCE_1, 0)) AS AVG_EXT_SOURCE_1,
    AVG(COALESCE(EXT_SOURCE_2, 0)) AS AVG_EXT_SOURCE_2,
    AVG(COALESCE(EXT_SOURCE_3, 0)) AS AVG_EXT_SOURCE_3
FROM
    application
GROUP BY
    OWNERSHIP_STATUS;
   
 -- factor affecting credit amount
   -- factor 1 by income
 SELECT
    CASE
        WHEN AMT_INCOME_TOTAL <= 30000 THEN 'Low Income'
        WHEN AMT_INCOME_TOTAL > 30000 AND AMT_INCOME_TOTAL <= 60000 THEN 'Medium Income'
        ELSE 'High Income'
    END AS income_range,
    AVG(AMT_CREDIT) AS average_credit_amount
FROM
    application
GROUP BY
    income_range;

 -- factor 2 by number of children
SELECT CNT_CHILDREN, AVG(AMT_CREDIT) as average_credit_amount
FROM application
GROUP BY CNT_CHILDREN
ORDER BY average_credit_amount DESC;

-- factor 3 by occupation type
SELECT OCCUPATION_TYPE, AVG(AMT_CREDIT) as average_credit_amount
FROM application
GROUP BY OCCUPATION_TYPE
ORDER BY average_credit_amount DESC;

-- factor 4 by credit score

SELECT EXT_SOURCE_1, EXT_SOURCE_2, EXT_SOURCE_3, AVG(AMT_CREDIT) as average_credit_amount
FROM application
GROUP BY EXT_SOURCE_1, EXT_SOURCE_2, EXT_SOURCE_3
ORDER BY average_credit_amount ;

-- factor affecting payment difficulty
-- factor 1 by income type

SELECT
    NAME_INCOME_TYPE,
    AVG(TARGET) AS Payment_Difficulty_Rate
FROM
    application
GROUP BY
    NAME_INCOME_TYPE;
   
-- factor 2 by credit score
   
SELECT EXT_SOURCE_1, EXT_SOURCE_2, EXT_SOURCE_3, AVG(TARGET) as Payment_Difficulty_Rate
FROM application
GROUP BY EXT_SOURCE_1, EXT_SOURCE_2, EXT_SOURCE_3
ORDER BY Payment_Difficulty_Rate

-- factor 3 by ownership

SELECT FLAG_OWN_CAR, FLAG_OWN_REALTY, AVG(TARGET) as Payment_Difficulty_Rate
FROM application
GROUP BY FLAG_OWN_CAR, FLAG_OWN_REALTY
ORDER BY Payment_Difficulty_Rate;



-- Bureau table

-- Step 1: Count the number of loans for each SK_ID_CURR in the “bureau” table
WITH loan_counts AS (
    SELECT SK_ID_CURR, COUNT(*) as num_loans
    FROM bureau
    GROUP BY SK_ID_CURR),

-- Step 2: Transform the counts into count groups (Discretization)
loan_counts_grouped AS (
    SELECT SK_ID_CURR, 
    CASE 
        WHEN num_loans <= 10 THEN '0-10'
        WHEN num_loans <= 20 THEN '11-20'
        WHEN num_loans <= 30 THEN '21-30'
        ELSE '30+'
    END AS OtherLoanCountGroup
    FROM loan_counts),

-- Step 3: Compute the relation between average other loan count to the TARGET
avg_loan_count_to_target AS (
    SELECT OtherLoanCountGroup, AVG(TARGET) as avg_target
    FROM loan_counts_grouped JOIN application 
    ON loan_counts_grouped.SK_ID_CURR = application.SK_ID_CURR
    GROUP BY OtherLoanCountGroup)

SELECT * FROM avg_loan_count_to_target;



-- factors from the “application” and the “bureau” tables are affecting
-- The Credit Scores

SELECT 
	CASE WHEN AMT_CREDIT_SUM <= 10000 THEN '0-10K'
         WHEN AMT_CREDIT_SUM <= 20000 THEN '10K-20K'
         WHEN AMT_CREDIT_SUM <= 30000 THEN '20K-30K'
         ELSE '30K+'
         END AS credit_sum_group, 
       AVG(EXT_SOURCE_1) as avg_ext_source_1, 
       AVG(EXT_SOURCE_2) as avg_ext_source_2, 
       AVG(EXT_SOURCE_3) as avg_ext_source_3
FROM bureau join application ON bureau.SK_ID_CURR = application.SK_ID_CURR
GROUP BY credit_sum_group;

-- the payment difficulty

SELECT 
	CASE 
        WHEN bureau.AMT_CREDIT_SUM <= 10000 THEN '0-10K'
        WHEN bureau.AMT_CREDIT_SUM <= 20000 THEN '10K-20K'
        WHEN bureau.AMT_CREDIT_SUM <= 30000 THEN '20K-30K'
        ELSE '30K+'
        END AS credit_sum_group, 
        AVG(TARGET) AS avg_target
FROM application JOIN bureau ON application.SK_ID_CURR = bureau.SK_ID_CURR 
GROUP BY credit_sum_group;












 


