USE [AdventureworksDW2016CTP3];
GO

--	https://www.red-gate.com/simple-talk/sql/t-sql-programming/sql-server-cte-basics/

--	CTE, czyli wspólne wyrażenia tablicowe, zostały wprowadzone po raz pierwszy w SQL Server 2005, jako rozszerzenie składni T-SQL.

--	Upraszczają i poprawiają przejrzystość kodu SQL. 
--	W tym zakresie, ich stosowanie nie ma wpływu na wydajność zapytań, tylko na jego czytelność. 

--	Oprócz funkcji czysto estetycznej, posiadają jeszcze jedną, specjalną właściwość – ich struktura pozwala na realizację rekurencji.

--	bez CTE
---------------------------------------------------------------------

	SELECT *
	FROM
	(
		SELECT e.[EmployeeKey],
			   e.[ParentEmployeeKey],
			   e.[FirstName],
			   e.[LastName],
			   e.[LoginID],
			   e.[EmailAddress],
			   t.[SalesTerritoryGroup]
		FROM [dbo].[DimEmployee] AS e
			INNER JOIN dbo.DimSalesTerritory AS t
				ON t.SalesTerritoryKey = e.SalesTerritoryKey
	) AS ch
	INNER JOIN 
	(
		SELECT e.[EmployeeKey],
			   e.[ParentEmployeeKey],
			   e.[FirstName],
			   e.[LastName],
			   e.[LoginID],
			   e.[EmailAddress],
			   t.[SalesTerritoryGroup]
		FROM [dbo].[DimEmployee] AS e
			INNER JOIN dbo.DimSalesTerritory AS t
				ON t.SalesTerritoryKey = e.SalesTerritoryKey
	) AS p ON p.EmployeeKey = ch.ParentEmployeeKey
			AND p.SalesTerritoryGroup = ch.SalesTerritoryGroup
	;

--	CTE -> przerzucamy podzapytania do przodu i odwołujemy się do nich w kodzie
---------------------------------------------------------------------

	WITH cte_emps
	AS
	(
		SELECT e.[EmployeeKey],
			   e.[ParentEmployeeKey],
			   e.[FirstName],
			   e.[LastName],
			   e.[LoginID],
			   e.[EmailAddress],
			   t.[SalesTerritoryGroup]
		FROM [dbo].[DimEmployee] AS e
			INNER JOIN dbo.DimSalesTerritory AS t
				ON t.SalesTerritoryKey = e.SalesTerritoryKey
	)

	SELECT *
	FROM 
				cte_emps AS ch
	INNER JOIN	cte_emps AS p	ON p.EmployeeKey = ch.ParentEmployeeKey 
								AND p.SalesTerritoryGroup = ch.SalesTerritoryGroup

	;

--	rekurencja
--	startujemy od pracownika 22, dodajemy jego podwładnych, i kolejnych i kolejnych... aż select rekurencyjny zwróci zbiór pusty
---------------------------------------------------------------------

	WITH cte_emps
	AS
	(
		--	{anchor}
		SELECT 
				e.[EmployeeKey]
			,	e.[ParentEmployeeKey]
			,	e.[FirstName]
			,	e.[LastName]
			,	e.[LoginID]
			,	e.[EmailAddress]
			,	1 AS [level]
		FROM [dbo].[DimEmployee] AS e
		WHERE e.EmployeeKey = 277

		UNION ALL

		--	{recursive}
		SELECT 
				e.[EmployeeKey]
			,	e.[ParentEmployeeKey]
			,	e.[FirstName]
			,	e.[LastName]
			,	e.[LoginID]
			,	e.[EmailAddress]
			,	p.level + 1 AS [level]
		FROM [dbo].[DimEmployee] AS e
		INNER JOIN cte_emps AS p ON p.EmployeeKey = e.ParentEmployeeKey
	)

	SELECT *
	FROM cte_emps AS ch
	ORDER BY level