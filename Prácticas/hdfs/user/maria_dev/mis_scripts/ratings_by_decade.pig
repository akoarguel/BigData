/* PR_03.2 - Apartado E: Valoración media por décadas */

-- 1. Cargar datos
ratings = LOAD '/user/maria_dev/u.data' USING PigStorage('\t') AS (user_id:int, movie_id:int, rating:int);
-- La fecha viene como '01-Jan-1995'
movies = LOAD '/user/maria_dev/u.item' USING PigStorage('|') AS (movie_id:int, title:chararray, release_date:chararray);

-- 2. Extraer el AÑO y calcular la DÉCADA
-- Filtramos películas sin fecha para evitar errores
movies_clean = FILTER movies BY release_date IS NOT NULL AND SIZE(release_date) > 7;

movies_decade = FOREACH movies_clean GENERATE 
    movie_id, 
    -- El año son los últimos 4 caracteres. Ejemplo '01-Jan-1995' -> SUBSTRING(..., 7, 11)
    (int)SUBSTRING(release_date, 7, 11) AS year;

-- Calculamos la década matemática: (1995 / 10) * 10 = 1990
movies_decade_calc = FOREACH movies_decade GENERATE 
    movie_id, 
    (year / 10) * 10 AS decade;

-- 3. Unir con valoraciones
joined_data = JOIN movies_decade_calc BY movie_id, ratings BY movie_id;

-- 4. Agrupar por década y calcular media
grp_decade = GROUP joined_data BY movies_decade_calc::decade;

avg_by_decade = FOREACH grp_decade GENERATE 
    group AS decade, 
    AVG(joined_data.ratings::rating) AS avg_score;

-- 5. Ordenar por década
result = ORDER avg_by_decade BY decade ASC;

-- 6. Guardar en formato CSV (coma)
fs -rm -r -f ratings_by_decade;
STORE result INTO 'ratings_by_decade' USING PigStorage(',');
