/* Data Cleaning In SQL Queries*/

SELECT * FROM NashvilleHousing.NashvilleHousingData;



/* Standardize Date Format */

SELECT SaleDate FROM NashvilleHousing.NashvilleHousingData;

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM NashvilleHousing.NashvilleHousingData

ALTER TABLE NashvilleHousingData
Add SaleDateConverted Date;

Update NashvilleHousingData
SET SaleDateConverted = CONVERT(Date, SaleDate)



/* Populate the Property Address Data (When there is NULL) */

SELECT * FROM NashvilleHousing.NashvilleHousingData
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing.NashvilleHousingData a
JOIN NashvilleHousing.NashvilleHousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.Property is null

UPDATE a
SET  PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing.NashvilleHousingData a
JOIN NashvilleHousing.NashvilleHousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.Property is null



/* Breaking Address into Individual Column (Address, City) */

SELECT PropertyAddress
FROM NashvilleHousing.NashvilleHousingData

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM NashvilleHousing.NashvilleHousingData


ALTER TABLE NashvilleHousingData
Add PropertySplitAddress NVarchar(255);

Update NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousingData
Add PropertySplitCity NVarchar(255);

Update NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))



/* Breaking Owner Addresss into Individual Column(Address, City, State) */


SELECT OwnerAddress 
FROM NashvilleHousing.NashvilleHousingData

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '-'), 3 )
,PARSENAME(REPLACE(OwnerAddress, ',', '-'), 2 )
,PARSENAME(REPLACE(OwnerAddress, ',', '-'), 1 )
FROM NashvilleHousing.NashvilleHousingData

ALTER TABLE NashvilleHousingData
Add OwnerSplitAddress NVarchar(255);

Update NashvilleHousingData
SET OwnerSplitAddress = (REPLACE(OwnerAddress, ',', '-'), 3 )

ALTER TABLE NashvilleHousingData
Add OwnerSplitCity NVarchar(255);

Update NashvilleHousingData
SET OwnerSplitCity = (REPLACE(OwnerAddress, ',', '-'), 2 )

ALTER TABLE NashvilleHousingData
Add OwnerSplitState NVarchar(255);

Update NashvilleHousingData
SET OwnerSplitState = (REPLACE(OwnerAddress, ',', '-'), 1 )




/* Change Y to Yes and N to No in "SoldAsVacant" */


SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing.NashvilleHousingData
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END
FROM NashvilleHousing.NashvilleHousingData


UPDATE NashvilleHousingData
SET SoldAsVacant = CASEWHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END
    
    
    
/* Remove Duplicates */

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER(
    PARTITION BY ParcelID,
				PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
                ORDER BY 
                UniqueID
                )row_num
FROM NashvilleHousing.NashvilleHousingData
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



/* Delete Unused Column */

ALTER TABLE NashvilleHousing.NashvilleHousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing.NashvilleHousingData
DROP COLUMN SaleDate