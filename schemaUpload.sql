CREATE TABLE ALUMNO
  (
    alumno_id        NUMBER NOT NULL ,
    dni              VARCHAR2 (9) NOT NULL ,
    nombre           VARCHAR2 (200) NOT NULL ,
    apellido1        VARCHAR2 (200) NOT NULL ,
    apellido2        VARCHAR2 (200) ,
    expediente       VARCHAR2 (30) NOT NULL ,
    fecha_alta       DATE NOT NULL ,
    fecha_nacimiento DATE NOT NULL
  ) ;
ALTER TABLE ALUMNO ADD CONSTRAINT ALUMNO_PK PRIMARY KEY ( alumno_id ) ;
ALTER TABLE ALUMNO ADD CONSTRAINT ALUMNO__UN UNIQUE ( dni ) ;

CREATE TABLE ASIGNATURA
  (
    asignatura_id NUMBER NOT NULL ,
    codigo        VARCHAR2 (40) NOT NULL ,
    nombre        VARCHAR2 (40) NOT NULL ,
    cuatrimestre  VARCHAR2 (10) NOT NULL ,
    min_puntos    NUMBER NOT NULL ,
    max_puntos    NUMBER NOT NULL
  ) ;
ALTER TABLE ASIGNATURA ADD CONSTRAINT ASIGNATURA_PK PRIMARY KEY ( asignatura_id ) ;
ALTER TABLE ASIGNATURA ADD CONSTRAINT ASIGNATURA__UN UNIQUE ( codigo ) ;

CREATE TABLE CALIF_EJERCICIO
  (
    nota                   NUMBER ,
    USUARIO_usuario_id     NUMBER (5) NOT NULL ,
    RELACION_relacion_id   NUMBER NOT NULL ,
    EJERCICIO_ejercicio_id NUMBER NOT NULL ,
    asignatura_id          NUMBER NOT NULL
  ) ;
ALTER TABLE CALIF_EJERCICIO ADD CONSTRAINT CALIF_EJERCICIO_PK PRIMARY KEY ( USUARIO_usuario_id, RELACION_relacion_id, asignatura_id, EJERCICIO_ejercicio_id ) ;
ALTER TABLE CALIF_EJERCICIO ADD respuesta VARCHAR2 (1024);

CREATE TABLE EJERCICIO
  (
    ejercicio_id NUMBER NOT NULL ,
    tema         NUMBER ,
    enunciado    VARCHAR2 (1024) NOT NULL ,
    solucion     VARCHAR2 (1024) NOT NULL ,
    fallos       NUMBER ,
    retribucion  NUMBER NOT NULL
  ) ;
ALTER TABLE EJERCICIO ADD CONSTRAINT EJERCICIO_PK PRIMARY KEY ( ejercicio_id ) ;
ALTER TABLE EJERCICIO ADD palabras_clave VARCHAR2 (256);

CREATE TABLE MATRICULA
  (
    curso_academico          VARCHAR2 (5) NOT NULL ,
    grupo                    VARCHAR2 (1) NOT NULL ,
    ALUMNO_alumno_id         NUMBER NOT NULL ,
    ASIGNATURA_asignatura_id NUMBER NOT NULL ,
    USUARIO_usuario_id       NUMBER (5) NOT NULL
  ) ;
CREATE UNIQUE INDEX MATRICULA__IDX ON MATRICULA
  (
    USUARIO_usuario_id ASC
  )
  ;
  ALTER TABLE MATRICULA ADD CONSTRAINT MATRICULA_PK PRIMARY KEY ( ALUMNO_alumno_id, ASIGNATURA_asignatura_id, curso_academico ) ;

CREATE TABLE PROFESOR
  (
    profesor_id NUMBER NOT NULL ,
    dni         VARCHAR2 (20) NOT NULL ,
    nombre      VARCHAR2 (100) NOT NULL ,
    apellido1   VARCHAR2 (100) NOT NULL ,
    apellido2   VARCHAR2 (100)
  ) ;
ALTER TABLE PROFESOR ADD CONSTRAINT PROFESOR_PK PRIMARY KEY ( profesor_id ) ;
ALTER TABLE PROFESOR ADD CONSTRAINT PROFESOR__UN UNIQUE ( dni ) ;

CREATE TABLE RELACION
  (
    relacion_id              NUMBER NOT NULL ,
    tema                     NUMBER NOT NULL ,
    USUARIO_usuario_id       NUMBER (5) NOT NULL ,
    ASIGNATURA_asignatura_id NUMBER NOT NULL
  ) ;
