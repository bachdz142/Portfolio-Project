--Câu 1
Select 
SalesOrderNumber
, SalesOrderLineNumber
, pro.ProductKey
, EnglishProductName
, SalesTerritoryCountry
, SalesAmount
, OrderQuantity
FROM FactInternetSales as fct
JOIN DimProduct as pro on pro.ProductKey = fct.ProductKey
JOIN DimSalesTerritory as ter on ter.SalesTerritoryKey = fct.SalesTerritoryKey

--Câu 2

Select
SalesTerritoryCountry
, pro.ProductKey
, EnglishProductName
, Sum(SalesAmount) as InternetTotalSales
, Count(OrderQuantity) as NumberofOrders
From DimSalesTerritory as ter 
JOIN FactInternetSales as inter on ter.SalesTerritoryKey = inter.SalesTerritoryKey
JOIN DimProduct as pro on pro.ProductKey = inter.ProductKey
Group by SalesTerritoryCountry, pro.ProductKey, EnglishProductName

--Câu 3
With Total_Sum as
(
Select
SalesTerritoryCountry
, Sum(SalesAmount) as InternetTotalSales
From DimSalesTerritory as ter 
JOIN FactInternetSales as inter on ter.SalesTerritoryKey = inter.SalesTerritoryKey
JOIN DimProduct as pro on pro.ProductKey = inter.ProductKey
Group by SalesTerritoryCountry
)
Select
SalesTerritoryCountry
, pro.ProductKey
, EnglishProductName
, Sum(SalesAmount) as InternetTotalSales 
From Total_Sum 
JOIN FactInternetSales as inter on ter.SalesTerritoryKey = inter.SalesTerritoryKey
JOIN DimProduct as pro on pro.ProductKey = inter.ProductKey
Group by SalesTerritoryCountry, pro.ProductKey, EnglishProductName



Select
ProductKey
, EnglishProductName
From DimProduct		

--CAu 4
Select * From
(
Select 
Year(OrderDate) as OrderYear
, Month(OrderDate) as OrderMonth
, Cu.CustomerKey
, CONCAT_WS(' ', FirstName, MiddleName, LastName) as Full_name
, SalesAmount as CustomerMonthAmount
, dense_rank() over (partition by Year(OrderDate) order by Sum(SalesAmount) desc) as rank_ 
From DimCustomer as Cu
JOIN FactInternetSales as inter on Cu.CustomerKey = inter.CustomerKey
Group by Year(OrderDate)
, Month(OrderDate) 
, Cu.CustomerKey
, CONCAT_WS(' ', FirstName, MiddleName, LastName)
, SalesAmount)
where rank_ < 4

--bai 5
Select
Year(OrderDate) as Year
, Month(OrderDate) as Month
, Sum(SalesAmount) as InternetMonthAmount
From FactInternetSales
Group by Month(OrderDate), Year(OrderDate)
Order By Year(OrderDate)  