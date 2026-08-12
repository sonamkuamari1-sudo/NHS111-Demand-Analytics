---------------------------------------------------------
-- View 1
-- Organisation Demand
---------------------------------------------------------

CREATE VIEW vw_OrganisationDemand AS

SELECT
    ORG_NAME,
    SUM(VALUE) AS TotalDemand
FROM dbo.Fact_IUCADC
WHERE VALUE IS NOT NULL
GROUP BY ORG_NAME;