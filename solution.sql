DROP TABLE IF EXISTS netflix;

CREATE TABLE netflix (
    show_id VARCHAR(6),
    type VARCHAR(10),
    title VARCHAR(150), 
    director VARCHAR(208),
    casts VARCHAR(1000),
    country VARCHAR(150),
    date_added VARCHAR(50),
    release_year INT,
    rating VARCHAR(10),
    duration VARCHAR(15),
    listed_in VARCHAR(100),
    description TEXT  
);

SELECT * FROM netflix;

SELECT COUNT(*) as Total_content
FROM netflix;



SELECT Distinct type FROM netflix;

SELECT country,release_year, COUNT(*) as Total_Content
FROM netflix
WHERE  release_year > 2020
GROUP BY country, release_year


SELECT title,country, release_year FROM netflix
WHERE country= 'India' and release_year > 2020;

SELECT COUNT(Distinct(type)) as Total_content
FROM netflix;

SELECT COUNT(DISTINCT(rating))
FROM netflix;

--15 Business Problems--

--1. Count the Number of Movies vs TV Shows--

SELECT type, COUNT(*) as Total_Content
FROM netflix
GROUP BY type

--2. Find the Most Common Rating for Movies and TV Shows--
	SELECT type, rating, count, rank
FROM (
    SELECT 
        type,
        rating,
        COUNT(*) AS count,
        RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS rank
    FROM netflix
    GROUP BY type, rating
) AS t1
WHERE rank = 1;



--3. List All Movies Released in a Specific Year (e.g., 2020)--

SELECT title,release_year
FROM netflix
WHERE  release_year = 2020

--4. Find the Top 5 Countries with the Most Content on Netflix--

SELECT UNNEST(STRING_TO_ARRAY(country, ','))AS new_country,COUNT(show_id) as Total_Content
FROM netflix

GROUP BY 1
order by 2 DESC
LIMIT 5

--5. Identify the Longest Movie--

SELECT * FROM netflix
WHERE
	type='Movie' AND
	duration=(SELECT MAX(duration) FROM netflix) 


--6. Find Content Added in the Last 5 Years--
SELECT * 
FROM netflix
WHERE 
    CASE 
        WHEN date_added ~ '^[0-9]{1,2}-[A-Za-z]{3}-[0-9]{2}$' 
        THEN TO_DATE(date_added, 'DD-Mon-YY')
        WHEN date_added ~ '^[A-Za-z]+ [0-9]{1,2}, [0-9]{4}$' 
        THEN TO_DATE(date_added, 'Month DD, YYYY')
    END 
    >= CURRENT_DATE - INTERVAL '5 years';

--7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'--

SELECT type,title, director 
FROM netflix 
WHERE director LIKE '%Rajiv Chilaka%'

--8. List All TV Shows with More Than 5 Seasons--

SELECT * FROM netflix
WHERE type= 'TV Show'
AND SPLIT_PART(duration, ' ', 1)::INT > 5;

--9. Count the Number of Content Items in Each Genre--

SELECT UNNEST(STRING_TO_ARRAY(listed_in,','))AS Genre, COUNT(*) AS total_shows
FROM netflix 
GROUP BY 1
ORDER BY 2 DESC

--10.Find each year and the average numbers of content release in India on netflix.--


SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC NULLS LAST
LIMIT 5;


--11. List All Movies that are Documentaries--

SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries%'


--12. Find All Content Without a Director--

SELECT * FROM netflix
WHERE director IS null 

,count(*)

--13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years--


SELECT * FROM netflix
WHERE casts LIKE '%Salman Khan%'   AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;


--14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India--

SELECT UNNEST(STRING_TO_ARRAY(casts,','))AS Highest, COUNT(*) AS total_shows
FROM netflix 
WHERE country='India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

--15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords--


SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;