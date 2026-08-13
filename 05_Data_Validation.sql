USE [NHS111_Analytics];
GO

/* =========================================================
   NHS111 Data Validation Checks
   ========================================================= */

-- 1. Validate total recorded value
SELECT
    SUM(VALUE) AS TotalRecordedValue
FROM dbo.Fact_IUCADC
WHERE VALUE IS NOT NULL;


-- 2. Validate total organisations
SELECT
    COUNT(DISTINCT ORG_NAME) AS TotalOrganisations
FROM dbo.Fact_IUCADC
WHERE ORG_NAME IS NOT NULL;


-- 3. Validate total regions
SELECT
    COUNT(DISTINCT REGION_NAME) AS TotalRegions
FROM dbo.Fact_IUCADC
WHERE REGION_NAME IS NOT NULL
  AND LTRIM(RTRIM(REGION_NAME)) <> '';


-- 4. Validate total contracts
SELECT
    COUNT(DISTINCT CONTRACT_NAME) AS TotalContracts
FROM dbo.Fact_IUCADC
WHERE CONTRACT_NAME IS NOT NULL;


-- 5. Validate total KPIs
SELECT
    COUNT(DISTINCT ITEM_NUMBER) AS TotalKPIs
FROM dbo.Fact_IUCADC
WHERE ITEM_NUMBER IS NOT NULL;


-- 6. Validate organisation demand
SELECT *
FROM dbo.vw_OrganisationDemand
ORDER BY TotalDemand DESC;


-- 7. Validate region demand
SELECT *
FROM dbo.vw_RegionDemand
ORDER BY TotalDemand DESC;


-- 8. Validate contract demand
SELECT *
FROM dbo.vw_ContractDemand
ORDER BY TotalRecordedValue DESC;


-- 9. Validate KPI demand
SELECT *
FROM dbo.vw_KPIDemand
ORDER BY TotalRecordedValue DESC;


-- 10. Validate monthly demand
SELECT *
FROM dbo.vw_MonthlyDemand
ORDER BY ReportingDate;
