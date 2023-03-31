/*

Cleaning Data in SQL Queries 

*/

SELECT *
FROM nashville_housing
ORDER BY uniqueid;

-----------------------------------------------------------------------

--Standardize Date Format
SELECT saledate, CAST(saledate AS DATE)
FROM nashville_housing;

UPDATE nashville_housing
SET saledate = CAST(saledate AS date);

SELECT saledate
FROM nashville_housing;

-----------------------------------------------------------------------

-- Populate Property Address data

SELECT uniqueid, parcelid, propertyaddress
FROM nashville_housing
ORDER BY parcelid;

SELECT n1.parcelid, n1.propertyaddress, n2.parcelid, n2.propertyaddress, COALESCE(n1.propertyaddress, n2.propertyaddress)
FROM nashville_housing AS n1 
JOIN nashville_housing AS n2 
    ON n1.parcelid = n2.parcelid
    AND n1.uniqueid != n2.uniqueid 
WHERE n1.propertyaddress IS NULL;

UPDATE nashville_housing AS n1
SET propertyaddress = COALESCE(n1.propertyaddress, n2.propertyaddress)
    FROM nashville_housing AS n2
    WHERE n1.parcelid = n2.parcelid
    AND n1.uniqueid != n2.uniqueid 
    AND n1.propertyaddress IS NULL;

SELECT *
FROM nashville_housing
WHERE propertyaddress IS NULL; 

-----------------------------------------------------------------------

-- Breaking out address into individual columns  - address, city, state

SELECT propertyaddress
FROM nashville_housing;

SELECT propertyaddress,
    split_part( propertyaddress, ',',1 ) AS address,
    split_part( propertyaddress, ',', 2)AS address
FROM nashville_housing;

ALTER TABLE nashville_housing
ADD COLUMN propertyno VARCHAR(255);

UPDATE nashville_housing
SET propertyno = split_part( propertyaddress, ',',1 );

ALTER TABLE nashville_housing
ADD COLUMN propertycity VARCHAR(255);

UPDATE nashville_housing
SET propertycity = split_part( propertyaddress, ',',2 );

SELECT * 
FROM nashville_housing;

-----------------------------------------------------------------------

--Splitting Owner Addrss

SELECT owneraddress
FROM nashville_housing;

SELECT owneraddress,
    split_part(owneraddress, ',', 1),
    split_part(owneraddress, ',', 2),
    split_part(owneraddress, ',', 3)
FROM nashville_housing;

ALTER TABLE nashville_housing
ADD owneraddresslandmark VARCHAR(255);

ALTER TABLE nashville_housing
ADD ownercity VARCHAR(255);

ALTER TABLE nashville_housing
ADD ownerstate VARCHAR(255);

UPDATE nashville_housing
SET owneraddresslandmark = split_part(owneraddress, ',', 1);

UPDATE nashville_housing
SET ownercity = split_part(owneraddress, ',', 2);

UPDATE nashville_housing
SET ownerstate = split_part(owneraddress, ',', 3);

SELECT owneraddress, owneraddresslandmark, ownercity, ownerstate
FROM nashville_housing;

-----------------------------------------------------------------------

-- Change Yes and No to Y and N in sold as vacant field

SELECT DISTINCT soldasvacant
FROM nashville_housing;

SELECT soldasvacant, count(soldasvacant)
FROM nashville_housing
GROUP BY soldasvacant;

SELECT CASE 
    WHEN soldasvacant = 'N'
    THEN 'No'
    WHEN soldasvacant = 'Y'
    THEN 'Yes'
END
FROM nashville_housing;

UPDATE nashville_housing
SET soldasvacant = (CASE 
    WHEN soldasvacant = 'N'
    THEN 'No'
    WHEN soldasvacant = 'Y'
    THEN 'Yes'
END) 
WHERE soldasvacant IN ('Y','N');

-----------------------------------------------------------------------

-- Removing duplicate records

WITH row_numCTE AS (
SELECT ctid, *, row_number() OVER (
    PARTITION BY parcelid,
    propertyaddress,
    saleprice,
    saledate,
    legalreference
    ORDER BY uniqueid ) AS row_number
FROM nashville_housing
ORDER BY parcelid
)

DELETE 
FROM nashville_housing 
USING row_numCTE
WHERE row_number > 1
    AND row_numCTE.ctid = nashville_housing.ctid;

/*
select *
from row_numCTE
WHERE row_number > 1;
*/
 
 -----------------------------------------------------------------------

--Delete Unused Columns

SELECT *
FROM nashville_housing;

ALTER TABLE nashville_housing
DROP propertyaddress;

ALTER TABLE nashville_housing
DROP COLUMN owneraddress, DROP COLUMN taxdistrict;

-----------------------------------------------------------------------
