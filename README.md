# Netflix Movies and TV Shows Data Exploration Using SQL

![Netflix Logo](https://github.com/dinesh-1623/Netflix_sql_project/blob/main/logo.png)


## Overview
This project focuses on an in-depth analysis of Netflix's movie and TV show dataset using SQL. The primary objective is to uncover valuable insights and address key business questions. This README provides a detailed overview of the project's goals, challenges, methodologies, findings, and conclusions.


## Objectives
-Examine the distribution of content types (Movies vs. TV Shows).
-Identify the most frequently assigned ratings for movies and TV shows.
-Analyze content trends based on release years, countries of origin, and duration.
-Classify and filter content based on specific keywords and predefined criteria.


## Dataset

The dataset used for this project is sourced from Kaggle:


- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
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
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT type, COUNT(*) as Total_Content
FROM netflix
GROUP BY type
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
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
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT title,release_year
FROM netflix
WHERE  release_year = 2020
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT UNNEST(STRING_TO_ARRAY(country, ','))AS new_country,COUNT(show_id) as Total_Content
FROM netflix

GROUP BY 1
order by 2 DESC
LIMIT 5
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT * FROM netflix
WHERE
	type='Movie' AND
	duration=(SELECT MAX(duration) FROM netflix) 
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
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
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT type,title, director 
FROM netflix 
WHERE director LIKE '%Rajiv Chilaka%'
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql

SELECT * FROM netflix
WHERE type= 'TV Show'
AND SPLIT_PART(duration, ' ', 1)::INT > 5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT UNNEST(STRING_TO_ARRAY(listed_in,','))AS Genre, COUNT(*) AS total_shows
FROM netflix 
GROUP BY 1
ORDER BY 2 DESC
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
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
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries%'
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT * FROM netflix
WHERE director IS null 
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT * FROM netflix
WHERE casts LIKE '%Salman Khan%'   AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
SELECT UNNEST(STRING_TO_ARRAY(casts,','))AS Highest, COUNT(*) AS total_shows
FROM netflix 
WHERE country='India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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
```

**Objective:** Classify content as 'Bad' if it contains keywords like 'kill' or 'violence' and 'Good' otherwise. Determine the total count of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset showcases a diverse collection of movies and TV shows spanning multiple genres and ratings.
- **Common Ratings:** Identifying the most frequent ratings helps understand the primary target audience of Netflix's content.
- **Geographical Insights:** Analysis of top-producing countries and India's average content output highlights geographical distribution patterns.
- **Content Categorization:** Categorizing content based on specific keywords offers insights into the nature and thematic elements of Netflix's catalog.

This analysis delivers a detailed perspective on Netflix's content landscape, aiding in content strategy development and informed decision-making.







