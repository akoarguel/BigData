/* PR_03.2 - Apartado B: Top 10 Películas mejor valoradas (Media) */

-- 1. Cargar valoraciones
ratings = LOAD '/user/maria_dev/u.data' USING PigStorage('\t') 
    AS (user_id:int, movie_id:int, rating:int, timestamp:int);

-- 2. Cargar películas
movies = LOAD '/user/maria_dev/u.item' USING PigStorage('|') 
    AS (movie_id:int, title:chararray, release_date:chararray, video_release_date:chararray, imdb_url:chararray);

-- 3. Agrupar valoraciones por película
ratings_group = GROUP ratings BY movie_id;

-- 4. Calcular la media de votos por película
avg_ratings = FOREACH ratings_group GENERATE 
    group AS movie_id, 
    AVG(ratings.rating) AS avg_score;

-- 5. Unir con el nombre de la película (JOIN)
joined_data = JOIN avg_ratings BY movie_id, movies BY movie_id;

-- 6. Proyectar los datos finales (Id, Titulo, Media)
final_data = FOREACH joined_data GENERATE 
    avg_ratings::movie_id AS id, 
    movies::title AS title, 
    avg_ratings::avg_score AS score;

-- 7. Ordenar por nota media descendente
ordered_data = ORDER final_data BY score DESC;

-- 8. Limitar a 10
top10 = LIMIT ordered_data 10;

-- 9. Mostrar y Guardar
DUMP top10;

-- Limpieza y almacenamiento
fs -rm -r -f top10_best_rated;
STORE top10 INTO 'top10_best_rated' USING PigStorage('|');
