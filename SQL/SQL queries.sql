SELECT funded_at,
        MIN(raised_amount),
        MAX(raised_amount)
FROM funding_round
GROUP BY funded_at
HAVING MIN(raised_amount) <> 0
        AND MIN(raised_amount) <> MAX(raised_amount)
        
---

SELECT *,
        CASE
            WHEN invested_companies >= 100 THEN 'high_activity'
            WHEN invested_companies BETWEEN 20 AND 99 THEN 'middle_activity'
            ELSE 'low_activity'
        END
FROM fund

---

SELECT 
       CASE
           WHEN invested_companies>=100 THEN 'high_activity'
           WHEN invested_companies>=20 THEN 'middle_activity'
           ELSE 'low_activity'
       END AS activity,
       ROUND(AVG(investment_rounds))
FROM fund
GROUP BY activity
ORDER BY ROUND(AVG(investment_rounds))

---

SELECT country_code,
        MIN(invested_companies),
        MAX(invested_companies),
        AVG(invested_companies)
FROM fund
WHERE EXTRACT(YEAR FROM CAST(founded_at as timestamp)) BETWEEN 2010 AND 2012
GROUP BY country_code
HAVING MIN(invested_companies) <> 0
ORDER BY AVG(invested_companies) DESC, country_code
LIMIT 10
---
SELECT p.first_name,
        p.last_name,
        e.instituition
FROM people AS p
lEFT OUTER JOIN education AS e ON p.id=e.person_id

---

SELECT c.name,
        COUNT(DISTINCT e.instituition)        
FROM company AS c
JOIN people AS p ON c.id=p.company_id
JOIN education AS e ON p.id=e.person_id
GROUP BY c.name
ORDER BY COUNT(DISTINCT e.instituition) DESC
LIMIT 5

---

SELECT DISTINCT c.name
FROM company AS c
LEFT OUTER JOIN funding_round AS fr ON c.id=fr.company_id
WHERE c.status = 'closed'
    AND fr.is_first_round = 1
    AND fr.is_last_round = 1
    
---

SELECT DISTINCT p.id
FROM people AS p
LEFT OUTER JOIN company AS c ON p.company_id=c.id
WHERE c.name IN (SELECT DISTINCT c.name
FROM company AS c
LEFT OUTER JOIN funding_round AS fr ON c.id=fr.company_id
WHERE c.status = 'closed'
    AND fr.is_first_round = 1
    AND fr.is_last_round = 1)
    
---

SELECT  p.id,
        e.instituition
FROM people as p
LEFT OUTER JOIN company as c ON p.company_id=c.id
INNER  JOIN education as e ON p.id=e.person_id
WHERE c.name IN (SELECT DISTINCT c.name
FROM company as c
LEFT OUTER JOIN funding_round as fr ON c.id=fr.company_id
WHERE c.status = 'closed'
    AND fr.is_first_round = 1
    AND fr.is_last_round = 1)
GROUP BY  p.id, e.instituition

---

SELECT  p.id,
        COUNT(e.instituition)
FROM people as p
LEFT OUTER JOIN company as c ON p.company_id=c.id
INNER  JOIN education as e ON p.id=e.person_id
WHERE c.name IN (SELECT DISTINCT c.name
FROM company as c
LEFT OUTER JOIN funding_round as fr ON c.id=fr.company_id
WHERE c.status = 'closed'
    AND fr.is_first_round = 1
    AND fr.is_last_round = 1)
GROUP BY  p.id

---

SELECT AVG(nt.quantity)
FROM 
(SELECT  p.id,
        COUNT(e.instituition) as quantity
FROM people as p
LEFT OUTER JOIN company as c ON p.company_id=c.id
INNER  JOIN education as e ON p.id=e.person_id
WHERE c.name IN (SELECT DISTINCT c.name
FROM company as c
LEFT OUTER JOIN funding_round as fr ON c.id=fr.company_id
WHERE c.status = 'closed'
    AND fr.is_first_round = 1
    AND fr.is_last_round = 1)
GROUP BY  p.id) as nt

---