ALTER TABLE RELACION ADD CONSTRAINT RELACION_PK PRIMARY KEY ( relacion_id, ASIGNATURA_asignatura_id ) ;

CREATE TABLE Relation_3
  (
    PROFESOR_profesor_id     NUMBER NOT NULL ,
    ASIGNATURA_asignatura_id NUMBER NOT NULL
  ) ;
ALTER TABLE Relation_3 ADD CONSTRAINT Relation_3_PK PRIMARY KEY ( PROFESOR_profesor_id, ASIGNATURA_asignatura_id ) ;

CREATE TABLE USUARIO
  (
    usuario_id NUMBER (5) NOT NULL ,
    nombre     VARCHAR2 (30) NOT NULL
  ) ;
ALTER TABLE USUARIO ADD CONSTRAINT USUARIO_PK PRIMARY KEY ( usuario_id ) ;

ALTER TABLE USUARIO ADD UNIQUE(nombre);

ALTER TABLE CALIF_EJERCICIO ADD CONSTRAINT CALIF_EJERCICIO_EJERCICIO_FK FOREIGN KEY ( EJERCICIO_ejercicio_id ) REFERENCES EJERCICIO ( ejercicio_id ) ;

ALTER TABLE CALIF_EJERCICIO ADD CONSTRAINT CALIF_EJERCICIO_RELACION_FK FOREIGN KEY ( RELACION_relacion_id, asignatura_id ) REFERENCES RELACION ( relacion_id, ASIGNATURA_asignatura_id ) ;

ALTER TABLE CALIF_EJERCICIO ADD CONSTRAINT CALIF_EJERCICIO_USUARIO_FK FOREIGN KEY ( USUARIO_usuario_id ) REFERENCES USUARIO ( usuario_id ) ;

ALTER TABLE Relation_3 ADD CONSTRAINT FK_ASS_4 FOREIGN KEY ( PROFESOR_profesor_id ) REFERENCES PROFESOR ( profesor_id ) ;

ALTER TABLE Relation_3 ADD CONSTRAINT FK_ASS_5 FOREIGN KEY ( ASIGNATURA_asignatura_id ) REFERENCES ASIGNATURA ( asignatura_id ) ;

ALTER TABLE MATRICULA ADD CONSTRAINT MATRICULA_ALUMNO_FK FOREIGN KEY ( ALUMNO_alumno_id ) REFERENCES ALUMNO ( alumno_id ) ;

ALTER TABLE MATRICULA ADD CONSTRAINT MATRICULA_ASIGNATURA_FK FOREIGN KEY ( ASIGNATURA_asignatura_id ) REFERENCES ASIGNATURA ( asignatura_id ) ;

ALTER TABLE MATRICULA ADD CONSTRAINT MATRICULA_USUARIO_FK FOREIGN KEY ( USUARIO_usuario_id ) REFERENCES USUARIO ( usuario_id ) ;

ALTER TABLE RELACION ADD CONSTRAINT RELACION_ASIGNATURA_FK FOREIGN KEY ( ASIGNATURA_asignatura_id ) REFERENCES ASIGNATURA ( asignatura_id ) ;

ALTER TABLE RELACION ADD CONSTRAINT RELACION_USUARIO_FK FOREIGN KEY ( USUARIO_usuario_id ) REFERENCES USUARIO ( usuario_id ) ;

  ALTER TABLE RELACION
DROP CONSTRAINT RELACION_USUARIO_FK;

alter table RELACION
ADD CONSTRAINT RELACION_USUARIO_FK
FOREIGN KEY (USUARIO_usuario_id)
REFERENCES USUARIO(usuario_id)
ON DELETE CASCADE;


  ALTER TABLE calif_ejercicio
DROP CONSTRAINT CALIF_EJERCICIO_USUARIO_FK;


-- on delete cascade nos mantiene consistente la base de datos
alter table calif_ejercicio
ADD CONSTRAINT CALIF_EJERCICIO_USUARIO_FK
FOREIGN KEY (USUARIO_usuario_id)
REFERENCES USUARIO(usuario_id)
ON DELETE CASCADE;



--5. Leer los puntos obtenidos por todos los alumnos. Realmente se debe poder leer los puntos totales obtenidos,
--el nombre de la asignatura, el curso y todos los datos del alumno, por lo que habrá que crear una vista.
--Modificar el parámetro N mencionado en el enunciado, los puntos mínimos para superar la asignatura y los puntos máximos
--(a partir de los cuales ya no se pueden pedir más relaciones). También podrá modificar el número de ejercicios de que consta una relación.

