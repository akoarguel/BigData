/* PR_03.1 - Apartado C: WordCount El Quijote */

-- 1. Carga del texto (leemos linea a linea)
lineas = LOAD '/user/maria_dev/quijote.txt' USING TextLoader() AS (linea:chararray);

-- 2. Aplanar y Tokenizar (Romper las frases en palabras sueltas)
-- TOKENIZE divide por espacios/puntuación. FLATTEN convierte la lista de palabras en filas.
palabras = FOREACH lineas GENERATE FLATTEN(TOKENIZE(linea)) AS palabra;

-- 3. Agrupar por palabra
grupos_palabras = GROUP palabras BY palabra;

-- 4. Contar ocurrencias
conteo = FOREACH grupos_palabras GENERATE group AS palabra, COUNT(palabras) AS cantidad;

-- 5. Ordenar por frecuencia (opcional, para verlo mejor)
conteo_ordenado = ORDER conteo BY cantidad DESC;

-- 6. Mostrar un ejemplo por pantalla (Top 20)
top_palabras = LIMIT conteo_ordenado 20;
DUMP top_palabras;

-- 7. Almacenar el resultado completo en HDFS
-- Limpiamos carpeta previa para evitar errores si re-ejecutas
fs -rm -r -f pig_quijote;

STORE conteo_ordenado INTO 'pig_quijote' USING PigStorage('\t');
