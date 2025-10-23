# Shiraz_Data_Cleaning_Project
A complete MySQL data cleaning pipeline for a layoffs dataset using CTEs window functions, and ETL best practices. With my own 'documentation' (comments explaining the code)


Hey! Thanks for spending the time to look at my little project here.

### Overview 
This project demonstrates a full **Data cleaning and transformation pipeline** in **MySQL**, preparing a raw real-world layoffs dataset for analysis. It follows **ETL (Extract, Transform, Load)** principles and includes duplicate removal, standardization, null/blank handiling, and data type conversion.

### Tools and Skills :D
- SQL (specifically MySQL)
- CTES and Window functions (`ROW_NUMBER()`)
- Data Standardization and Normalization
- Data validation and Null Handling
- Schema Modification and Type Conversion (`STR_TO_DATE()`)
- ETL and Data Transformation Best Pracitces
- Active commenting (although its not the most professional :D)

  ## Steps
  1. Created staging tables to perserve raw data integrity
  2. Identified and removed duplicates using `ROW_NUMBER()` and CTEs
  3. Standardized company, industry, country, and date fields (see below for date)
  4. Converted string dates to proper date format `STR_TO_DATE()` and then to DATE value
  5. Filled missing values via self-joins and deleted unusable rows
  6. Delivered a fully cleaned dataset ready for visualization in Power BI / Tableau
  7. Sets up Exploratory Data Analysis (next project.. stay tuned!)

  ## Files
 - **Shiraz_Data_Cleaning_File.sql** => SQL script containing full cleaning workflow along with 'personality filled comments' explaining workflow (SFW)
 - **README.md** Project Overview (what you're reading now)
 - **layoffs.csv** Original data files (For before and after cleaning)


Once again thanks for spending the time to read this, have a great day!!


**Author:** Shiraz A. (aka your friendly neighborhood spiderman :p)
*BIT - Decision Support Systems | Virginia Tech*
