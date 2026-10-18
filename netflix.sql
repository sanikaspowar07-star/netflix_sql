#Step 1:Check the table structure
use netflix;
describe netflix_data;

#Step 2:View the dataset 
select * from netflix_data limit 10;

#Step 3:Count total records
select count(*) as total_records from netflix_data;

#Step 4:Find all content types 
select type,count(*) as total_count 
from netflix_data group by type;

#Step 5:Find Missing Values
SELECT
SUM(CASE WHEN show_id IS NULL THEN 1 ELSE 0 END) AS missing_show_id,
SUM(CASE WHEN type IS NULL THEN 1 ELSE 0 END) AS missing_type,
SUM(CASE WHEN title IS NULL THEN 1 ELSE 0 END) AS missing_title,
SUM(CASE WHEN director IS NULL THEN 1 ELSE 0 END) AS missing_director,
SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS missing_country,
SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS missing_rating,
SUM(CASE WHEN duration IS NULL THEN 1 ELSE 0 END) AS missing_duration
FROM netflix_data;

#Step 6:Check Duplicate Records 
select show_id, count(*) as total_count
from netflix_data
group by show_id 
having count(*)>1;

#Step 7:Analyze Netflix Content 
#Find the most common rating 
select rating,count(*) as total_count
from netflix_data
where rating is not null
group by rating 
order by total_count desc
limit 1;

#Find the top 10 directors
select director, count(*) as total_titles
from netflix_data
where director is  not null 
group by director 
order by total_titles desc limit 10;

#Count Movies Released each year
select release_year, count(*) as total_movies
from netflix_data 
where type='Movie'
group by release_year 
order by release_year desc;

#Step 8:Analyze TV shows 
#Find TV shows with the most Seasons 
select title,duration from netflix_data
where type='TV Show'and duration is not null 
order by cast(substring_index(duration,'',1)as unsigned)desc
limit 10;

#Count Movies by Duration 
select duration,count(*) as total_movies 
from netflix_data 
where type='Movie'
and duration is not null 
group by duration 
order by total_movies desc limit 10;

#Compare Movies and TV Shows 
select type,count(*) as total_titles,round(count(*)*100.0/(select count(*) from netflix_data),
2)as percentage from netflix_data group by type;

#Advanced SQL Analysis 
#Find the top 10 most common geners
select listed_in as genre,
count(*) as total_titles from netflix_data 
where listed_in is not null 
group by listed_in order by total_titles desc limit 10;

#Find the top 5 countries with the most netflix titles
SELECT
country,
COUNT(*) AS total_titles
FROM netflix_data
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_titles DESC
LIMIT 5; 

#Find the total number of movies released in each year 
SELECT
release_year,
COUNT(*) AS total_movies
FROM netflix_data
WHERE type = 'Movie'
GROUP BY release_year
ORDER BY release_year DESC;

#Find the Tv shows with the longest duration 
SELECT
title,
duration
FROM netflix_data
WHERE type = 'TV Show'
AND duration IS NOT NULL
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC
LIMIT 10;

#Find the directors who have directed the most netflix titles 
SELECT
director,
COUNT(*) AS total_titles
FROM netflix_data
WHERE director IS NOT NULL
GROUP BY director
ORDER BY total_titles DESC
LIMIT 10;

#find the number of movies and tv shows released before the year 2010 
SELECT
type,
COUNT(*) AS total_titles
FROM netflix_data
WHERE release_year < 2010
GROUP BY type;

#Find the most rating on netflix 
SELECT
rating,
COUNT(*) AS total_titles
FROM netflix_data
WHERE rating IS NOT NULL
GROUP BY rating
ORDER BY total_titles DESC
LIMIT 1;

#Find the Movies released in the last 5 years of your dataset 
SELECT
title,
release_year,
type
FROM netflix_data
WHERE type = 'Movie'
ORDER BY release_year DESC
LIMIT 10;

#Find the top 10 most frequently occuring actors on netflix 
SELECT
TRIM(actor_name) AS actor_name,
COUNT(*) AS total_titles
FROM netflix_data
CROSS JOIN JSON_TABLE(
CONCAT('["', REPLACE(REPLACE(cast, ', ', '","'), '"', '\\"'), '"]'),
'$[*]' COLUMNS (
actor_name VARCHAR(255) PATH '$'
    )
) AS actors
WHERE cast IS NOT NULL
GROUP BY actor_name
ORDER BY total_titles DESC
LIMIT 10;

#find the average release year of netflix content by type 
SELECT
type,
ROUND(AVG(release_year), 0) AS average_release_year
FROM netflix_data
WHERE release_year IS NOT NULL
GROUP BY type;

#Percentage distribution of movies vs Tv Shows
SELECT
    type,
    COUNT(*) AS total_titles,
    ROUND(
	COUNT(*) * 100.0 / (SELECT COUNT(*) FROM netflix_data),
	2
    ) AS percentage
FROM netflix_data
GROUP BY type;

#Ranking Countries using window functions 
SELECT
    country,
    total_titles,
    RANK() OVER (ORDER BY total_titles DESC) AS country_rank
FROM (
    SELECT
        country,
        COUNT(*) AS total_titles
    FROM netflix_data
    WHERE country IS NOT NULL
    GROUP BY country
) AS country_counts
ORDER BY country_rank
LIMIT 10;

#Compare content added with its release year 
SELECT
    release_year,
    YEAR(STR_TO_DATE(date_added, '%M %d, %Y')) AS year_added,
    COUNT(*) AS total_titles
FROM netflix_data
WHERE date_added IS NOT NULL
GROUP BY
    release_year,
    YEAR(STR_TO_DATE(date_added, '%M %d, %Y'))
ORDER BY year_added, release_year;