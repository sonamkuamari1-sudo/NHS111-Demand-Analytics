USE NHS111_Analytics;
GO

---------------------------------------------------------
-- Query 1
-- Rank NHS organisations by total recorded KPI value
---------------------------------------------------------

SELECT
    ORG_NAME,
    SUM(VALUE) AS TotalRecordedValue,
    RANK() OVER (
        ORDER BY SUM(VALUE) DESC
    ) AS OrganisationRank
FROM dbo.Fact_IUCADC
WHERE VALUE IS NOT NULL
GROUP BY ORG_NAME
ORDER BY OrganisationRank;
GO


---------------------------------------------------------
-- Query 2
-- Rank NHS regions by total recorded KPI value
---------------------------------------------------------

SELECT
    REGION_NAME,
    SUM(VALUE) AS TotalRecordedValue,
    DENSE_RANK() OVER (
        ORDER BY SUM(VALUE) DESC
    ) AS RegionRank
FROM dbo.Fact_IUCADC
WHERE VALUE IS NOT NULL
GROUP BY REGION_NAME
ORDER BY RegionRank;
GO


---------------------------------------------------------
-- Query 3
-- Monthly total with correct chronological order
-- and a running total
---------------------------------------------------------

WITH MonthlyData AS (
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
        ) AS MonthStart,

        SUM(VALUE) AS MonthlyRecordedValue

    FROM dbo.Fact_IUCADC
    WHERE VALUE IS NOT NULL
    GROUP BY REPORTING_PERIOD
)

SELECT
    REPORTING_PERIOD,
    MonthStart,
    MonthlyRecordedValue,

    SUM(MonthlyRecordedValue) OVER (
        ORDER BY MonthStart
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS RunningTotal

FROM MonthlyData
ORDER BY MonthStart;
GO


---------------------------------------------------------
-- Query 4
-- Month-on-month change using LAG
---------------------------------------------------------

WITH MonthlyData AS (
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
        ) AS MonthStart,

        SUM(VALUE) AS MonthlyRecordedValue

    FROM dbo.Fact_IUCADC
    WHERE VALUE IS NOT NULL
    GROUP BY REPORTING_PERIOD
),

MonthlyComparison AS (
    SELECT
        REPORTING_PERIOD,
        MonthStart,
        MonthlyRecordedValue,

        LAG(MonthlyRecordedValue) OVER (
            ORDER BY MonthStart
        ) AS PreviousMonthValue

    FROM MonthlyData
)

SELECT
    REPORTING_PERIOD,
    MonthStart,
    MonthlyRecordedValue,
    PreviousMonthValue,

    MonthlyRecordedValue - PreviousMonthValue AS AbsoluteChange,

    CAST(
        100.0 * (MonthlyRecordedValue - PreviousMonthValue)
        / NULLIF(PreviousMonthValue, 0)
        AS DECIMAL(10,2)
    ) AS MonthOnMonthChangePercent

FROM MonthlyComparison
ORDER BY MonthStart;
GO


---------------------------------------------------------
-- Query 5
-- Highest-value KPI code for each organisation
---------------------------------------------------------

WITH OrganisationKPI AS (
    SELECT
        ORG_NAME,
        ITEM_NUMBER,
        SUM(VALUE) AS KPIValue
    FROM dbo.Fact_IUCADC
    WHERE VALUE IS NOT NULL
    GROUP BY
        ORG_NAME,
        ITEM_NUMBER
),

RankedKPI AS (
    SELECT
        ORG_NAME,
        ITEM_NUMBER,
        KPIValue,

        ROW_NUMBER() OVER (
            PARTITION BY ORG_NAME
            ORDER BY KPIValue DESC
        ) AS KPIPosition

    FROM OrganisationKPI
)

SELECT
    ORG_NAME,
    ITEM_NUMBER,
    KPIValue
FROM RankedKPI
WHERE KPIPosition = 1
ORDER BY KPIValue DESC;
GO


---------------------------------------------------------
-- Query 6
-- Regional share of the overall recorded KPI value
---------------------------------------------------------

WITH RegionData AS (
    SELECT
        REGION_NAME,
        SUM(VALUE) AS TotalRecordedValue
    FROM dbo.Fact_IUCADC
    WHERE VALUE IS NOT NULL
    GROUP BY REGION_NAME
)

SELECT
    REGION_NAME,
    TotalRecordedValue,

    CAST(
        100.0 * TotalRecordedValue
        / SUM(TotalRecordedValue) OVER ()
        AS DECIMAL(10,2)
    ) AS ShareOfTotalPercent

FROM RegionData
ORDER BY TotalRecordedValue DESC;
GO


---------------------------------------------------------
-- Query 7
-- Top 10 contracts using ROW_NUMBER
---------------------------------------------------------

WITH ContractData AS (
    SELECT
        CONTRACT_NAME,
        SUM(VALUE) AS TotalRecordedValue
    FROM dbo.Fact_IUCADC
    WHERE VALUE IS NOT NULL
    GROUP BY CONTRACT_NAME
),

RankedContracts AS (
    SELECT
        CONTRACT_NAME,
        TotalRecordedValue,

        ROW_NUMBER() OVER (
            ORDER BY TotalRecordedValue DESC
        ) AS ContractRank

    FROM ContractData
)

SELECT
    ContractRank,
    CONTRACT_NAME,
    TotalRecordedValue
FROM RankedContracts
WHERE ContractRank <= 10
ORDER BY ContractRank;
GO


---------------------------------------------------------
-- Query 8
-- Missing VALUE records by KPI code
---------------------------------------------------------

SELECT
    ITEM_NUMBER,
    COUNT(*) AS MissingValueCount
FROM dbo.Fact_IUCADC
WHERE VALUE IS NULL
GROUP BY ITEM_NUMBER
ORDER BY MissingValueCount DESC;
GO