CREATE TABLE customers(
	customer_id VARCHAR(10) PRIMARY KEY,
	person_age INT,
	person_gender VARCHAR(20),
	person_education VARCHAR(50),
	person_income NUMERIC,
	person_emp_exp INT,
	person_home_ownership VARCHAR(30)
);

CREATE TABLE loans (
    loan_id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(10),
    loan_amnt NUMERIC,
    loan_intent VARCHAR(50),
    loan_int_rate NUMERIC,
    loan_percent_income NUMERIC,
    loan_status INT,
    FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id)
);

CREATE TABLE credit_history (
    customer_id VARCHAR(10) PRIMARY KEY,
    cb_person_cred_hist_length INT,
    credit_score INT,
    previous_loan_defaults_on_file VARCHAR(10),
    FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id)
);
DROP TABLE credit_history;

--customer table--
COPY customers(customer_id,person_age,person_gender,person_education,person_income,person_emp_exp,person_home_ownership
) FROM 'D:\data analysis projects\Banking Loan Risk & Customer Analytics\customers.csv'
DELIMITER ','
CSV HEADER;

SELECT *FROM customers LIMIT 10;

--loans table--
COPY loans(customer_id,loan_id,loan_amnt,loan_intent,loan_int_rate,loan_percent_income,loan_status
) FROM 'D:\data analysis projects\Banking Loan Risk & Customer Analytics\loans.csv'
DELIMITER ','
CSV HEADER;

SELECT *FROM loans LIMIT 10;

--credit history table--
COPY credit_history(customer_id,cb_person_cred_hist_length,credit_score,previous_loan_defaults_on_file
) FROM 'D:\data analysis projects\Banking Loan Risk & Customer Analytics\credit_history.csv'
DELIMITER ','
CSV HEADER;

SELECT *FROM credit_history LIMIT 10;

--check record count--
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM loans;
SELECT COUNT(*) FROM credit_history;

--Join all three tables--
SELECT 
	c.customer_id,
	c.person_age,
	c.person_gender,
	c.person_income,
	l.loan_amnt,
	l.loan_intent,
	l.loan_status,
	ch.credit_score,
	ch.previous_loan_defaults_on_file
FROM customers c
JOIN loans l
ON c.customer_id = l.customer_id
JOIN credit_history ch
ON c.customer_id = ch.customer_id;

--Instead of writing the JOIN every time, create a reusable view--
CREATE VIEW final_loan_data AS
SELECT
    c.customer_id,
    c.person_age,
    c.person_gender,
    c.person_education,
    c.person_income,
    c.person_emp_exp,
    c.person_home_ownership,
    l.loan_id,
    l.loan_amnt,
    l.loan_intent,
    l.loan_int_rate,
    l.loan_percent_income,
    l.loan_status,
    ch.cb_person_cred_hist_length,
    ch.credit_score,
    ch.previous_loan_defaults_on_file
FROM customers c
JOIN loans l
ON c.customer_id = l.customer_id
JOIN credit_history ch
ON c.customer_id = ch.customer_id;

SELECT *FROM final_loan_data;
--Total Customers--
SELECT COUNT(*) AS total_customers
FROM customers;
--Total Loan Amount--
SELECT SUM(loan_amnt) AS total_loan_amount
FROM loans;
--Average Loan Amount--
SELECT ROUND(AVG(loan_amnt),2) AS average_loan
FROM loans;
--Maximum Loan Amount--
SELECT MAX(loan_amnt) AS highest_loan
FROM loans;
--Minimum Loan Amount--
SELECT MIN(loan_amnt) AS lowest_loan
FROM loans;
--Average Customer Income--
SELECT ROUND(AVG(person_income),2) AS avg_income
FROM customers;
--Highest Income Customer--
SELECT *FROM customers
ORDER BY person_income DESC
LIMIT 1;
--Lowest Income Customer--
SELECT *FROM customers
ORDER BY person_income ASC
LIMIT 1;
--Average Credit Score--
SELECT ROUND(AVG(credit_score),2) AS avg_cred_score
FROM credit_history;
--Highest Credit Score--
SELECT MAX(credit_score)
FROM credit_history;
--Customers by Gender--
SELECT person_gender,
COUNT(*) AS total_customers
FROM customers
GROUP BY person_gender;
--Average Income by Education--
SELECT person_education,
ROUND(AVG(person_income),2) AS avg_income
FROM customers
GROUP BY person_education
ORDER BY avg_income DESC;
--Loan Amount by Loan Purpose--
SELECT loan_intent,
SUM(loan_amnt) AS total_loan
FROM loans
GROUP BY loan_intent
ORDER BY total_loan DESC;
--Average Interest Rate by Loan Purpose--
SELECT loan_intent,
ROUND(AVG(loan_int_rate),2) AS avg_interst
FROM loans
GROUP BY loan_intent;
--Customers by Home Ownership--
SELECT person_home_ownership,
COUNT(*) FRom customers
GROUP BY person_home_ownership;

--JOIN Queries--

