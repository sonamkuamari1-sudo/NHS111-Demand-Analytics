-- Check Organisation view
SELECT *
FROM vw_OrganisationDemand
ORDER BY TotalDemand DESC;

-- Check Region view
SELECT *
FROM vw_RegionDemand
ORDER BY TotalDemand DESC;

-- Check Contract view
SELECT *
FROM vw_ContractDemand
ORDER BY TotalRecordedValue DESC;

-- Check KPI view
SELECT *
FROM vw_KPIDemand
ORDER BY TotalRecordedValue DESC;

-- Check Monthly view
SELECT *
FROM vw_MonthlyDemand
ORDER BY ReportingDate;

