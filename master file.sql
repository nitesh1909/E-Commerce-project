---SQL ANALYSIS
--revenue over time
SELECT 
    DATE(order_purchase_timestamp) AS order_date,
    SUM(price) AS total_revenue
FROM master_table
GROUP BY order_date
ORDER BY order_date;

--customer purchase behaviour

 SELECT 
    customer_unique_id,
    COUNT(DISTINCT order_id) AS total_orders
FROM master_table
GROUP BY customer_unique_id;

--RFM analysis
--recency

SELECT 
    customer_unique_id,
    MAX(order_purchase_timestamp) AS last_purchase
FROM master_table
GROUP BY customer_unique_id;

-- frequency and monetary

SELECT 
    customer_unique_id,
    COUNT(DISTINCT order_id) AS frequency,
    SUM(price) AS monetary
FROM master_table
GROUP BY customer_unique_id;

----create RFM base table
CREATE TABLE rfm_base AS
SELECT 
    customer_unique_id,
    MAX(order_purchase_timestamp) AS last_purchase,
    COUNT(DISTINCT order_id) AS frequency,
    SUM(price) AS monetary
FROM master_table
GROUP BY customer_unique_id;

--
SELECT 
    customer_unique_id,
    CURRENT_DATE - MAX(order_purchase_timestamp)::date AS recency_days
FROM master_table
GROUP BY customer_unique_id;

--
CREATE TABLE rfm AS
SELECT 
    customer_unique_id,
    CURRENT_DATE - MAX(order_purchase_timestamp)::date AS recency,
    COUNT(DISTINCT order_id) AS frequency,
    SUM(price) AS monetary
FROM master_table
GROUP BY customer_unique_id;

--
SELECT *,
NTILE(5) OVER (ORDER BY recency ASC) AS r_score
FROM rfm;

--
SELECT *,
NTILE(5) OVER (ORDER BY frequency DESC) AS f_score
FROM rfm;
--
SELECT *,
NTILE(5) OVER (ORDER BY monetary DESC) AS m_score
FROM rfm;

--
CREATE TABLE rfm_scores AS
SELECT 
    customer_unique_id,
    recency,
    frequency,
    monetary,
    NTILE(5) OVER (ORDER BY recency ASC) AS r_score,
    NTILE(5) OVER (ORDER BY frequency DESC) AS f_score,
    NTILE(5) OVER (ORDER BY monetary DESC) AS m_score
FROM rfm;

--
SELECT *,
CASE 
    WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'High Value'
    WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal'
    WHEN r_score <= 2 AND f_score <= 2 THEN 'At Risk'
    ELSE 'Regular'
END AS customer_segment
FROM rfm_scores;

---Pareto (Revenue Concentration)
SELECT 
    customer_unique_id,
    SUM(price) AS total_spent
FROM master_table
GROUP BY customer_unique_id
ORDER BY total_spent DESC;

---Repeat Customers
SELECT 
    customer_unique_id,
    COUNT(DISTINCT order_id) AS orders
FROM master_table
GROUP BY customer_unique_id
HAVING COUNT(DISTINCT order_id) > 1;

select * from rfm_scores;



