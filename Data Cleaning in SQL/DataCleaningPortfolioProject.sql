/*
	Cleaning Data in SQL Queries
*/


Select *
From PortfolioProject..NashvilleHousing

------------------------------------------------------------------------------------------------------------------

-- Altering the data type of SaleDate Column form datetime to date

Alter table PortfolioProject..NashvilleHousing
Alter column SaleDate date

------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

-- Checking
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Populating
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into individual columns (Address, City, State)

-- Verifying the split positions

Select PropertyAddress,
TRIM(SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)) as Address,
TRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))) as Address2
From PortfolioProject..NashvilleHousing

-- By using SUBSTRING

Alter Table PortfolioProject..NashvilleHousing
Add PropertySplitAddress nvarchar(255)

Update PortfolioProject..NashvilleHousing
SET PropertySplitAddress = TRIM(SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1))

Alter Table PortfolioProject..NashvilleHousing
Add PropertySplitCity nvarchar(255)

Update PortfolioProject..NashvilleHousing
SET PropertySplitCity = TRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)))

Select PropertyAddress, PropertySplitAddress, PropertySplitCity
From PortfolioProject..NashvilleHousing


-- By using PARSENAME

Select OwnerAddress,
TRIM(PARSENAME(Replace(OwnerAddress, ',', '.'), 3)),
TRIM(PARSENAME(Replace(OwnerAddress, ',', '.'), 2)),
TRIM(PARSENAME(Replace(OwnerAddress, ',', '.'), 1))
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitCity nvarchar(255)

Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitState nvarchar(255)


Update PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = TRIM(PARSENAME(Replace(OwnerAddress, ',', '.'), 3))

Update PortfolioProject..NashvilleHousing
SET OwnerSplitCity = TRIM(PARSENAME(Replace(OwnerAddress, ',', '.'), 2))

Update PortfolioProject..NashvilleHousing
SET OwnerSplitState = TRIM(PARSENAME(Replace(OwnerAddress, ',', '.'), 1))

------------------------------------------------------------------------------------------------------------------

-- Changing 'Y' to 'Yes' and 'N' to 'No'

-- View number of 'Y', 'N', 'Yes', 'No'
Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

-- Testing
Select SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
From PortfolioProject..NashvilleHousing

-- Updation of 'Y' to 'Yes' and 'N' to 'No'
Update PortfolioProject..NashvilleHousing
SET SoldAsVacant =  
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END

------------------------------------------------------------------------------------------------------------------

-- Removing Duplicates

Select *,
ROW_NUMBER() Over (
	Partition by ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
	Order By UniqueID
) row_num
From PortfolioProject..NashvilleHousing
