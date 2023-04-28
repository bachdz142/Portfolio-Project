USE [Portfolio project]
GO
/*

CLEANING DATA IN SQL
*/


select top (1000) *
from dbo.NashvilleHousing
order by ParcelID

-- Standardize Date Format


Select SaleDateConverted, convert(Date, SaleDate) 
From [Portfolio project]..NashvilleHousing
Order by 2



Update NashvilleHousing
Set SaleDate = convert(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
Set SaleDateConverted = convert(Date, SaleDate)

------------------------------------------------------------------------------------------------

-- Populate Property Address -- same parcel ID

select PropertyAddress, SaleDateConverted
From [Portfolio project]..NashvilleHousing
Where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from [Portfolio project]..NashvilleHousing a
join [Portfolio project]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

Update a  -- in join clause Update need to specify which table
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio project]..NashvilleHousing a
join [Portfolio project]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


-- Breaking out Adress into Individual Columns (Add, City, State)

select PropertyAddress
From [Portfolio project]..NashvilleHousing 


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX( ',', PropertyAddress)-1) as Adress  --The CHARINDEX() function searches for a substring in a string, and returns the position.
, SUBSTRING(PropertyAddress, CHARINDEX( ',', PropertyAddress) +  1, len(PropertyAddress))
from [Portfolio project]..NashvilleHousing 


ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255)

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX( ',', PropertyAddress)-1)


ALTER TABLE NashvilleHousing
Add City nvarchar(255)

Update NashvilleHousing
Set City = SUBSTRING(PropertyAddress, CHARINDEX( ',', PropertyAddress) +  1, len(PropertyAddress))




select *
from [Portfolio project]..NashvilleHousing 



Select OwnerAddress
from [Portfolio project]..NashvilleHousing 


Select 
PARSENAME(REPLACE(OwnerAddress, ',','.'),3) -- Parsename return value backwards 
, PARSENAME(REPLACE(OwnerAddress, ',','.'),2)
, PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
From [Portfolio project]..NashvilleHousing 


-- ADD owner adress columns
ALTER TABLE NashvilleHousing
Add OwnerPropertySplitAddress nvarchar(255)

Update NashvilleHousing
Set OwnerPropertySplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)


--ADD owner city columns
ALTER TABLE NashvilleHousing
Add OwnerPropertyCity nvarchar(255)

Update NashvilleHousing
Set OwnerPropertyCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

-- Add owner state column
ALTER TABLE NashvilleHousing
Add OwnerPropertyState nvarchar(255)

Update NashvilleHousing
Set OwnerPropertyState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)



select OwnerPropertyCity, OwnerPropertyState, OwnerPropertySplitAddress
from [Portfolio project]..NashvilleHousing 


-- Change Y and N to Yes and No in 'Sold as vacant'


Select Distinct(SoldAsVacant), Count(SoldAsVacant) as count
from [Portfolio project]..NashvilleHousing 
group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END 
from [Portfolio project]..NashvilleHousing 
Where SoldAsVacant = 'N' or SoldAsVacant = 'Y'

-- Update that shit
Update NashvilleHousing
Set SoldAsVacant =  CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END 


---------------------------------------------------------------------------------------

--Remove Duplicates

-- Finding duplicates
with row_cte as
(
Select *
	, ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueId
					) row_num
from [Portfolio project]..NashvilleHousing  
)
SELECT * --delete (AFTER SELECT WE DELETE THE DUPLICATES)
from row_cte
WHERE row_num > 1

select *
from [Portfolio project]..NashvilleHousing


-- Delete unused column

Select *
From [Portfolio project]..NashvilleHousing


ALTER TABLE [Portfolio project]..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict



ALTER TABLE [Portfolio project]..NashvilleHousing
DROP COLUMN SaleDate