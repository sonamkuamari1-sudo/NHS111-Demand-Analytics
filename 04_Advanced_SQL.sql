USE NHS111_Analytics;
GO

---------------------------------------------------------
-- Query 1
-- Rank NHS organisations by calls received (A01)
---------------------------------------------------------

SELECT
    ORG_NAME,
    SUM(VALUE) AS CallsReceived,

    RANK() OVER (
        ORDER BY SUM(VALUE) DESC
    ) AS OrganisationRank

FROM dbo.Fact_IUCADC

WHERE ITEM_NUMBER = 'A01'
  AND VALUE IS NOT NULL

GROUP BY ORG_NAME

ORDER BY OrganisationRank;
GO

---------------------------------------------------------
-- Query 2
-- Rank NHS regions by calls received (A01)
---------------------------------------------------------

SELECT
    REGION_NAME,
    SUM(VALUE) AS CallsReceived,

    DENSE_RANK() OVER (
        ORDER BY SUM(VALUE) DESC
    ) AS RegionRank

FROM dbo.Fact_IUCADC

WHERE ITEM_NUMBER = 'A01'
  AND VALUE IS NOT NULL

GROUP BY REGION_NAME

ORDER BY RegionRank;
GO


---------------------------------------------------------
-- Query 3
-- Monthly calls received with running total
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

        SUM(VALUE) AS CallsReceived

    FROM dbo.Fact_IUCADC

    WHERE ITEM_NUMBER = 'A01'
      AND VALUE IS NOT NULL

    GROUP BY REPORTING_PERIOD
)

SELECT
    REPORTING_PERIOD,
    MonthStart,
    CallsReceived,

    SUM(CallsReceived) OVER (
        ORDER BY MonthStart
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS RunningTotalCalls

FROM MonthlyData
ORDER BY MonthStart;
GO


---------------------------------------------------------
-- Query 4
-- Month-on-month change in calls received using LAG
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

        SUM(VALUE) AS CallsReceived

    FROM dbo.Fact_IUCADC

    WHERE ITEM_NUMBER = 'A01'
      AND VALUE IS NOT NULL

    GROUP BY REPORTING_PERIOD
),

MonthlyComparison AS (
    SELECT
        REPORTING_PERIOD,
        MonthStart,
        CallsReceived,

        LAG(CallsReceived) OVER (
            ORDER BY MonthStart
        ) AS PreviousMonthCalls

    FROM MonthlyData
)

SELECT
    REPORTING_PERIOD,
    MonthStart,
    CallsReceived,
    PreviousMonthCalls,

    CallsReceived - PreviousMonthCalls AS AbsoluteChange,

    CAST(
        100.0 * (CallsReceived - PreviousMonthCalls)
        / NULLIF(PreviousMonthCalls, 0)
        AS DECIMAL(10,2)
    ) AS MonthOnMonthChangePercent

FROM MonthlyComparison
ORDER BY MonthStart;
GO


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
-- Query 5
-- Highest call-related KPI volume by organisation
---------------------------------------------------------

WITH OrganisationKPI AS (
    SELECT
        ORG_NAME,
        ITEM_NUMBER,
        SUM(VALUE) AS KPIValue
    FROM dbo.Fact_IUCADC
    WHERE VALUE IS NOT NULL
      AND ITEM_NUMBER IN (
          'A01', 'A02', 'A03', 'A05', 'A07',
          'B01', 'B02', 'B03', 'B04', 'B05'
      )
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
-- Regional share of total calls received (A01)
---------------------------------------------------------

WITH RegionData AS (
    SELECT
        REGION_NAME,
        SUM(VALUE) AS CallsReceived
    FROM dbo.Fact_IUCADC
    WHERE ITEM_NUMBER = 'A01'
      AND VALUE IS NOT NULL
    GROUP BY REGION_NAME
)

SELECT
    REGION_NAME,
    CallsReceived,

    CAST(
        100.0 * CallsReceived
        / SUM(CallsReceived) OVER ()
        AS DECIMAL(10,2)
    ) AS ShareOfTotalCallsPercent

FROM RegionData
ORDER BY CallsReceived DESC;
GO


---------------------------------------------------------
-- Query 7
-- Top 10 contracts by calls received (A01)
---------------------------------------------------------

WITH ContractData AS (
    SELECT
        CONTRACT_NAME,
        SUM(VALUE) AS CallsReceived
    FROM dbo.Fact_IUCADC
    WHERE ITEM_NUMBER = 'A01'
      AND VALUE IS NOT NULL
    GROUP BY CONTRACT_NAME
),

RankedContracts AS (
    SELECT
        CONTRACT_NAME,
        CallsReceived,

        ROW_NUMBER() OVER (
            ORDER BY CallsReceived DESC
        ) AS ContractRank

    FROM ContractData
)

SELECT
    ContractRank,
    CONTRACT_NAME,
    CallsReceived
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
