USE RetailRocketDB;

-- ==============================================
-- 1) Temel Veri Kalitesi + Null Oranlarý
-- ==============================================
IF OBJECT_ID('tempdb..#null_summary') IS NOT NULL DROP TABLE #null_summary;
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN event IS NULL THEN 1 ELSE 0 END) AS null_events,
    ROUND(100.0 * SUM(CASE WHEN event IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS null_events_pct,
    SUM(CASE WHEN timestamp IS NULL THEN 1 ELSE 0 END) AS null_timestamps,
    ROUND(100.0 * SUM(CASE WHEN timestamp IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS null_timestamps_pct,
    SUM(CASE WHEN visitorid IS NULL THEN 1 ELSE 0 END) AS null_visitors,
    ROUND(100.0 * SUM(CASE WHEN visitorid IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS null_visitors_pct,
    SUM(CASE WHEN transactionid IS NULL THEN 1 ELSE 0 END) AS null_transactions,
    ROUND(100.0 * SUM(CASE WHEN transactionid IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS null_transactions_pct
INTO #null_summary
FROM EVENTS;

-- Eðer tablo yoksa oluþtur
IF OBJECT_ID('dbo.null_summary', 'U') IS NULL
    SELECT * INTO dbo.null_summary FROM #null_summary;


-- ==============================================
-- 2) Zaman Aralýðý Kontrolü + UTC Netliði
-- ==============================================
IF OBJECT_ID('tempdb..#date_range') IS NOT NULL DROP TABLE #date_range;
SELECT 
    MIN(DATEADD(SECOND, [timestamp]/1000, '1970-01-01')) AS min_date_utc,
    MAX(DATEADD(SECOND, [timestamp]/1000, '1970-01-01')) AS max_date_utc,
    DATEDIFF(DAY, 
        MIN(DATEADD(SECOND, [timestamp]/1000, '1970-01-01')),
        MAX(DATEADD(SECOND, [timestamp]/1000, '1970-01-01'))
    ) AS total_days
INTO #date_range
FROM EVENTS;

IF OBJECT_ID('dbo.date_range', 'U') IS NULL
    SELECT * INTO dbo.date_range FROM #date_range;


-- ==============================================
-- 3) Duplicate Temizleme ve Temiz Tablo
-- ==============================================
IF OBJECT_ID('dbo.EVENTS_CLEAN', 'U') IS NULL
BEGIN
    SELECT *
    INTO dbo.EVENTS_CLEAN
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY visitorid, itemid, event, timestamp, transactionid
                   ORDER BY (SELECT NULL)
               ) AS rn
        FROM EVENTS
    ) t
    WHERE rn = 1; -- sadece ilk kayýt, tekrarlayanlar atýlýr
END


-- ==============================================
-- 4) Event Türleri ve Daðýlýmý
-- ==============================================
IF OBJECT_ID('tempdb..#event_types') IS NOT NULL DROP TABLE #event_types;
SELECT 
    event, 
    COUNT(*) AS event_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM events_clean), 2) AS percentage
INTO #event_types
FROM events_clean
GROUP BY event
ORDER BY event_count DESC;

IF OBJECT_ID('dbo.event_types', 'U') IS NULL
    SELECT * INTO dbo.event_types FROM #event_types;


-- ==============================================
-- 5) Günlük / Haftalýk / Aylýk Yoðunluk
-- ==============================================
IF OBJECT_ID('tempdb..#daily_events') IS NOT NULL DROP TABLE #daily_events;
SELECT 
    CAST(DATEADD(SECOND, [timestamp]/1000, '1970-01-01') AS DATE) AS event_date,
    COUNT(*) AS events_per_day
INTO #daily_events
FROM events_clean
GROUP BY CAST(DATEADD(SECOND, [timestamp]/1000, '1970-01-01') AS DATE);

IF OBJECT_ID('dbo.daily_events', 'U') IS NULL
    SELECT * INTO dbo.daily_events FROM #daily_events;


