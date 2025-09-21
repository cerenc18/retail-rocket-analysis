USE RetailRocketDB;

----BURADA PARETO DAHA DUZGUN OLACAK SEK�LDE AYARLAND� CUNKU LONG TAIL COK UZUNNNNN 
---BUNA GORE SALES RANGE VS FARKLI
-------------------------------------------------
-- 1) Ana transaction tablosu
IF OBJECT_ID('dbo.all_transaction') IS NOT NULL DROP TABLE dbo.all_transaction;

SELECT *
INTO dbo.all_transaction
FROM events_clean
WHERE event = 'transaction';

-------------------------------------------------
-- 2) Toplam transaction say�s�
IF OBJECT_ID('dbo.total_tx') IS NOT NULL DROP TABLE dbo.total_tx;

SELECT COUNT(*) AS total_transactions
INTO dbo.total_tx
FROM dbo.all_transaction;

-------------------------------------------------
-- 3) Saatlere g�re transaction da��l�m�
IF OBJECT_ID('dbo.tx_by_hour') IS NOT NULL DROP TABLE dbo.tx_by_hour;

SELECT 
    DATEPART(HOUR, DATEADD(SECOND, [timestamp]/1000, '1970-01-01')) AS tx_hour,
    COUNT(*) AS tx_count
INTO dbo.tx_by_hour
FROM dbo.all_transaction
GROUP BY DATEPART(HOUR, DATEADD(SECOND, [timestamp]/1000, '1970-01-01'))
ORDER BY tx_hour;

-------------------------------------------------
-- 4) Item bazl� transaction say�s�
IF OBJECT_ID('dbo.tx_by_item') IS NOT NULL DROP TABLE dbo.tx_by_item;

SELECT 
    itemid,
    COUNT(*) AS tx_count
INTO dbo.tx_by_item
FROM dbo.all_transaction
GROUP BY itemid
ORDER BY tx_count DESC;

-------------------------------------------------
-- 5) Bestseller �r�nler (ilk 10)
IF OBJECT_ID('dbo.bestseller_items') IS NOT NULL DROP TABLE dbo.bestseller_items;

SELECT TOP 10 *
INTO dbo.bestseller_items
FROM dbo.tx_by_item
ORDER BY tx_count DESC;

-------------------------------------------------
-- En �ok satan ilk 10 �r�n (g�r�nt�leme i�in, tabloya gerek yok)
SELECT TOP 10 *
FROM dbo.tx_by_item
ORDER BY tx_count DESC;

-- En az satan son 10 �r�n (g�r�nt�leme i�in, tabloya gerek yok)
SELECT TOP 10 *
FROM dbo.tx_by_item
ORDER BY tx_count ASC;

-------------------------------------------------
-------------------------------------------------
-- 6) Sat�� da��l�m� (sales range i�in)
IF OBJECT_ID('dbo.tx_distribution') IS NOT NULL DROP TABLE dbo.tx_distribution;

SELECT 
    CASE 
        WHEN tx_count = 1 THEN '1'
        WHEN tx_count BETWEEN 2 AND 5 THEN '2-5'
        WHEN tx_count BETWEEN 6 AND 10 THEN '6-10'
        WHEN tx_count BETWEEN 11 AND 20 THEN '11-20'
        WHEN tx_count BETWEEN 21 AND 50 THEN '21-50'
        WHEN tx_count BETWEEN 51 AND 100 THEN '51-100'
        ELSE '100+' 
    END AS sales_range,
    COUNT(*) AS product_count,
    SUM(tx_count) AS total_tx
INTO dbo.tx_distribution
FROM dbo.tx_by_item
GROUP BY 
    CASE 
        WHEN tx_count = 1 THEN '1'
        WHEN tx_count BETWEEN 2 AND 5 THEN '2-5'
        WHEN tx_count BETWEEN 6 AND 10 THEN '6-10'
        WHEN tx_count BETWEEN 11 AND 20 THEN '11-20'
        WHEN tx_count BETWEEN 21 AND 50 THEN '21-50'
        WHEN tx_count BETWEEN 51 AND 100 THEN '51-100'
        ELSE '100+' 
    END;

-------------------------------------------------
-- 7) Pareto i�in veri haz�rl��� (gruplu)
IF OBJECT_ID('dbo.pareto_data') IS NOT NULL DROP TABLE dbo.pareto_data;

SELECT 
    sales_range,
    SUM(total_tx) AS group_tx,
    SUM(SUM(total_tx)) OVER (ORDER BY MIN(CASE WHEN sales_range LIKE '%+%' THEN 9999 ELSE CAST(PARSENAME(REPLACE(sales_range, '-', '.'),1) AS INT) END) 
                             ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_tx,
    SUM(SUM(total_tx)) OVER () AS total_tx,
    CAST(100.0 * SUM(SUM(total_tx)) OVER (ORDER BY MIN(CASE WHEN sales_range LIKE '%+%' THEN 9999 ELSE CAST(PARSENAME(REPLACE(sales_range, '-', '.'),1) AS INT) END) 
                             ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) 
         / SUM(SUM(total_tx)) OVER () AS DECIMAL(5,2)) AS cum_pct
INTO dbo.pareto_data
FROM dbo.tx_distribution
GROUP BY sales_range
ORDER BY 
    CASE 
        WHEN sales_range = '1' THEN 1
        WHEN sales_range = '2-5' THEN 2
        WHEN sales_range = '6-10' THEN 3
        WHEN sales_range = '11-20' THEN 4
        WHEN sales_range = '21-50' THEN 5
        WHEN sales_range = '51-100' THEN 6
        WHEN sales_range = '100+' THEN 7
    END;
