--cleaning data in sql queries
select * from 
PortfolioProject..NashvilleHousing

--standardize date format
select SaleDate,convert(Date,SaleDate)
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = convert(Date,SaleDate)

--Populate property adress data
select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
 on a.ParcelID = b.ParcelID
  and a.[UniqueID ] <> b.[UniqueID ]
  where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
 on a.ParcelID = b.ParcelID
  and a.[UniqueID ] <> b.[UniqueID ]
  where a.PropertyAddress is null

-- Braking out adress into individual columns (Adress,City,State)

select PropertyAddress
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select 
SUBSTRING(PropertyAddress,1,charindex(',',PropertyAddress)-1) as adress,
SUBSTRING(PropertyAddress,charindex(',',PropertyAddress)+1, len(PropertyAddress)) as address
from PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress,charindex(',',PropertyAddress)+1, len(PropertyAddress))

ALTER Table NashvilleHousing 
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,charindex(',',PropertyAddress)-1)

select * 
from PortfolioProject..NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
       PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	   PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject..NashvilleHousing


alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);


alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);

--change Y and N to Yes and No in 'Solid As Vacant' field

Select distinct(SoldAsVacant),count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2


Select SoldAsVacant,
 case 
      when SoldAsVacant = 'Y' then 'Yes'
	  when SoldAsVacant = 'N' then 'No'
	  else SoldAsVacant
	  end
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case 
      when SoldAsVacant = 'Y' then 'Yes'
	  when SoldAsVacant = 'N' then 'No'
	  else SoldAsVacant
	  end

--Remove Dublicates

with RowNumCTE AS(
select *,
row_number() over (
partition by ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 order by
			  UniqueID)
			 row_num
from PortfolioProject..NashvilleHousing
--order by ParcelID
)

select *
from RowNumCTE 
where row_num > 1
--order by PropertyAddress


select * from 
PortfolioProject..NashvilleHousing

--delete unused columns

alter table	PortfolioProject..NashvilleHousing
drop column OwnerAddress,TaxDistrict,PropertyAddress


alter table	PortfolioProject..NashvilleHousing
drop column SaleDate