-- Haftalýk
IF OBJECT_ID('tempdb..#weekly_events') IS NOT NULL DROP TABLE #weekly_events;
SELECT 
    DATEPART(YEAR, DATEADD(SECOND, [timestamp]/1000, '1970-01-01')) AS year,
    DATEPART(WEEK, DATEADD(SECOND, [timestamp]/1000, '1970-01-01')) AS week,
    COUNT(*) AS events_per_week
INTO #weekly_events
FROM events_clean
GROUP BY DATEPART(YEAR, DATEADD(SECOND, [timestamp]/1000, '1970-01-01')), 
         DATEPART(WEEK, DATEADD(SECOND, [timestamp]/1000, '1970-01-01'));

IF OBJECT_ID('dbo.weekly_events', 'U') IS NULL
    SELECT * INTO dbo.weekly_events FROM #weekly_events;


-- Aylýk
IF OBJECT_ID('tempdb..#monthly_events') IS NOT NULL DROP TABLE #monthly_events;
SELECT 
    DATEPART(YEAR, DATEADD(SECOND, [timestamp]/1000, '1970-01-01')) AS year,
    DATEPART(MONTH, DATEADD(SECOND, [timestamp]/1000, '1970-01-01')) AS month,
    COUNT(*) AS events_per_month
INTO #monthly_events
FROM events_clean
GROUP BY DATEPART(YEAR, DATEADD(SECOND, [timestamp]/1000, '1970-01-01')), 
         DATEPART(MONTH, DATEADD(SECOND, [timestamp]/1000, '1970-01-01'));

IF OBJECT_ID('dbo.monthly_events', 'U') IS NULL
    SELECT * INTO dbo.monthly_events FROM #monthly_events;


-- ==============================================
-- 6) Saat Bazlý Event Yoðunluðu
-- ==============================================
IF OBJECT_ID('tempdb..#hourly_events') IS NOT NULL DROP TABLE #hourly_events;
SELECT 
    DATEPART(HOUR, DATEADD(SECOND, [timestamp]/1000, '1970-01-01')) AS event_hour,
    COUNT(*) AS events_per_hour
INTO #hourly_events
FROM events_clean
GROUP BY DATEPART(HOUR, DATEADD(SECOND, [timestamp]/1000, '1970-01-01'));

IF OBJECT_ID('dbo.hourly_events', 'U') IS NULL
    SELECT * INTO dbo.hourly_events FROM #hourly_events;


-- ==============================================
-- 7) Funnel Analizi
-- ==============================================
IF OBJECT_ID('tempdb..#funnel_analysis') IS NOT NULL DROP TABLE #funnel_analysis;
WITH OrderedEvents AS (
    SELECT 
        visitorid,
        event,
        DATEADD(SECOND, [timestamp]/1000, '1970-01-01') AS event_time,
        ROW_NUMBER() OVER (PARTITION BY visitorid ORDER BY timestamp) AS event_order
    FROM events_clean
)
SELECT 
    event_order,
    COUNT(DISTINCT visitorid) AS users_at_step,
    ROUND(100.0 * COUNT(DISTINCT visitorid) / 
          (SELECT COUNT(DISTINCT visitorid) FROM OrderedEvents), 2) AS pct_users
INTO #funnel_analysis
FROM OrderedEvents
GROUP BY event_order;

IF OBJECT_ID('dbo.funnel_analysis', 'U') IS NULL
    SELECT * INTO dbo.funnel_analysis FROM #funnel_analysis;


-- ==============================================
-- 8) Outlier Kontrolü
-- ==============================================
IF OBJECT_ID('tempdb..#outlier_users') IS NOT NULL DROP TABLE #outlier_users;
SELECT 
    visitorid,
    COUNT(*) AS total_events
INTO #outlier_users
FROM events_clean
GROUP BY visitorid
HAVING COUNT(*) > (
    SELECT AVG(event_count) + 3 * STDEV(event_count)
    FROM (
        SELECT COUNT(*) AS event_count
        FROM events_clean
        GROUP BY visitorid
    ) t
);

IF OBJECT_ID('dbo.outlier_users', 'U') IS NULL
    SELECT * INTO dbo.outlier_users FROM #outlier_users;
	----mostprofeda ile ayný ama tke fark bunda her bir sonucu tabloya ekiyoruz. oburu tbaloya eklemeden ekranda olusturuyor 