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