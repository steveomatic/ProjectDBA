-- Esta vista me da la mediana de las notas en cada relación todos los estudiantes
CREATE VIEW mediana_alu_relacion AS
select nombre, asignatura, median(nota) AS mediana from notas_alumnos
group by nombre, asignatura;
-- He usado la mediana porque puede darse el caso de que un estudiante siempre saque 10 y una relación le pasara algo y la hiciese mal.
-- No sería justo penalizarle tanto como lo haría la media.
-- Esta vista me ordena por orden ascendiente la mediana de las notas en cada relación todos los estudiantes
CREATE VIEW Mejores_alu_relacion AS
select * from mediana_alu_relacion
ORDER BY mediana asc;

GRANT SELECT ON Mejores_alu_relacion TO R_PROFESOR;
--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------

-- Vista auxiliar
CREATE VIEW Notas_alu_tema_sin_datos AS
SELECT c.asignatura_id, r.tema, c.relacion_relacion_id, c.NOTA, c.usuario_usuario_id
FROM calif_ejercicio c , relacion r
WHERE c.relacion_relacion_id = c.relacion_relacion_id;

-- Vista auxiliar
CREATE VIEW notas_alu_por_tema AS
SELECT asignatura_id, tema, SUM(nota) AS NOTA, usuario_usuario_id AS usuario FROM Notas_alu_tema_sin_datos
GROUP BY tema, asignatura_id, usuario_usuario_id;

-- Vista auxiliar
CREATE VIEW notas_alu_por_tema_datos AS
SELECT asignatura.nombre as Asignatura, tema, NOTA, alumno.nombre || ' ' || alumno.apellido1 || ' ' ||
alumno.apellido2 AS Nombre, alumno.dni, curso_academico, grupo, expediente, alumno.fecha_alta AS "Fecha de alta",
alumno.fecha_nacimiento AS "Fecha de nacimiento"
FROM notas_alu_por_tema, usuario, matricula, alumno, asignatura
WHERE notas_alu_por_tema.usuario = usuario.usuario_id
AND matricula.usuario_usuario_id = usuario.usuario_id
AND matricula.alumno_alumno_id = alumno.alumno_id;



-- Esta vista me da la mediana de las notas en cada relación todos los estudiantes
CREATE VIEW mediana_alu_tema AS
select nombre, asignatura, median(nota) AS mediana from notas_alu_por_tema_datos
group by nombre, asignatura;
-- He usado la mediana porque puede darse el caso de que un estudiante siempre saque 10 y una relación le pasara algo y la hiciese mal.
-- No sería justo penalizarle tanto como lo haría la media.
-- Esta vista me ordena por orden ascendiente la mediana de las notas en cada relación todos los estudiantes

CREATE VIEW Mejores_alu_tema AS
select * from mediana_alu_tema
ORDER BY mediana asc;

GRANT SELECT ON Mejores_alu_tema TO R_PROFESOR;


CREATE OR REPLACE VIEW notas_alumnos_para_procedure AS
SELECT asignatura.asignatura_id as AsignaturaID, asignatura.nombre as Asignatura, relacion_relacion_id AS Relacion, NOTA,alumno.alumno_id as alumnoID, alumno.nombre || ' ' || alumno.apellido1 || ' ' ||
alumno.apellido2 AS Nombre, alumno.dni, curso_academico, grupo, expediente, alumno.fecha_alta AS "Fecha de alta",
alumno.fecha_nacimiento AS "Fecha de nacimiento"
FROM Notas_alumnos_sin_datos, usuario, matricula, alumno, asignatura
WHERE Notas_alumnos_sin_datos.usuario_usuario_id = usuario.usuario_id
AND matricula.usuario_usuario_id = usuario.usuario_id
AND matricula.alumno_alumno_id = alumno.alumno_id;

