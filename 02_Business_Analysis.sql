USE [NHS111_Analytics];
GO


---------------------------------------------------------
-- Business Question 1
-- Which NHS organisations receive the highest demand?
---------------------------------------------------------

SELECT
    ORG_NAME,
    SUM(VALUE) AS CallsReceived
FROM dbo.Fact_IUCADC
WHERE ITEM_NUMBER = 'A01'
  AND VALUE IS NOT NULL
GROUP BY ORG_NAME
ORDER BY CallsReceived DESC;



---------------------------------------------------------
-- Business Question 2
-- Which NHS regions have the highest demand?
---------------------------------------------------------

SELECT
    REGION_NAME,
    SUM(VALUE) AS CallsReceived
FROM dbo.Fact_IUCADC
WHERE ITEM_NUMBER = 'A01'
  AND VALUE IS NOT NULL
GROUP BY REGION_NAME
ORDER BY CallsReceived DESC;


---------------------------------------------------------
-- Business Question 3
-- Monthly NHS111 demand
---------------------------------------------------------

SELECT
    REPORTING_PERIOD,
    DATEFROMPARTS(
        TRY_CONVERT(INT, RIGHT(REPORTING_PERIOD, 4)),
        CASE SUBSTRING(REPORTING_PERIOD, 16, 3)
            WHEN 'JAN' THEN 1
            WHEN 'FEB' THEN 2
            WHEN 'MAR' THEN 3
            WHEN 'APR' THEN 4
            WHEN 'MAY' THEN 5
            WHEN 'JUN' THEN 6
            WHEN 'JUL' THEN 7
            WHEN 'AUG' THEN 8
            WHEN 'SEP' THEN 9
            WHEN 'OCT' THEN 10
            WHEN 'NOV' THEN 11
            WHEN 'DEC' THEN 12
        END,
        1
    ) AS ReportingDate,
    SUM(VALUE) AS CallsReceived
FROM dbo.Fact_IUCADC
WHERE ITEM_NUMBER = 'A01'
  AND VALUE IS NOT NULL
GROUP BY REPORTING_PERIOD
ORDER BY ReportingDate;

---------------------------------------------------------
-- Business Question 4
-- Top contracts by demand
---------------------------------------------------------

SELECT
    CONTRACT_NAME,
    SUM(VALUE) AS CallsReceived
FROM dbo.Fact_IUCADC
WHERE ITEM_NUMBER = 'A01'
  AND VALUE IS NOT NULL
GROUP BY CONTRACT_NAME
ORDER BY CallsReceived DESC;



---------------------------------------------------------
-- Business Question 5
-- KPI activity
---------------------------------------------------------
SELECT
    ITEM_NUMBER,
    SUM(VALUE) AS TotalRecordedValue
FROM dbo.Fact_IUCADC
WHERE VALUE IS NOT NULL
GROUP BY ITEM_NUMBER
ORDER BY TotalRecordedValue DESC;