-- Creo una vista auxiliar que me da las notas de las relaciones de todos los alumnos, pero no me da los datos de estos.
CREATE OR REPLACE VIEW Notas_alumnos_sin_datos AS
SELECT asignatura_id, relacion_relacion_id, SUM(NOTA) AS nota, usuario_usuario_id
FROM calif_ejercicio
GROUP BY asignatura_id, relacion_relacion_id, usuario_usuario_id;

CREATE OR REPLACE VIEW notas_alumnos AS
SELECT asignatura.nombre as Asignatura, relacion_relacion_id AS Relacion, NOTA, alumno.nombre || ' ' || alumno.apellido1 || ' ' ||
alumno.apellido2 AS Nombre, alumno.dni, curso_academico, grupo, expediente, alumno.fecha_alta AS "Fecha de alta",
alumno.fecha_nacimiento AS "Fecha de nacimiento"
FROM Notas_alumnos_sin_datos, usuario, matricula, alumno, asignatura
WHERE Notas_alumnos_sin_datos.usuario_usuario_id = usuario.usuario_id
AND asignatura.asignatura_id=notas_alumnos_sin_datos.asignatura_id
AND matricula.usuario_usuario_id = usuario.usuario_id
AND matricula.alumno_alumno_id = alumno.alumno_id;





--Ejercicio 8
--2. Crear los mecanismos necesarios (evalúe las diferentes posibilidades) para que cada alumno sólo pueda ver sus propios datos.
CREATE OR REPLACE VIEW Mis_Datos AS
SELECT alumno.nombre || ' ' || alumno.apellido1 || ' ' ||
alumno.apellido2 AS Nombre, alumno.dni, curso_academico AS "Curso Académico", grupo, expediente, alumno.fecha_alta AS "Fecha de alta",
alumno.fecha_nacimiento AS "Fecha de nacimiento"
FROM usuario, matricula, alumno
WHERE matricula.usuario_usuario_id = usuario.usuario_id
AND matricula.alumno_alumno_id = alumno.alumno_id
AND UPPER(usuario.nombre) = UPPER(user);



--3. Dar los permisos necesarios para que un alumno pueda ver los puntos que ha obtenido en cada ejercicio de cada relación
CREATE OR REPLACE VIEW Mis_notas_de_ejercicios AS
SELECT nota as Nota, relacion_relacion_id AS Relación, ejercicio_ejercicio_id AS Ejercicio
FROM calif_ejercicio, usuario
WHERE UPPER(usuario.nombre) = UPPER(user)
AND usuario_id=usuario_usuario_id;


--4. Dar los permisos necesarios para que un alumno pueda ver los puntos totales que ha obtenido en cada relación
CREATE OR REPLACE VIEW Mis_Notas AS 
SELECT asignatura.nombre AS Asignatura,  relacion_relacion_id AS Relación, nota
FROM notas_alumnos_sin_datos, usuario, asignatura
WHERE notas_alumnos_sin_datos.usuario_usuario_id = usuario.usuario_id
AND notas_alumnos_sin_datos.asignatura_id = asignatura.asignatura_id
AND UPPER(usuario.nombre) = UPPER(user);

------------------------------
--5. Dar los permisos necesarios para que un alumno pueda ver los puntos totales que lleva acumulados y los que le faltan para
--llegar al mínimo de la asignatura y al máximo.

--auxiliar
Create OR REPLACE view Mis_notas_total_por_asignatura AS
select asignatura, SUM(nota) AS nota from mis_notas
GROUP BY asignatura;


--Solución
CREATE OR REPLACE VIEW Mis_puntos_restantes AS
select asignatura, asignatura.min_puntos - mis_notas_total_por_asignatura.nota
AS "Puntos restantes para aprobar", asignatura.max_puntos-nota
AS "Puntos restantes para 10"
from asignatura, Mis_notas_total_por_asignatura
where nombre=asignatura;

--6. Dar los permisos necesarios para que un alumno pueda ver los N alumnos que más puntos llevan acumulados. 
--Para ello se creará un procedimiento que creará una tabla temporal con esos datos.

--RESUELTO EN MEJORES_ALUMNOS.SQL CON EL PROCEDURE N_MEJORES_ASIGNATURA

----------------------------------------------
CREATE BITMAP INDEX grupo_idx ON matricula(grupo) ;
CREATE BITMAP INDEX matricula_asignatura_idx ON matricula(asignatura_asignatura_id) ;
CREATE INDEX apellido_mayus_idx ON alumno(UPPER(apellido1)) ;


