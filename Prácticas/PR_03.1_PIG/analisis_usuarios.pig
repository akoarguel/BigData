/* Carga de datos */
usuarios = LOAD '/user/maria_dev/u.user' USING PigStorage('|') 
   AS (id:int, age:int, gender:chararray, occupation:chararray, zip:chararray);

/* 1. Total de hombres y mujeres */
grupos_genero = GROUP usuarios BY gender;
conteo_genero = FOREACH grupos_genero GENERATE group AS genero, COUNT(usuarios) AS total;
/* Guardamos en la carpeta 'genero' dentro de 'pig_usuarios' */
STORE conteo_genero INTO '/user/maria_dev/pig_usuarios/genero';

/* 2. Las 10 ocupaciones más frecuentes */
grupos_ocupacion = GROUP usuarios BY occupation;
conteo_ocupacion = FOREACH grupos_ocupacion GENERATE group AS ocupacion, COUNT(usuarios) AS total;
ocupaciones_ordenadas = ORDER conteo_ocupacion BY total DESC;
top_10_ocupaciones = LIMIT ocupaciones_ordenadas 10;
STORE top_10_ocupaciones INTO '/user/maria_dev/pig_usuarios/ocupaciones';

/* 3. Edad media por géneros */
edad_media_genero = FOREACH grupos_genero GENERATE group AS genero, AVG(usuarios.age) AS edad_promedio;
STORE edad_media_genero INTO '/user/maria_dev/pig_usuarios/edad_genero';

/* 4. Edad media por ocupaciones */
edad_media_ocupacion = FOREACH grupos_ocupacion GENERATE group AS ocupacion, AVG(usuarios.age) AS edad_promedio;
STORE edad_media_ocupacion INTO '/user/maria_dev/pig_usuarios/edad_ocupacion';
