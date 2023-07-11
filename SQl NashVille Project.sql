/* 

Cleaning Data in SQL Queries

*/

Select *
from PortfolioProject..Nashville_housing

--Standardise DateFormat
Select SaleDate, Convert(Date, SaleDate)
from PortfolioProject..Nashville_housing

Alter Table Nashville_housing
add SaleDate2 Date

Update PortfolioProject..Nashville_housing
SET SaleDate2 = Convert(Date, SaleDate)

Select SaleDate2
from PortfolioProject..Nashville_housing

--------------------------------------------------------------------------------------

-- Populate Property Address Data

Select *
from PortfolioProject..Nashville_housing
Where PropertyAddress is null
Order by 2

Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
from PortfolioProject..Nashville_housing as A
join PortfolioProject..Nashville_housing as B
on A.ParcelID = B.ParcelID
and A.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(A.PropertyAddress, B.propertyaddress)
from PortfolioProject..Nashville_housing as A
join PortfolioProject..Nashville_housing as B
on A.ParcelID = B.ParcelID
and A.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------

--Breakin out Address into individual Columns(Address, City, State)

Select PropertyAddress
from Nashville_housing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress )-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, Len(PropertyAddress)) as City
from Nashville_housing

Alter Table Nashville_housing
add PropertySplitAddress Nvarchar(255)

Update PortfolioProject..Nashville_housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress )-1)

Alter Table Nashville_housing
Add PropertySplitCity Nvarchar(255)

Update PortfolioProject..Nashville_housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, Len(PropertyAddress))

Select * 
from Nashville_housing
 
-- Using ParseName

Select OwnerAddress
from Nashville_housing

Select 
PARSENAME(Replace(OwnerAddress,',','.'),3) OwnerSplitAddress,
PARSENAME(Replace(OwnerAddress,',','.'),2) OwnerSplitCity,
PARSENAME(Replace(OwnerAddress,',','.'),1) OwnerSplitState
from Nashville_housing

Alter table Nashville_housing
Add OwnerSplitAddress nvarchar(255)

Update Nashville_housing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)


Alter table Nashville_housing
Add OwnerSplitCity nvarchar(255)

Update Nashville_housing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)


Alter table Nashville_housing
Add OwnerSplitState nvarchar(255)

Update Nashville_housing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

Select *
from Nashville_housing

--------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold As Vacant"  field

Select Distinct(SoldAsVacant)
from Nashville_housing

Select SoldAsVacant,
Case
When SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' Then 'No'
Else SoldAsVacant
End
From Nashville_housing

Update Nashville_housing
Set SoldAsVacant = 
Case
When SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' Then 'No'
Else SoldAsVacant
End

-----------------------------------------------------------------------------------------
-- Remove Duplicates

With RowNumCTE as(

Select *,
Row_number () OVER(
partition by ParcelID,
			 PropertyAddress, 
			 SalePrice,
			 LegalReference
			 Order by uniqueID) RowNum
From Nashville_housing 
)

Delete 
from RowNumCTE
Where RowNum > 1

---------------------------------------------------------------------------------------------

-- Delete Unused columns

Select * 
From Nashville_housing

alter table Nashville_housing
Drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


