/* PR_03.2 - Apartado A: Top 5 Películas más votadas */

-- 1. Cargar valoraciones (u.data es separado por tabuladores)
ratings = LOAD '/user/maria_dev/u.data' USING PigStorage('\t') 
    AS (user_id:int, movie_id:int, rating:int, timestamp:int);

-- 2. Cargar películas (u.item es separado por tuberías |)
movies = LOAD '/user/maria_dev/u.item' USING PigStorage('|') 
    AS (movie_id:int, title:chararray, release_date:chararray, video_release_date:chararray, imdb_url:chararray);

-- 3. Agrupar valoraciones por película para contarlas
ratings_group = GROUP ratings BY movie_id;

-- 4. Contar votos por película
votes_count = FOREACH ratings_group GENERATE 
    group AS movie_id, 
    COUNT(ratings) AS num_votes;

-- 5. Unir con el nombre de la película (JOIN)
-- Unimos la relación de conteos con la de películas por el campo movie_id
joined_data = JOIN votes_count BY movie_id, movies BY movie_id;

-- 6. Proyectar solo los datos que nos piden (Id, Titulo, Votos)
final_data = FOREACH joined_data GENERATE 
    votes_count::movie_id AS id, 
    movies::title AS title, 
    votes_count::num_votes AS votes;

-- 7. Ordenar por número de votos descendente
ordered_data = ORDER final_data BY votes DESC;

-- 8. Limitar a 5
top5 = LIMIT ordered_data 5;

-- 9. Mostrar y Guardar
DUMP top5;

-- Limpiamos carpeta de salida por si existe
fs -rm -r -f top5_most_voted;
STORE top5 INTO 'top5_most_voted' USING PigStorage('|');
