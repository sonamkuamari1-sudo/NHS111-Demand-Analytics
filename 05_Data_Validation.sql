USE [NHS111_Analytics];
GO

/* =========================================================
   NHS111 Data Validation Checks

   Important:
   A01 = Number of calls received.

   Any analysis described as call demand/calls received
   uses ITEM_NUMBER = 'A01'.

   Other KPI codes are kept separate and are not added
   together as NHS111 call demand.
   ========================================================= */


/* ---------------------------------------------------------
   1. Validate total calls received
   Expected total: 21,817,671
   --------------------------------------------------------- */

SELECT
    SUM(VALUE) AS TotalCallsReceived
FROM dbo.Fact_IUCADC
WHERE ITEM_NUMBER = 'A01'
  AND VALUE IS NOT NULL;
GO


/* ---------------------------------------------------------
   2. Validate total organisations
   --------------------------------------------------------- */

SELECT
    COUNT(DISTINCT ORG_NAME) AS TotalOrganisations
FROM dbo.Fact_IUCADC
WHERE ORG_NAME IS NOT NULL;
GO


/* ---------------------------------------------------------
   3. Validate total regions
   --------------------------------------------------------- */

SELECT
    COUNT(DISTINCT REGION_NAME) AS TotalRegions
FROM dbo.Fact_IUCADC
WHERE REGION_NAME IS NOT NULL
  AND LTRIM(RTRIM(REGION_NAME)) <> '';
GO


/* ---------------------------------------------------------
   4. Validate total contracts
   --------------------------------------------------------- */

SELECT
    COUNT(DISTINCT CONTRACT_NAME) AS TotalContracts
FROM dbo.Fact_IUCADC
WHERE CONTRACT_NAME IS NOT NULL;
GO


/* ---------------------------------------------------------
   5. Validate total KPI codes
   --------------------------------------------------------- */

SELECT
    COUNT(DISTINCT ITEM_NUMBER) AS TotalKPIs
FROM dbo.Fact_IUCADC
WHERE ITEM_NUMBER IS NOT NULL;
GO


/* ---------------------------------------------------------
   6. Validate organisation calls received
   --------------------------------------------------------- */

SELECT *
FROM dbo.vw_OrganisationDemand
ORDER BY CallsReceived DESC;
GO


/* ---------------------------------------------------------
   7. Validate regional calls received
   --------------------------------------------------------- */

SELECT *
FROM dbo.vw_RegionDemand
ORDER BY CallsReceived DESC;
GO


/* ---------------------------------------------------------
   8. Validate contract calls received
   --------------------------------------------------------- */

SELECT *
FROM dbo.vw_ContractDemand
ORDER BY CallsReceived DESC;
GO


/* ---------------------------------------------------------
   9. Validate KPI recorded values

   This is KPI-level analysis.
   These values must NOT be interpreted as total call demand.
   --------------------------------------------------------- */

SELECT *
FROM dbo.vw_KPIDemand
ORDER BY TotalRecordedValue DESC;
GO


/* ---------------------------------------------------------
   10. Validate monthly calls received
   --------------------------------------------------------- */

SELECT *
FROM dbo.vw_MonthlyDemand
ORDER BY ReportingDate;
GO


/* ---------------------------------------------------------
   11. Validate monthly totals equal annual A01 total

   The result should equal 21,817,671.
   --------------------------------------------------------- */

SELECT
    SUM(CallsReceived) AS TotalCallsFromMonthlyView
FROM dbo.vw_MonthlyDemand;
GO


/* ---------------------------------------------------------
   12. Check missing VALUE records for A01
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS MissingA01Values
FROM dbo.Fact_IUCADC
WHERE ITEM_NUMBER = 'A01'
  AND VALUE IS NULL;
GO
