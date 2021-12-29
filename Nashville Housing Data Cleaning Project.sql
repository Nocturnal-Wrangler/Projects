select * from NashvilleHousing

select distinct(SoldAsVacant), count(SoldAsVacant) as VacantSalesCount
from NashvilleHousing
group by (SoldAsVacant)
order by (VacantSalesCount)

--Standardise Date Format

Select * from PortfolioProject.dbo.NashvilleHousing

select SaleDate, CONVERT(date, SaleDate) as SaleDate_1
from NashvilleHousing

alter table NashvilleHousing
add SaleDate_1 nvarchar(255)

update NashvilleHousing
set SaleDate_1 = CONVERT(date, SaleDate) 



--Populate Property Address data (missing data)

select a.ParcelID, a.PropertyAddress, b.parcelId, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.propertyaddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



--Breaking out Address into individual columns (Address, City, State)


Select
SUBSTRING(PropertyAddress, 1, Charindex(',',PropertyAddress)-1) as Address 
, substring(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1 , LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing


Alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)

select * from NashvilleHousing

Update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, Charindex(',',PropertyAddress)-1)



Alter table NashvilleHousing
add PropertySplitCity nvarchar(255)

Update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1 , LEN(PropertyAddress)) 


select * from NashvilleHousing



Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

select 
PARSENAME(replace(OwnerAddress,',', '.'), 3),
PARSENAME(replace(OwnerAddress,',', '.'), 2),
PARSENAME(replace(OwnerAddress,',', '.'), 1)
From PortfolioProject.dbo.NashvilleHousing


Alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255)

Update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',', '.'), 3)
from PortfolioProject.dbo.NashvilleHousing

Alter table NashvilleHousing
add OwnerSplitCity nvarchar(255)

Update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',', '.'), 2)

Alter table NashvilleHousing
add OwnerSplitState nvarchar(255)

Update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',', '.'), 1)



--Change responses from Y or N to Yes or No

select SoldAsVacant, count(SoldAsVacant) CountVacantSales
from NashvilleHousing
group by(SoldAsVacant)
order by (CountVacantSales) desc


select SoldAsVacant,
case
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant 
END
From nashvillehousing


update NashvilleHousing
set SoldAsVacant = case
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant 
END
From nashvillehousing



--Delete duplicates

WITH RowNumCTE as( 
Select * , 
ROW_NUMBER() over (
partition by parcelID,
PropertyAddress, 
SalePrice,
SaleDate, 
LegalReference
Order by UniqueID) 
row_num

From NashvilleHousing)
--order by ParcelID
select *
from RowNumCTE
where ROW_NUM > 1



--Delete unused columns

Select * 
From PortfolioProject.dbo.NashvilleHousing

alter table nashvillehousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table nashvillehousing
drop column SaleDate
