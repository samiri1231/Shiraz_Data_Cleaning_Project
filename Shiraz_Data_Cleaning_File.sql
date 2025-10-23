-- DATA CLEANING
# small disclaimer!! 
# My comment formatting might be weird to some but thats just cause i dont like having to scroll
# to see the rest of the comment, also zooming out is weird

SELECT *
FROM layoffs_raw;

-- STEPS

# Before you do any data manipulation it is important that you do not touch the raw dataset,
# the 'layoffs_raw' table is our raw dataset #obviously


# if you want to jump to any step, cntrl+f (command+f) and type the step number
# Example: 6., 7., etc (using steps that dont exist so it doesnt mess up the find) 
# it will be the second instance of it occuring 

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

-- 1. REMOVING THE DUPLICATES

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
-- this deleted every duplicate :D yayyy

SELECT *
FROM layoffs_staging2;

-- now the row_num column is redundant and white (the bear reference) so we can get rid of it

-- DUPLICATES REMOVED :DDD



-- 2. STANDARDIZING DATA 
# finding problems and fixing it so it all looks the same

SELECT company, TRIM(company)
FROM layoffs_staging2;
# ^^ all it does is trim the spaces before and after, we are going to use this to update

UPDATE layoffs_staging2
SET company = TRIM(company);
# UPDATE => hey i wonder what this does
# SET => this is the criteria of what you want to do

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;
# this shows us the distinct industries to see if there is some redundancies
# there is redundancies in the form of 'crypto' and 'crypto Currency' like thats the same industry
# the order by is there to make it alphabetical :D

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';
# ^ showing all the layoffs in the 'crypto'+ industry
# the percent just means that there can be any word after crypto
# but it has to start with crypto

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';
# ^ this updates the layoffs _staging2 table to make every 'crypto'+ just 'crypto'
# typing out crypto so much makes the word look weird lol

SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY location;
# it is good practice to check every column just to make sure there are no issues
# the location looks fine but you never know!
# its just being thourough for the rest of these queries in this section, standardization is complete

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;
# holy poop i lied there is a duplicate

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';
# it was fixed dont worry
# you can also use a TRIM(TRAILING '.' FROM country) function for larger datasets
# if there are a bunch of rows with the .'s at the end its better to use the above one
# instead of writing this query out like 9 trillion times

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM COUNTRY) -- hey remove the trailing . from that country
WHERE country LIKE  '%.';
# this finds any country ending in a . and removes the period


SELECT DISTINCT stage
FROM layoffs_staging2
ORDER BY stage;
# stage is normal - no problems

SELECT DISTINCT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y') -- this is a difficult thing to remember after one use
# ^^ it is caps sensitive and UPPER('m') will null ur data
# ^^ LOWER('Y') will return the first two data digits in the year repeated
 layoffs_staging2;
# I plan to practice the STR_TO_DATE() and commit it to memory
# the data is set to be a text value, but if we want to do any meaningful visualization 
# we have to change it to be a date value
# standard date format in mysql is year-month-date

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
# ^^ there is no need for a where function/clause because we are changing every date value
# this is still a text value, it is in the date format but its still a string

# ^^ you have to change it into the date format if you want to change it into date value
# otherwise it will error (it doesnt know what those funky symbols mean without them being
# in a specific format)

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;
# only ever do this to a staging table, do not do this to the raw
# it is very important you NEVER modify the raw (unless asked to or smth idk)

# Format for alter table is 
/*
ALTER TABLE table_name
MODIFY (whatever you want to change) (specific name of thing) (what you want to change it to)
vv Example
MODIFY COLUMN `date` DATE;
changes the column named date to be the data type date
*/

SELECT *
FROM layoffs_staging2;

-- STANDARDIZATION IS DONE!!


-- 3. WORKING WITH NULL AND BLANK VALUES

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
# ^^ you have to use IS NULL because = NULL does not work
# because null is not a value it is an placeholder that means theres no value

# the areas that have no data on total laid off and percentage laid off are useless to us
# for the sake of the project we will be removing them


SELECT *
FROM layoffs_staging2
WHERE industry IS NULL 
OR industry = '';
# notice how you can = blanks and not nulls 
# to restate, its because blank is an actual value but null just means absence of value

# first thing you wanna do if you have empty fields, is you want to see if you can populate it
# look through the data!!
# see if another entry has the answer :D

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';
# looking to find other entries to see if there is any data we can fix

SELECT s1.industry, s2.industry
FROM layoffs_staging2 s1
JOIN layoffs_staging2 s2
	ON s1.company = s2.company
    AND s1.location = s2.location -- its always good practice to make it redundant just in case
WHERE (s1.industry IS NULL OR s1.industry = '')
# ^^ if you dont add parenthesis its gonna do it double because its or-anding
AND s2.INDUSTRY IS NOT NULL;
/* 
This needs an explanation because I personally dont really understand joins perfectly

You are 'making' 2 exact same tables and joining them on the basis that the company is the same
and the location is the same (just to make sure you dont overwrite something on accident)

and you are joining a filled out piece of info, to wherever it matches and if there is no info

*/
# ^^ this is all just to see the areas they match, now we have to write the update statement

-- since blanks act weird its more uniform if you just make all the blanks NULL

UPDATE layoffs_staging2
set industry = NULL -- when you are setting something to null it is okay to use =
WHERE industry = '';


UPDATE layoffs_staging2 s1 -- the table you are updating
JOIN layoffs_staging2 s2 -- joining the same table to it
	ON s1.company = s2.company -- on the basis that company and location match
    AND s1.location = s2.location
SET s1.industry = s2.industry -- you make the original = the doppelganger
WHERE (s1.industry IS NULL OR s1.industry = '') -- if and only if the original is empty there
AND s2.industry IS NOT NULL; -- and the doppelganger has an answer
# so you iterate through the joined table, and wherever the where function is true
# you set it

#  If you look at the table for NULL values in the industry column, Bally's is still there
# this is because it did not have another entry to check and update off of

# We cannot update the other columns with null values because there is not enough information
# this means we are done with the NUll and Blanks portion

-- Nulls And Blanks Completed!!!



-- 4. REMOVING UNECESSARY COLUMNS

SELECT *
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

# earlier above I stated 
# that if we dont know the total and the percentage laid off theres nothing we can do
# so we are going to delete the rows where this is the case


SELECT COUNT(*)
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
# this code just returns the count of how many rows were returned from that query


DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
# so long data that was honestly useless

# now we want to get rid of that yucky row_num column that we used in the beginning
# you use the drop column function

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;

-- DATA CLEANING COMPLETE !!!
# Congrats on successfully cleaning this dataset.


