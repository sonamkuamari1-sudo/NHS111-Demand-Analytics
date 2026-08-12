-- Total number of records
SELECT COUNT(*) AS TotalRecords
FROM dbo.Fact_IUCADC;

-- Number of NHS organisations
SELECT COUNT(DISTINCT ORG_NAME) AS TotalOrganisations
FROM dbo.Fact_IUCADC;

-- Number of contracts
SELECT COUNT(DISTINCT CONTRACT_NAME) AS TotalContracts
FROM dbo.Fact_IUCADC;

-- Number of KPI codes
SELECT COUNT(DISTINCT ITEM_NUMBER) AS TotalKPIs
FROM dbo.Fact_IUCADC;

-- Number of regions
SELECT COUNT(DISTINCT REGION_NAME) AS TotalRegions
FROM dbo.Fact_IUCADC;