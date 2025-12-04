/* PR_03.2 - Apartado D: Película favorita por ocupación (CORREGIDO) */

-- 1. Cargar datos
ratings = LOAD '/user/maria_dev/u.data' USING PigStorage('\t') AS (user_id:int, movie_id:int, rating:int);
users = LOAD '/user/maria_dev/u.user' USING PigStorage('|') AS (user_id:int, age:int, gender:chararray, occupation:chararray);
movies = LOAD '/user/maria_dev/u.item' USING PigStorage('|') AS (movie_id:int, title:chararray);

-- 2. Unir para tener ocupación y nota
ratings_users = JOIN ratings BY user_id, users BY user_id;

-- 3. Calcular nota media por (Ocupación, Película)
grp_occ_movie = GROUP ratings_users BY (users::occupation, ratings::movie_id);
avg_ratings = FOREACH grp_occ_movie GENERATE 
    group.occupation AS occupation, 
    group.movie_id AS movie_id, 
    AVG(ratings_users.rating) AS score;

-- 4. Encontrar la MEJOR película por ocupación
grp_occ = GROUP avg_ratings BY occupation;

best_per_occ = FOREACH grp_occ {
    ordered = ORDER avg_ratings BY score DESC;
    top1 = LIMIT ordered 1;
    -- AQUÍ ESTABA EL ERROR: Definimos explícitamente los nombres al aplanar
    GENERATE FLATTEN(top1) AS (occupation, movie_id, score);
};

-- 5. Unir con Películas para tener el título
final_join = JOIN best_per_occ BY movie_id, movies BY movie_id;

-- 6. Proyección final
result = FOREACH final_join GENERATE 
    best_per_occ::occupation AS occupation, 
    movies::title AS title, 
    best_per_occ::score AS score;

-- 7. Ordenar y guardar
result_sorted = ORDER result BY occupation ASC;

DUMP result_sorted;

fs -rm -r -f best_movie_by_occupation;
STORE result_sorted INTO 'best_movie_by_occupation' USING PigStorage('|');
