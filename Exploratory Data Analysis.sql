-- Exploratory Data Analysis

SELECT * 
FROM layoffs_Staging2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_Staging2;

SELECT * 
FROM layoffs_Staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company,industry, SUM(total_laid_off) total_laid
FROM layoffs_Staging2
GROUP BY company, industry
ORDER BY total_laid DESC;

SELECT country, SUM(total_laid_off) total_laid
FROM layoffs_Staging2
GROUP BY country
ORDER BY total_laid DESC;

SELECT `date`, SUM(total_laid_off) total_laid
FROM layoffs_Staging2
GROUP BY `date`
ORDER BY 1 DESC;

SELECT YEAR(`date`), SUM(total_laid_off) total_laid
FROM layoffs_Staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

SELECT stage, SUM(total_laid_off) total_laid
FROM layoffs_Staging2
GROUP BY stage
ORDER BY 2 DESC;

#Rolling total day-offs
SELECT MONTH(`date`),YEAR(`date`), SUM(total_laid_off)
FROM layoffs_Staging2
GROUP BY MONTH(`date`), YEAR(`date`)
ORDER by MONTH(`date`),YEAR(`date`) ASC ;

# OR (both give same result)

SELECT SUBSTRING(`date`,1,7) AS MONTH, SUM(total_laid_off)
FROM layoffs_Staging2
GROUP BY MONTH
ORDER BY 1 ASC;

# Rolling total over months
WITH rolling_cte AS
(
SELECT SUBSTRING(`date`,1,7) AS MONTH, SUM(total_laid_off) AS total_off
FROM layoffs_Staging2
GROUP BY MONTH
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off,
SUM(total_off) OVER(Order By `MONTH`) As rolling_total
FROM rolling_cte;

/*
Select MONTH(`date`),YEAR(`date`), SUM(total_laid_off) 
OVER(partition by MONTH(`date`) Order by MONTH(`date`) ASC ) As Rolling_test
Group By MONTH(`date`),YEAR(`date`)
FROM layoffs_Staging2;
But can't use group by and a window function together. we need CTE for it.
*/

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_Staging2
GROUP BY company,YEAR(`date`)
ORDER BY 3 DESC;


WITH company_Year (comapny, years, total_laid_off) AS
(
	SELECT company, YEAR(`date`), SUM(total_laid_off)
	FROM layoffs_Staging2
	GROUP BY company,YEAR(`date`)
),
Company_Year_Rank AS
(
	SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
	FROM company_Year
	WHERE years IS NOT NULL
)
SELECT * 
FROM company_Year_Rank
WHERE Ranking <= 5;












