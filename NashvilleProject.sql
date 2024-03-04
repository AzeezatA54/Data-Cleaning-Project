Select * from NashvilleHousingProject..Nash


--Data Cleaning Project


--1.   Change SaleDate Format
Select SaleDate , cast(SaleDate as Date)
from NashvilleHousingProject..Nash

Alter Table NashvilleHousingProject..Nash
Add NewSaleDate date;

Update NashvilleHousingProject..Nash 
Set NewSaleDate = cast(SaleDate as Date)

Select *
from NashvilleHousingProject..Nash

Alter Table NashvilleHousingProject..Nash
Drop Column SaleDate

Select *
from NashvilleHousingProject..Nash






--2.   Populate Property Address 

Select PropertyAddress
from NashvilleHousingProject..Nash


--This shows that there are 29 rows where property address is null
Select PropertyAddress
from NashvilleHousingProject..Nash
where PropertyAddress is null    

--Populate Null Property Address with that of which has similar ParcelID 
--NB:Some of the same houses were resold years later

Select a.ParcelId, a.PropertyAddress,b.ParcelID, b.PropertyAddress
from NashvilleHousingProject..Nash a
join NashvilleHousingProject..Nash b
   on a.ParcelID = b.ParcelID
   and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null



--Now use ISNULL to create a new column that would be used to populate the null values
Select a.ParcelId, a.PropertyAddress,b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousingProject..Nash a
join NashvilleHousingProject..Nash b
   on a.ParcelID = b.ParcelID
   and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


Update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousingProject..Nash a
join NashvilleHousingProject..Nash b
   on a.ParcelID = b.ParcelID
   and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


--crosscheck
Select a.ParcelId, a.PropertyAddress,b.ParcelID, b.PropertyAddress
from NashvilleHousingProject..Nash a
join NashvilleHousingProject..Nash b
   on a.ParcelID = b.ParcelID
   and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


--3.   Breaking PropertyAddress into individual Columns (Address, City, State)
Select PropertyAddress
from NashvilleHousingProject..Nash

Select Substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address
from NashvilleHousingProject..Nash

Select Substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress) ) as State
from NashvilleHousingProject..Nash



Alter Table NashvilleHousingProject..Nash
Add NewPropertyAddress NVarchar(255);

Update NashvilleHousingProject..Nash 
Set NewPropertyAddress =  Substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1)

select NewPropertyAddress from  NashvilleHousingProject..Nash



Alter Table NashvilleHousingProject..Nash
Add NewPropertyState NVarchar (255);

Update NashvilleHousingProject..Nash 
Set NewPropertyState = Substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress) )

select NewPropertyState from  NashvilleHousingProject..Nash



Alter Table NashvilleHousingProject..Nash
Drop Column PropertyAddress;

select * from NashvilleHousingProject..Nash



--4. Breaking OwnerAddress into individual Columns (Address, City, State)
Select OwnerAddress
from NashvilleHousingProject..Nash  


select parsename(replace(OwnerAddress, ',', '.'), 3) ,
      parsename(replace(OwnerAddress, ',', '.'), 2) ,
	  parsename(replace(OwnerAddress, ',', '.'), 1)
from NashvilleHousingProject..Nash



Alter Table NashvilleHousingProject..Nash
Add NewOwnerAddressSt NVarchar (255);

Update NashvilleHousingProject..Nash 
Set NewOwnerAddressSt = parsename(replace(OwnerAddress, ',', '.'), 3)

Select NewOwnerAddressSt
from NashvilleHousingProject..Nash




Alter Table NashvilleHousingProject..Nash
Add NewOwnerAddressCity NVarchar (255);

Update NashvilleHousingProject..Nash 
Set NewOwnerAddressCity = parsename(replace(OwnerAddress, ',', '.'), 2)

Select NewOwnerAddressCity
from NashvilleHousingProject..Nash





Alter Table NashvilleHousingProject..Nash
Add NewOwnerAddressState NVarchar (255);

Update NashvilleHousingProject..Nash 
Set NewOwnerAddressState = parsename(replace(OwnerAddress, ',', '.'), 1)


Select NewOwnerAddressState
from NashvilleHousingProject..Nash



Select *
from NashvilleHousingProject..Nash


--5.   Change Y and N to Yes and No in 'Sold as Vacant' Field

select distinct (SoldAsVacant), Count (SoldAsVacant)
from NashvilleHousingProject..Nash
group by SoldAsVacant
order by 2


select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes' 
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant end   
from NashvilleHousingProject..Nash



Alter Table NashvilleHousingProject..Nash
Add NewSoldAsVacant NVarchar (255);

Update NashvilleHousingProject..Nash 
Set NewSoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes' 
                           when SoldAsVacant = 'N' then 'No'
	                       else SoldAsVacant end   


Select *
from NashvilleHousingProject..Nash


--6.  Remove Duplicates

select * ,
   row_number() over(
   partition by ParcelID,
                SalePrice,
				NewSaleDate,
				LegalReference
   order by UniqueID ) as row_num

from NashvilleHousingProject..Nash
order by ParcelID


with RowNumCte as 
(
select * ,
   row_number() over(
   partition by ParcelID,
                SalePrice,
				NewSaleDate,
				LegalReference
   order by UniqueID ) as row_num

from NashvilleHousingProject..Nash
)
--order by ParcelID

select * from RowNumCte
where  row_num > 1
order by LegalReference


select distinct (row_num), count(row_num)
from RowNumCte
group by row_num

with RowNumCte as 
(
select * ,
   row_number() over(
   partition by ParcelID,
                SalePrice,
				NewSaleDate,
				LegalReference
   order by UniqueID ) as row_num

from NashvilleHousingProject..Nash
)

Delete from RowNumCte
where  row_num > 1
--order by LegalReference

with RowNumCte as 
(
select * ,
   row_number() over(
   partition by ParcelID,
                SalePrice,
				NewSaleDate,
				LegalReference
   order by UniqueID ) as row_num

from NashvilleHousingProject..Nash
)
--order by ParcelID

select * from RowNumCte
where  row_num > 1
order by LegalReference

