USE [NHS111_Analytics];
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

/* =========================================================
   View 1: Organisation Demand
   ========================================================= */
CREATE OR ALTER VIEW dbo.vw_OrganisationDemand AS
SELECT
    ORG_NAME,
    SUM(VALUE) AS CallsReceived
FROM dbo.Fact_IUCADC
WHERE ITEM_NUMBER = 'A01'
  AND VALUE IS NOT NULL
GROUP BY ORG_NAME;
GO

/* =========================================================
   View 2: Region Demand
   ========================================================= */
CREATE OR ALTER VIEW dbo.vw_RegionDemand AS
SELECT
    REGION_NAME,
    SUM(VALUE) AS CallsReceived
FROM dbo.Fact_IUCADC
WHERE ITEM_NUMBER = 'A01'
  AND VALUE IS NOT NULL
GROUP BY REGION_NAME;
GO


/* =========================================================
   View 3: Contract Demand
   ========================================================= */
CREATE OR ALTER VIEW dbo.vw_ContractDemand AS
SELECT
    CONTRACT_NAME,
    SUM(VALUE) AS CallsReceived
FROM dbo.Fact_IUCADC
WHERE ITEM_NUMBER = 'A01'
  AND VALUE IS NOT NULL
GROUP BY CONTRACT_NAME;
GO


/* =========================================================
   View 4: KPI Demand
   ========================================================= */
CREATE OR ALTER VIEW dbo.vw_KPIDemand AS
SELECT
    ITEM_NUMBER,
    SUM(VALUE) AS TotalRecordedValue
FROM dbo.Fact_IUCADC
WHERE VALUE IS NOT NULL
GROUP BY ITEM_NUMBER;
GO

/* =========================================================
   View 5: Monthly Demand
   ========================================================= */
CREATE OR ALTER VIEW dbo.vw_MonthlyDemand AS
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
GROUP BY REPORTING_PERIOD;
GO