--al meter datos dummy,no usados en la realidad de la aplicacion hemos de comenzar por el 10 para evitar colisiones
create sequence asignatura_seq start with 10 increment by 1;
create sequence alumno_seq start with 10 increment by 1;
create sequence ejercicio_seq start with 10 increment by 1;
create sequence profesor_seq start with 10 increment by 1;
create sequence relacion_seq start with 10 increment by 1;
create sequence usuario_seq start with 10 increment by 1;



ALTER TABLE matricula
DROP CONSTRAINT MATRICULA_USUARIO_FK;

alter table matricula
ADD CONSTRAINT MATRICULA_USUARIO_FK
FOREIGN KEY (USUARIO_USUARIO_ID)
REFERENCES USUARIO(usuario_id)
ON DELETE CASCADE;



--tiempo minimo va en minutos
alter table relacion add tiempo_minimo number;

CREATE TABLE audit_ejer
  (
  usuario_id  NUMBER NOT NULL,
  ejercicio_id NUMBER NOT NULL,
  relacion_id NUMBER NOT NULL,
  asignatura_id NUMBER NOT NULL,
  fecha_inicio timestamp NOT NULL,
  fecha_entrega_ultima timestamp,
  fecha_entrega_correcto timestamp
  );
  ALTER TABLE audit_ejer ADD CONSTRAINT USUARIO_UNIQUE UNIQUE (usuario_id, ejercicio_id, relacion_id, asignatura_id);





-- Vista auxiliar
CREATE OR REPLACE VIEW Notas_alu_tema_sin_datos AS
SELECT c.asignatura_id, r.tema, c.relacion_relacion_id, c.NOTA, c.usuario_usuario_id
FROM calif_ejercicio c , relacion r
WHERE c.relacion_relacion_id = r.relacion_id;

-- Vista auxiliar
CREATE OR REPLACE VIEW notas_alu_por_tema AS
SELECT asignatura_id, tema, SUM(nota) AS NOTA, usuario_usuario_id AS usuario FROM Notas_alu_tema_sin_datos
GROUP BY tema, asignatura_id, usuario_usuario_id;

-- Vista auxiliar
CREATE OR REPLACE VIEW notas_alu_por_tema_datos AS
SELECT asignatura.nombre as Asignatura, tema, NOTA, alumno.nombre || ' ' || alumno.apellido1 || ' ' ||
alumno.apellido2 AS Nombre, alumno.dni, curso_academico, grupo, expediente, alumno.fecha_alta AS "Fecha de alta",
alumno.fecha_nacimiento AS "Fecha de nacimiento"
FROM notas_alu_por_tema, usuario, matricula, alumno, asignatura
WHERE notas_alu_por_tema.usuario = usuario.usuario_id
AND matricula.usuario_usuario_id = usuario.usuario_id
AND matricula.alumno_alumno_id = alumno.alumno_id
AND asignatura.asignatura_id=notas_alu_por_tema.asignatura_id;



-- Esta vista me da la mediana de las notas en cada tema todos los estudiantes
CREATE OR REPLACE VIEW mediana_alu_tema AS
select nombre, asignatura, median(nota) AS mediana from notas_alu_por_tema_datos
group by nombre, asignatura;
-- He usado la mediana porque puede darse el caso de que un estudiante siempre saque 10 y un tema le pasara algo y la hiciese mal.
-- No sería justo penalizarle tanto como lo haría la media.

-- Esta vista me ordena por orden descendiente la mediana de las notas en cada tema todos los estudiantes
CREATE OR REPLACE VIEW Mejores_alu_tema AS
select * from mediana_alu_tema
ORDER BY mediana desc;


CREATE OR REPLACE VIEW notas_alumnos_para_procedure AS
SELECT asignatura.asignatura_id as AsignaturaID, asignatura.nombre as Asignatura, relacion_relacion_id AS Relacion, NOTA,alumno.alumno_id as alumnoID, alumno.nombre || ' ' || alumno.apellido1 || ' ' ||
alumno.apellido2 AS Nombre, alumno.dni, curso_academico, grupo, expediente, alumno.fecha_alta AS "Fecha de alta",
alumno.fecha_nacimiento AS "Fecha de nacimiento"
FROM Notas_alumnos_sin_datos, usuario, matricula, alumno, asignatura
WHERE Notas_alumnos_sin_datos.usuario_usuario_id = usuario.usuario_id
AND matricula.usuario_usuario_id = usuario.usuario_id
AND matricula.alumno_alumno_id = alumno.alumno_id
AND notas_alumnos_sin_datos.asignatura_id = asignatura.asignatura_id;


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



