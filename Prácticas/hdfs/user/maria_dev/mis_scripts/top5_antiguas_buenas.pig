/* PR_03.2 - Apartado C: 5 Películas más antiguas con media > 4 */

-- 1. Cargar valoraciones
ratings = LOAD '/user/maria_dev/u.data' USING PigStorage('\t') 
    AS (user_id:int, movie_id:int, rating:int, timestamp:int);

-- 2. Cargar películas (Esquema completo necesario para leer la fecha)
-- Formato u.item: id|titulo|fecha_estreno|...
movies = LOAD '/user/maria_dev/u.item' USING PigStorage('|') 
    AS (movie_id:int, title:chararray, release_date:chararray, video_release:chararray, imdb_url:chararray);

-- 3. Calcular nota media
ratings_group = GROUP ratings BY movie_id;
avg_ratings = FOREACH ratings_group GENERATE 
    group AS movie_id, 
    AVG(ratings.rating) AS score;

-- 4. Filtrar solo las "buenas" (> 4.0)
good_movies = FILTER avg_ratings BY score > 4.0;

-- 5. Unir con metadatos de la película
joined_data = JOIN good_movies BY movie_id, movies BY movie_id;

-- 6. Filtrar películas sin fecha (para evitar errores al convertir)
valid_movies = FILTER joined_data BY (movies::release_date IS NOT NULL) AND (SIZE(movies::release_date) > 5);

-- 7. Proyectar y Convertir Fecha
/* Usamos ToDate para convertir el string '01-Jan-1995' a objeto fecha real.
   El formato 'dd-MMM-yyyy' interpreta meses como Jan, Feb, etc. */
final_data = FOREACH valid_movies GENERATE 
    good_movies::movie_id AS id, 
    movies::title AS title, 
    good_movies::score AS score,
    ToDate(movies::release_date, 'dd-MMM-yyyy') AS full_date;

-- 8. Ordenar por fecha ASCENDENTE (de más antigua a más nueva)
ordered_data = ORDER final_data BY full_date ASC;

-- 9. Top 5
top5_oldest = LIMIT ordered_data 5;

-- 10. Mostrar y Guardar
DUMP top5_oldest;

fs -rm -r -f top5_oldest_good_movies;
STORE top5_oldest INTO 'top5_oldest_good_movies' USING PigStorage('|');
