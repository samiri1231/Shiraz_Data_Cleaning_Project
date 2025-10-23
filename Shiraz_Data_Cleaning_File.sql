-- DATA CLEANING

SELECT *
FROM layoffs_raw;

-- STEPS

# Before you do any data manipulation it is important that you do not touch the raw dataset,
# the 'layoffs_raw' table is our raw dataset #obviously


# 1. Remove Duplicates if there are any
# 2. Standardize Data
# 3. Null Values or Blank Values
# 4. Remove any columns that arent necessary


CREATE TABLE layoffs_staging
LIKE layoffs_raw;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs_raw;

# only touch the staging database

-- REMOVING THE DUPLICATES

#identify duplicates

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;
-- Date is written with the backtick because it is something in sql and this gets around that
-- backtick is the one under tilde (~)

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location, industry, total_laid_off, percentage_laid_off, `date`, 
stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;
# ^^ this function creates a CTE that adds a row number to each unique item in the table based on all the columns,
# if there is a matching column it will change the row to number 2
# then it selects every column from the 'new table' where every row number is greater than 1 (all the duplicates)
# this is possible to be written as a subquery but its good practice to make it a CTE


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
# ^^ The idea here is to create a new table for all the duplicate values
# I did not right this out and instead I right clicked layoffs_staging > copy to clipboard > create table
# pasted it into the file and then added the row_num column

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location, industry, total_laid_off, percentage_laid_off, `date`, 
stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;
# ^^ this means we can use row_num without adding a new column to the staging table (would not be great)
# AND we can use the row_num column without needing to run the CTE every time

# ^^ this function simply adds all the rows into the new table along with the row num column
# this lets us filter using where
# ^^ assumption is that there is going to be some form of join shenaniganry to remove duplicates
# ^^ actually since this table has all the data we can just delete it from the table
# (we couldnt earlier because the delete function is an update function and that does not work with CTE's

DELETE
FROM layoffs_staging2
WHERE row_num > 1;




