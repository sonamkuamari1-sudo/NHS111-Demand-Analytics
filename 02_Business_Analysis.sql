---------------------------------------------------------
-- Business Question 1
-- Which NHS organisations receive the highest demand?
---------------------------------------------------------

SELECT
    ORG_NAME,
    SUM(VALUE) AS TotalDemand
FROM dbo.Fact_IUCADC
WHERE VALUE IS NOT NULL
GROUP BY ORG_NAME
ORDER BY TotalDemand DESC;



---------------------------------------------------------
-- Business Question 2
-- Which NHS regions have the highest demand?
---------------------------------------------------------

SELECT
    REGION_NAME,
    SUM(VALUE) AS TotalDemand
FROM dbo.Fact_IUCADC
WHERE VALUE IS NOT NULL
GROUP BY REGION_NAME
ORDER BY TotalDemand DESC;



---------------------------------------------------------
-- Business Question 3
-- Monthly NHS111 demand
---------------------------------------------------------

SELECT
    REPORTING_PERIOD,
    SUM(VALUE) AS MonthlyDemand
FROM dbo.Fact_IUCADC
WHERE VALUE IS NOT NULL
GROUP BY REPORTING_PERIOD
ORDER BY REPORTING_PERIOD;



---------------------------------------------------------
-- Business Question 4
-- Top contracts by demand
---------------------------------------------------------

SELECT
    CONTRACT_NAME,
    SUM(VALUE) AS TotalDemand
FROM dbo.Fact_IUCADC
WHERE VALUE IS NOT NULL
GROUP BY CONTRACT_NAME
ORDER BY TotalDemand DESC;



---------------------------------------------------------
-- Business Question 5
-- KPI activity
---------------------------------------------------------

SELECT
    ITEM_NUMBER,
    SUM(VALUE) AS KPIValue
FROM dbo.Fact_IUCADC
WHERE VALUE IS NOT NULL
GROUP BY ITEM_NUMBER
ORDER BY KPIValue DESC;