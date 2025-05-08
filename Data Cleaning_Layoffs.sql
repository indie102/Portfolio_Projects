-- Data Cleaning
/*
The Layoffs Dataset

skills used: Joins, Views, CTE's, Temp tables, Window Function, Aggregate Functions
*/
Select * 
From layoffs;

Create table layoffs_Staging
Like layoffs;

Select * from layoffs_Staging;

Insert layoffs_Staging
Select * 
From layoffs;

#1. Remove duplicates
Select * From layoffs;
Select * From layoffs_Staging;

Select *,
Row_number() Over(
Partition by Company, Industry, total_laid_off, percentage_laid_off, `Date`) As row_num
From layoffs_Staging;

With Duplicate_CTE As
(
Select *,
Row_number() Over(
Partition by Company, location, Industry, total_laid_off, percentage_laid_off, `Date`, 
stage, country, funds_raised_millions) As row_num
From layoffs_Staging
)
Select *
From Duplicate_CTE
Where row_num >1;

CREATE TABLE `layoffs_Staging2` (
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

Select * From layoffs_Staging2;

Insert Into layoffs_Staging2
Select *,
Row_number() Over(
Partition by Company, location, Industry, total_laid_off, percentage_laid_off, `Date`, 
stage, country, funds_raised_millions) As row_num
From layoffs_Staging;

Select * From layoffs_Staging2;

Select * From layoffs_Staging2 Where row_num>1; #shows duplicate enteries
Delete From layoffs_Staging2 Where row_num>1;   #delete duplicate rows
Select * From layoffs_Staging2;					#After delete duplicate rows

#2. Standaridizing Data Finding issues in data and fixing it
#2a. TRIM: remove unwanted space
Select DISTINCT(Company)
From layoffs_Staging2;

Update layoffs_Staging2
SET company = TRIM(company);

Select DISTINCT(Company)
From layoffs_Staging2;

Select DISTINCT industry 
From layoffs_Staging2
ORDER BY 1;

Update layoffs_Staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

Select DISTINCT Location From layoffs_Staging2 Order by 1;

Select DISTINCT Country From layoffs_Staging2 Order by 1;

Select DISTINCT Country, TRIM(TRAILING '.' FROM country) 
From layoffs_Staging2 
Order by 1;

Update layoffs_Staging2 
SET country = TRIM(TRAILING '.' FROM country) 
WHERE country lIKE 'United States%';

SELECT `date`,
str_to_date(`date`,'%m/%d/%Y')
From layoffs_Staging2 ;

Update layoffs_Staging2 
SET `date` = str_to_date(`date`,'%m/%d/%Y');

SELECT `date`
From layoffs_Staging2 ;

ALTER Table layoffs_Staging2
Modify Column `date` DATE;

Select * From layoffs_Staging2;

#3. Null values
Select *
From layoffs_Staging2
Where total_laid_off IS NULL
AND percentage_laid_off IS NULL;

Select * 
From layoffs_Staging2
Where industry IS NULL OR industry = ' ';

#let's see if we can populate industry name from company.
Select * 
From layoffs_Staging2
Where company = "Bally's Interactive";

Select * 
From layoffs_Staging2 t1
JOIN layoffs_Staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry= ' ')
AND t2.industry IS NOT NULL;

#If enteries present, we populate the missing values
UPDATE layoffs_Staging2 t1
JOIN layoffs_Staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry= ' ')
AND t2.industry IS NOT NULL;

#4. Drop unwanted rows/cols
SELECT * 
FROM layoffs_Staging2 
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_Staging2 
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_Staging2 
DROP COLUMN row_num;

Select * FROM layoffs_Staging2 ;