--Customer Income and Loan Amount--
SELECT c.customer_id,c.person_income,l.loan_amnt
FROM customers c
JOIN loans l
ON c.customer_id=l.customer_id;
--High Credit Score Customers--
SELECT c.customer_id,c.person_income,ch.credit_score
FROM customers c
JOIN credit_history ch
ON c.customer_id=ch.customer_id
ORDER BY credit_score DESC;
--Previous Loan Defaulters--
SELECT c.customer_id,c.person_income,ch.previous_loan_defaults_on_file
FROM customers c
JOIN credit_history ch
ON c.customer_id=ch.customer_id
WHERE previous_loan_defaults_on_file='Yes';

--Income Category--
SELECT customer_id,person_income,
CASE 
WHEN person_income<30000 THEN 'Low Income'
WHEN person_income BETWEEN 30000 AND 70000 THEN 'Medium Income'
ELSE 'High Income'
END AS income_category
FROM customers;
--Risk Category--
SELECT customer_id,credit_score,
CASE
WHEN credit_score<600 THEN 'High Risk'
WHEN credit_score BETWEEN 600 AND 750 THEN 'Medium Risk'
ELSE 'Low Risk'
END AS risk_level
FROM credit_history;

--Top 10 Highest Loan Amounts--
SELECT loan_id,customer_id,loan_amnt
FROM loans
ORDER BY loan_amnt DESC
LIMIT 10;
--Top 10 Highest Income Customers--
SELECT customer_id,person_income
FROM customers
ORDER BY person_income DESC
LIMIT 10;
--Customers with Credit Score Above 750--
SELECT *FROM credit_history
WHERE credit_score>750;
--Previous Loan Defaulters--
SELECT *FROM credit_history
WHERE previous_loan_defaults_on_file='Yes';
--Average Loan Amount by Home Ownership--
SELECT c.person_home_ownership,
	   ROUND(AVG(loan_amnt),2) AS avg_loan
FROM customers c
JOIN loans l
ON c.customer_id=l.customer_id
GROUP BY c.person_home_ownership
ORDER BY avg_loan DESC;
--Loan Approval Count--
SELECT loan_status,
	   COUNT(*) AS total_loans
FROM loans
GROUP BY loan_status;
--Highest Loan by Loan Purpose--
SELECT loan_intent,
	   MAX(loan_amnt) AS highest_loan
FROM loans
GROUP BY loan_intent;
--Income and Credit Score Analysis--
SELECT c.customer_id,
	   c.person_income,
	   ch.credit_score
FROM customers c
JOIN credit_history ch
ON c.customer_id=ch.customer_id
ORDER BY ch.credit_score DESC;
--CTE (Common Table Expression)--
WITH high_income AS
(
SELECT *FROM customers
WHERE person_income > 100000
)
SELECT *FROM high_income;

--Customers with Income Above Average--
SELECT customer_id,
	   person_income
FROM customers
WHERE person_income >
(
SELECT AVG(person_income) AS avg_income
FROM customers
);
--ROW_NUMBER()--
SELECT customer_id,person_income,
	   ROW_NUMBER() OVER(ORDER BY person_income DESC) AS income_rank
FROM customers;
--RANK()--
SELECT customer_id,loan_amnt,
	   RANK() OVER(ORDER BY loan_amnt DESC) AS loan_rank
FROM loans;
--DENSE_RANK()--
SELECT customer_id,
	   credit_score,
	   DENSE_RANK() OVER(ORDER BY credit_score DESC) AS credit_rank
FROM credit_history;
--Running Total of Loan Amount--
SELECT loan_id,
	   loan_amnt,
	   SUM(loan_amnt) OVER(ORDER BY loan_id) AS running_total
FROM loans;
--NTILE()Divides customers into 4 equal groups based on credit score.--
SELECT customer_id,credit_score,
	   NTILE(4) OVER(ORDER BY credit_score DESC) AS quartile
FROM credit_history;
--Create High-Risk Customers View--
CREATE VIEW high_risk_customer AS
SELECT
	c.customer_id,
	c.person_income,
	ch.credit_score,
	ch.previous_loan_defaults_on_file
FROM customers c
JOIN credit_history ch
ON c.customer_id=ch.customer_id
WHERE ch.credit_score<600
OR ch.previous_loan_defaults_on_file='Yes';

SELECT *
FROM high_risk_customer;
--Average Income by Risk Category--
SELECT CASE
WHEN credit_score<600 THEN 'High Risk'
WHEN credit_score BETWEEN 600 AND 750 THEN 'Medium Risk'
ELSE 'Low Risk'
END AS risk_category,
ROUND(AVG(person_income),2) AS avg_income
FROM customers c
JOIN credit_history ch
ON c.customer_id=ch.customer_id
GROUP BY risk_category;
--Top 5 Loan Purposes--
SELECT loan_intent,
	   COUNT(*) AS total
FROM loans
GROUP BY loan_intent
ORDER BY total DESC
LIMIT 5;

--Final Business Report--
SELECT
c.person_gender,
c.person_education,
l.loan_intent,
COUNT(*) AS total_customers,
ROUND(AVG(c.person_income),2) AS avg_income,
ROUND(AVG(l.loan_amnt),2) AS avg_loan,
ROUND(AVG(ch.credit_score),2) AS avg_credit_score
FROM customers c
JOIN loans l
ON c.customer_id=l.customer_id
JOIN credit_history ch
ON c.customer_id=ch.customer_id
GROUP BY
c.person_gender,
c.person_education,
l.loan_intent
ORDER BY total_customers DESC;
