--Câu 3:
with x as
(
Select
SalesTerritoryCountry
, pro.ProductKey
, EnglishProductName
, Sum(SalesAmount) as InternetTotalSales
From DimSalesTerritory as ter 
JOIN FactInternetSales as inter 
	on ter.SalesTerritoryKey = inter.SalesTerritoryKey
JOIN DimProduct as pro 
	on pro.ProductKey = inter.ProductKey
Group by SalesTerritoryCountry, 
		 pro.ProductKey, 
		 EnglishProductName
)
Select * 
, sum(InternetTotalSales) over (partition by SalesTerritoryCountry) as Percent
,  (InternetTotalSales / Sum(InternetTotalsales)
from X

--Cau 4
with x as
(Select 
Year(OrderDate) as OrderYear
, Month(OrderDate) as OrderMonth
, fis.CustomerKey
, concat_ws(' ', FirstName, MiddleName, LastName) as Fullnmae
, Sum(SalesAmount) as CustomerMonth

FROM FactInternetSales as fis
join DimCustomer as C
On fis.CustomerKey = C.CustomerKey
Group by Year(OrderDate) 
, Month(OrderDate) 
, fis.CustomerKey
, concat_ws(' ', FirstName, MiddleName, LastName)
), 
y as
(
select *
, Row_Number() Over (partition by OrderYear, OrderMonth order by CustomerMonth desc) as rank_
from x
)
Select * 
FROM Y

--task 6
With Totalsales_by_month as
Select Year(OrderDate) as OrderYear
, Month(OrderDate) as OrderMonth
, Sum(SalesAmount) 
FROM FactInternetSales as fis
group by Year(OrderDate)
, Month(OrderDate)
Order by Year(OrderDate), Month(OrderDate) asc)
Select * from current_year_sales as CY