insert into alumno(alumno_id,dni,nombre,apellido1,apellido2,expediente,fecha_alta,fecha_nacimiento) values(1,'999999X','Robert','Liam','Curtis','00001',sysdate,sysdate-20);
insert into alumno(alumno_id,dni,nombre,apellido1,apellido2,expediente,fecha_alta,fecha_nacimiento) values(2,'787643X','Luke','Sky','Walker','00012',sysdate,sysdate-21);
insert into alumno(alumno_id,dni,nombre,apellido1,apellido2,expediente,fecha_alta,fecha_nacimiento) values(3,'123445X','Jack','Kerouac',NULL,'00013',sysdate,sysdate-60);

INSERT INTO asignatura(asignatura_id,codigo,nombre,cuatrimestre,min_puntos,max_puntos) VALUES(1, 'BD', 'Bases de Datos I', '2cuat',50,100);
INSERT INTO asignatura(asignatura_id,codigo,nombre,cuatrimestre,min_puntos,max_puntos) VALUES(2, 'BD2', 'Bases de Datos 2', '1cuat',50,100);



insert into usuario(usuario_id,nombre) values(1,'user_dummy1');
insert into usuario(usuario_id,nombre) values(2,'user_dummy2');
insert into usuario(usuario_id,nombre) values(3,'user_dummy3');



INSERT INTO matricula(curso_academico,grupo,alumno_alumno_id,asignatura_asignatura_id,usuario_usuario_id) VALUES('14/15', 'A', 1, 1, 1);
INSERT INTO matricula(curso_academico,grupo,alumno_alumno_id,asignatura_asignatura_id,usuario_usuario_id) VALUES('14/15', 'B', 2, 1, 2);
INSERT INTO matricula(curso_academico,grupo,alumno_alumno_id,asignatura_asignatura_id,usuario_usuario_id) VALUES('14/15', 'A', 3, 2, 3);




--Tablas donde los estudiantes ejecutaran sus querys en examenes o practica
create table continent(
continent_id number(5) primary key,
continent_name varchar2(100) not null unique
);
create table countries(
country_id number(5) primary key,
country_name varchar2(100) not null unique,
continent references continent(continent_id)
);


create table company(
company_id number(5) primary key,
company_name varchar2(100) not null,
country_id references countries(country_id)
);
insert into continent values(1,'Africa');
insert into continent values(2,'Europe');
insert into continent values(3,'America');

insert into countries values(1,'USA',3);
insert into countries values(2,'France',2);
insert into countries values(3,'UK',2);
insert into countries values (4,'Ghana',1);
insert into countries values (5,'Switzerland',2);
insert into countries values (6,'Canada',3);

insert into company values(1,'IBM',1);
insert into company values(2,'Roche',5);
insert into company values(3,'Carrefour',2);
insert into company values(4,'Raytheon',1);
insert into company values(5,'THIS_IS_INVENTED',4);
insert into company values(6,'Airbus',2);


grant select on continent to R_ALUMNO;
grant select on countries to R_ALUMNO;
grant select on company to R_ALUMNO;

INSERT INTO ejercicio(ejercicio_id,tema,enunciado,solucion,fallos,retribucion,palabras_clave) VALUES(1, 1, 'Muestra sysdate', 'SELECT sysdate FROM dual', 0, 1,'sysdate, dual');
insert into ejercicio(ejercicio_id,tema,enunciado,solucion,fallos,retribucion,palabras_clave) values(2,2,'Selecciona todos los continentes','Select * from continent', 0,1,'continent, easy');



insert into ejercicio(ejercicio_id,tema,enunciado,solucion,fallos,retribucion,palabras_clave) values(3,2,'Selecciona todos los paises en america','select * from countries
where continent in(select continent_id from continent where continent_name = ''America'')', 0,1,'countries, hard');

insert into ejercicio(ejercicio_id,tema,enunciado,solucion,fallos,retribucion,palabras_clave) values(4,2,'Selecciona todos los paises que empiecen por S','select * from countries
where country_name like ''S%''', 0,1,'wildcard, hard');


insert into relacion(relacion_id,tema,usuario_usuario_id,asignatura_asignatura_id,tiempo_minimo) values(4,1,1,1,5);
insert into relacion(relacion_id,tema,usuario_usuario_id,asignatura_asignatura_id,tiempo_minimo) values(5,2,2,1,7);
insert into relacion(relacion_id,tema,usuario_usuario_id,asignatura_asignatura_id,tiempo_minimo) values(6,2,3,2,3);

--cada usuario ahora tiene una relacion, ahora asignamos los ejercicios con calif_ejercicio


--cuando el usuario responda, se actualizara a otra cosa que null y 
--cuando acabe el tiempo, el profesor ejecutara 
--el procedimiento de correccion

INSERT INTO calif_ejercicio(nota,usuario_usuario_id,relacion_relacion_id,ejercicio_ejercicio_id,asignatura_id,respuesta) 
VALUES(0,1,4,1,1,'select sysdate from dual');

INSERT INTO calif_ejercicio(nota,usuario_usuario_id,relacion_relacion_id,ejercicio_ejercicio_id,asignatura_id,respuesta) 
VALUES(0,2,5,2,1,'select * from continent');

INSERT INTO calif_ejercicio(nota,usuario_usuario_id,relacion_relacion_id,ejercicio_ejercicio_id,asignatura_id,respuesta) 
VALUES(0,2,5,3,1,NULL);

INSERT INTO calif_ejercicio(nota,usuario_usuario_id,relacion_relacion_id,ejercicio_ejercicio_id,asignatura_id,respuesta) 
VALUES(0,3,6,3,2,'selec * from dual');

INSERT INTO calif_ejercicio(nota,usuario_usuario_id,relacion_relacion_id,ejercicio_ejercicio_id,asignatura_id,respuesta) 
VALUES(0,3,6,4,2,'select * from countries
where country_name like ''S%''');