/*
Cleaning Data in SQL
Limpiando data en SQL 
*/ 

---------------------------------------------------------------------------------------------------------------------------------------------------------
--Standardize data 
--Estandarizando la data
--En SQL server no existe el to_date asi que usamos el convert (DATE,'2017-01-21',102) el 102 nos da el fromato DD-MM-YY y 104 DD-MM-YYYY
select SaleDate, convert (date, SaleDate) as SaleDateConverted
from PortfolioProject.dbo.NashvilleHousing

--Intentamos hacer un update a la columna SaleDate con el convert pero no lo toma, agregamos una columna nueva 
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
set SaleDateConverted = CONVERT(date, SaleDate)

select SaleDate, SaleDateConverted
from PortfolioProject.dbo.NashvilleHousing

------------------------------------------------------------------------------------------------------------------------------------------------
--Populate Property Address data
--Colocandovalor a Property Address donde estaban null
--Podemos observar que en el PropertyAddress hay columnas en Null pero con el ParcelID podemod verificar su direccion 

select a.ParcelID, a.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b 
on a.ParcelID = b.ParcelID  --hacemos un join cnsigo misma donde verificamos que sea la misma direccion pero diferente fila    
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b 
on a.ParcelID = b.ParcelID 
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


----------------------------------------------------------------------------------------------------------------------------------------------------
--Breaking out Address into Individuals columns (Address, City, State)
--Separando las direcciones en columnas individuales 
--
select PropertyAddress, SUBSTRING(PropertyAddress ,1, CHARINDEX(',', PropertyAddress)-1) as SplitPropertyAddress,
SUBSTRING(PropertyAddress , CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as SplitPropertyCity
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add SplitPropertyAddress nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
set SplitPropertyAddress = SUBSTRING(PropertyAddress ,1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add SplitPropertyCity nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
set SplitPropertyCity = SUBSTRING(PropertyAddress , CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

select *
from PortfolioProject.dbo.NashvilleHousing

--Split OwnerAddress
--Separamos ahora OwnerAddress

select PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as SplitOwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as SplitOwnerCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as SplitOwnerState
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add SplitOwnerAddress nvarchar(255), SplitOwnerCity nvarchar(255), SplitOwnerState nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
set SplitOwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
 SplitOwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
 SplitOwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

 select *
from PortfolioProject.dbo.NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in 'Sold as Vacant' Field 
select distinct (SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant 

select  SoldAsVacant, case when SoldAsVacant = 'Y' then 'Yes'
							when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
						end
from PortfolioProject.dbo.NashvilleHousing

update PortfolioProject.dbo.NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
							when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
						end
 select distinct(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--Remove Duplicates
--Eliminamos registros duplicados
--A pesar de que UniqueID sea diferente, hay registros que contienen exactamente la misma informacion en las demas columnas 

with RowNumCTE  as (
select *, ROW_NUMBER() OVER (
			PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			order by 
			UniqueID)
			row_num
from PortfolioProject.dbo.NashvilleHousing
)


/*delete 
from RowNumCTE
where row_num > 1*/

Select * 
from RowNumCTE
where row_num > 1
order by PropertyAddress
-------------------------------------------------------------------------------------------------------------------------------------------------
--DeleteColumns
--Eliminamos Columnas
--Aunque en la practica no es muy comun y es poco recomendable lo hares para este proyecto

select *  
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
drop column PropertyAddress, OwnerAddress

select *  
from PortfolioProject.dbo.NashvilleHousing
