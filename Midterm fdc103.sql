Use AdventureWorksDW2019
--Câu 1
Select
Year(OrderDate) as OrderYear
,FORMAT(OrderDate, 'yyyy-MM') as OrderMonth
,Sum(SalesAmount) as SalesMonthAmount
FROM FactResellerSales
Group by Year(OrderDate) 
,FORMAT(OrderDate, 'yyyy-MM')
Order by OrderMonth

--Câu 2
Select 
fis.SalesOrderNumber
,EnglishProductName
,SalesReasonReasonType
,Year(OrderDate) as Year_
,Month(OrderDate) as Month_
,OrderDate
,SalesAmount
,EnglishProductCategoryName
From FactInternetSales as fis
	JOIN DimProduct as pro on fis.ProductKey = pro.ProductKey
	JOIN FactInternetSalesReason as frea on fis.SalesOrderNumber = frea.SalesOrderNumber
	JOIN DimSalesReason as rea on rea.SalesReasonKey = frea.SalesReasonKey
	JOIN DimProductSubcategory as sub on sub.ProductSubcategoryKey = pro.ProductSubcategoryKey
	JOIN DimProductCategory as cat on cat.ProductCategoryKey = sub.ProductCategoryKey
where SalesReasonReasonType = 'Marketing' 
and Year(OrderDate) in ('2013', '2014')
and Month(OrderDate) > 6 and Month(OrderDate) < 10

--Câu 3
Use AdventureWorksDW2019
With X as
(
Select 
SalesTerritoryCountry
, EnglishProductName
, Sum(SalesAmount) as InternetTotalSales
FROM DimProduct as pro
JOIN FactInternetSales as fis on fis.ProductKey = pro.ProductKey 
JOIN DimSalesTerritory as ter on ter.SalesTerritoryKey = fis.SalesTerritoryKey
Group by SalesTerritoryCountry, EnglishProductName
)
, Y as
(
	select *
	, Sum(InternetTotalSales) Over(partition by SalesTerritoryCountry) as CountryTotal
	, InternetTotalSales/Sum(InternetTotalSales) Over(partition by SalesTerritoryCountry) as PercentofTotaInCountry  
	from X
)
Select SalesTerritoryCountry
		, EnglishProductName
		, InternetTotalSales
		, format(PercentofTotaInCountry, 'P') PercenOfTotalInCountry
, Case when PercentofTotaInCountry < 0.01 then 'High'
else 'low' end
From Y


--Caau 4
WITH X as
(
Select
Year(OrderDate) as OrderYear
, FORMAT(OrderDate, 'yyyy-MM') as OrderMonth
, fis.PromotionKey
, EnglishPromotionName
, Sum(SalesAmount) as SalesMonthAmount
FROM FactInternetSales as fis
LEFT JOIN DimPromotion as prom on fis.PromotionKey = prom.PromotionKey
Group by 
Year(OrderDate) 
, FORMAT(OrderDate, 'yyyy-MM')
, fis.PromotionKey
, EnglishPromotionName
)
, Y as
(
Select *
, Row_Number() OVER(Partition by OrderMonth Order by SalesMonthAmount DESC) as Row_
FROM X
)
Select 
Year(OrderDate) as OrderYear
, Month(OrderDate) as OrderMonth
, PromotionKey
, EnglishPromotionName
, SalesMonthAmount
FROM Y
Where Row_ < 2

--Cau 5
WITH Employee AS (
SELECT 1 as Id, 'Joe' as Name, 7000 as Salary, 3 as ManagerId UNION ALL
SELECT 2 as Id, 'Henry' as Name, 8000 as Salary, 4 as ManagerId UNION ALL
SELECT 3 as Id, 'Sam' as Name, 6000 as Salary, null as ManagerId UNION ALL
SELECT 4 as Id, 'Max' as Name, 9000 as Salary, null as ManagerId UNION ALL
SELECT 5 as Id, 'Harry' as Name, 10000 as Salary, null as ManagerId UNION ALL
SELECT 6 as Id, 'Potter' as Name, 11000 as Salary, 5 as ManagerId
)
select 
A.Id as EmployeeId
, A.Name Employee
, A.Salary as EmpSal
, B.Id as ManagerID
, B.Salary as Manasal
, B.Name Manager
From Employee as A 
	JOIN Employee as B on B.Id = A.ManagerId
where A.Salary > B.Salary