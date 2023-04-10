select * from [dbo].[Housing]

--Changing a date column from datatype- DATETIME TO DATE

alter table [dbo].[Housing]
alter column saledate date

--Populating the null addresses
select a.uniqueid,a.ParcelID,a.PropertyAddress,b.uniqueid,b.ParcelID,b.PropertyAddress,ISNULL(b.PropertyAddress,a.PropertyAddress)
from [dbo].[Housing] a join [dbo].[Housing] b 
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where b.PropertyAddress is null

update b
set b.propertyaddress = ISNULL(b.PropertyAddress,a.PropertyAddress) from
[dbo].[Housing] a join [dbo].[Housing] b 
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where b.PropertyAddress is null

--Breaking out addresses into different columns (Address,City) USING SUBSTRING METHOD

--select rtrim(SUBSTRING(propertyaddress,1,charindex(',',propertyaddress)-1)) as Address,
--ltrim(SUBSTRING(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress))) as City from [dbo].[Housing]

alter table [dbo].[Housing]
add Address_new nvarchar(100)
update [dbo].[Housing]
set address_new = rtrim(SUBSTRING(propertyaddress,1,charindex(',',propertyaddress)-1))


alter table [dbo].[Housing]
add City_new nvarchar(100)
update [dbo].[Housing]
set city_new = ltrim(SUBSTRING(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress)))


--Breaking out addresses into different columns (Address,City,State) USING PARSENAME
--select owneraddress from [dbo].[Housing]
--select parsename(replace(owneraddress,',','.'),3) from [dbo].[Housing]
--select parsename(replace(owneraddress,',','.'),2) from [dbo].[Housing]
--select parsename(replace(owneraddress,',','.'),1) from [dbo].[Housing]

alter table [dbo].[Housing]
add owner_add_split nvarchar(100),owner_city_split nvarchar(20),owner_state_split nvarchar(20)

update [dbo].[Housing]
set owner_add_split = parsename(replace(owneraddress,',','.'),3) from [dbo].[Housing]

update [dbo].[Housing]
set owner_city_split = parsename(replace(owneraddress,',','.'),2) from [dbo].[Housing]

update [dbo].[Housing]
set owner_state_split = parsename(replace(owneraddress,',','.'),1) from [dbo].[Housing]

--Changing Y/N into yes or no in SOLDASVACANT COLUMN 
select soldasvacant,COUNT(soldasvacant) from [dbo].[Housing]
group by SoldAsVacant

update [dbo].[Housing]
set SoldAsVacant = 
case
	when soldasvacant = 'Y' then 'Yes'
	when soldasvacant = 'N' then 'No'
	else SoldAsVacant
end
from [dbo].[Housing]

--Removing duplicates Using a CTE to look at data and removing the duplicate colummns 
with rownum as(
select *, 
ROW_NUMBER() over (partition by parcelid,propertyaddress,saledate,saleprice,legalreference
order by parcelid) as RN
from [dbo].[Housing])
select * from rownum
where rn > 1

--Removing extra colums 
alter table [dbo].[Housing]
drop column propertyaddress