SELECT AVG(nt.quantity)
FROM 
(SELECT  p.id,
        COUNT(e.instituition) as quantity
FROM people as p
INNER JOIN company as c ON p.company_id=c.id
INNER  JOIN education as e ON p.id=e.person_id
WHERE c.name = 'Facebook'
GROUP BY  p.id) as nt

---

WITH
a AS (SELECT id,
        acquiring_company_id,
        acquired_company_id,
        price_amount
FROM acquisition 
WHERE price_amount <> 0),
c as (SELECT id,
      name,
      funding_total
FROM company 
WHERE funding_total <> 0)

SELECT c.name,
        a.price_amount,
        c.name,
        c.funding_total,
        ROUND(a.price_amount / c.funding_total)
FROM c 
LEFT OUTER JOIN a ON c.id=a.acquiring_company_id
ORDER BY a.price_amount DESC, c.name
LIMIT 10

---

WITH
buyer as (SELECT a.id as all_id,
            a.acquiring_company_id,
            c.name as buyer_name,
            a.price_amount as price
          FROM acquisition as a
          LEFT JOIN company as c ON a.acquiring_company_id=c.id
          WHERE a.price_amount <> 0),

seller as (SELECT a.id as all_id,
            a.acquired_company_id,
            c.name as seller_name
          FROM acquisition as a
          LEFT JOIN company as c ON a.acquired_company_id=c.id)

SELECT b.buyer_name,
        b.price,
        s.seller_name,
        c.funding_total,
        ROUND(b.price / c.funding_total) as rate
FROM buyer as b
INNER JOIN seller as s ON b.all_id=s.all_id
LEFT OUTER JOIN company as c ON s.acquired_company_id=c.id
WHERE c.funding_total <> 0
ORDER BY b.price DESC, s.seller_name
LIMIT 10

---

WITH
table_1 as (SELECT EXTRACT(MONTH FROM CAST(fr.funded_at as timestamp)) as rounds_month,
        COUNT(DISTINCT f.name) as unique_funds
FROM funding_round as fr
LEFT OUTER JOIN investment as i on fr.id=i.funding_round_id
LEFT OUTER JOIN fund as f on i.fund_id=f.id
WHERE f.country_code = 'USA'
    AND EXTRACT(YEAR FROM CAST(fr.funded_at as timestamp)) BETWEEN 2010 AND 2013
GROUP BY EXTRACT(MONTH FROM CAST(fr.funded_at as timestamp))),

table_2 as (SELECT EXTRACT(MONTH FROM CAST(acquired_at as timestamp)) as acquiring_month,
        COUNT(acquired_company_id) as acquired_num,
        SUM(price_amount) as total_amount
FROM acquisition
WHERE EXTRACT(YEAR FROM CAST(acquired_at as timestamp)) BETWEEN 2010 AND 2013
GROUP BY EXTRACT(MONTH FROM CAST(acquired_at as timestamp)))

SELECT table_1.rounds_month,
        table_1.unique_funds,
        table_2.acquired_num,
        table_2.total_amount
FROM table_1
INNER JOIN table_2 on table_1.rounds_month=table_2.acquiring_month
        
---

WITH
y_2011 as (SELECT country_code as country_2011,
        AVG(funding_total) as inv_in_2011
FROM company
WHERE EXTRACT(YEAR FROM CAST(founded_at as timestamp)) = 2011
GROUP BY country_code),

y_2012 as (SELECT country_code as country_2012,
        AVG(funding_total) as inv_in_2012
FROM company
WHERE EXTRACT(YEAR FROM CAST(founded_at as timestamp)) = 2012
GROUP BY country_code),

y_2013 as (SELECT country_code as country_2013,
        AVG(funding_total) as inv_in_2013
FROM company
WHERE EXTRACT(YEAR FROM CAST(founded_at as timestamp)) = 2013
GROUP BY country_code)

SELECT y_2011.country_2011,
        y_2011.inv_in_2011,
        y_2012.inv_in_2012,
        y_2013.inv_in_2013
FROM y_2011
JOIN y_2012 ON y_2011.country_2011=y_2012.country_2012
JOIN y_2013 ON y_2012.country_2012=y_2013.country_2013
ORDER BY y_2011.inv_in_2011 DESC