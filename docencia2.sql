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
    nombre     VARCHAR2 (10) NOT NULL
  ) ;
ALTER TABLE USUARIO ADD CONSTRAINT USUARIO_PK PRIMARY KEY ( usuario_id ) ;

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


GRANT INSERT, DELETE, ALTER on DOCENCIA.ALUMNO TO R_ADMINISTRATIVO;
GRANT INSERT, DELETE, ALTER on DOCENCIA.ASIGNATURA TO R_ADMINISTRATIVO;
GRANT INSERT, DELETE, ALTER on DOCENCIA.MATRICULA TO R_ADMINISTRATIVO;


--5. Leer los puntos obtenidos por todos los alumnos. Realmente se debe poder leer los puntos totales obtenidos,
--el nombre de la asignatura, el curso y todos los datos del alumno, por lo que habrá que crear una vista.
--Modificar el parámetro N mencionado en el enunciado, los puntos mínimos para superar la asignatura y los puntos máximos
--(a partir de los cuales ya no se pueden pedir más relaciones). También podrá modificar el número de ejercicios de que consta una relación.

-- Creo una vista auxiliar que me da las notas de las relaciones de todos los alumnos, pero no me da los datos de estos.
CREATE VIEW Notas_alumnos_sin_datos AS 
SELECT SUM(NOTA) AS nota, relacion_relacion_id, usuario_usuario_id
FROM calif_ejercicio 
GROUP BY relacion_relacion_id, usuario_usuario_id;

CREATE VIEW notas_alumnos AS
SELECT asignatura.nombre as Asignatura, NOTA, relacion_relacion_id AS Relacion, alumno.nombre || ' ' ||  alumno.apellido1 || ' ' || 
alumno.apellido2 AS Nombre, alumno.dni, curso_academico, grupo, expediente, alumno.fecha_alta AS "Fecha de alta",
alumno.fecha_nacimiento AS "Fecha de nacimiento"
FROM notas_alumnos_sin_datos, usuario, matricula, alumno, asignatura
WHERE notas_alumnos_sin_datos.usuario_usuario_id = usuario.usuario_id 
AND matricula.usuario_usuario_id = usuario.usuario_id
AND matricula.alumno_alumno_id = alumno.alumno_id
AND matricula.asignatura_asignatura_id = asignatura_id;

GRANT SELECT ON notas_alumnos TO r_administrativo;


--Ejercicio 7
--Conectarse como administrador. Dar permisos al R_PROFESOR para:
--1. Conectarse en practica2.sql

--2. Añadir ejercicios al banco de preguntas (leer, insertar, modificar o borrar)
GRANT delete, insert, update, select ON ejercicio TO r_profesor;
--3. Ver los datos de todos los alumnos, incluyendo los puntos obtenidos
GRANT select ON alumno TO r_profesor;
--4. Modificar los puntos que un alumno obtiene en la solución de un ejercicio
GRANT select, update ON calif_ejercicio TO r_profesor;

--Ejercicio 8
--2. Crear los mecanismos necesarios (evalúe las diferentes posibilidades) para que cada alumno sólo pueda ver sus propios datos.
CREATE VIEW Mis_Datos AS
SELECT alumno.nombre || ' ' || alumno.apellido1 || ' ' ||
alumno.apellido2 AS Nombre, alumno.dni, curso_academico AS "Curso Académico", grupo, expediente, alumno.fecha_alta AS "Fecha de alta",
alumno.fecha_nacimiento AS "Fecha de nacimiento"
FROM usuario, matricula, alumno
WHERE matricula.usuario_usuario_id = usuario.usuario_id
AND matricula.alumno_alumno_id = alumno.alumno_id
AND UPPER(usuario.nombre) = UPPER(user);

GRANT select ON Mis_Datos TO R_ALUMNO;


CREATE OR REPLACE VIEW Mis_Notas AS 
SELECT nota, relacion_relacion_id AS Relación
FROM notas_alumnos_sin_datos, usuario
WHERE notas_alumnos_sin_datos.usuario_usuario_id = usuario.usuario_id
AND UPPER(usuario.nombre) = UPPER(user);

GRANT select ON Mis_Notas TO R_ALUMNO;

CREATE OR REPLACE VIEW Mis_notas_de_ejercicios AS
SELECT nota as Nota, relacion_relacion_id AS Relación, ejercicio_ejercicio_id AS Ejercicio
FROM calif_ejercicio, usuario
WHERE UPPER(usuario.nombre) = UPPER(user);

GRANT SELECT ON Mis_notas_de_ejercicios TO R_ALUMNO;
------------------------------
--5
--auxiliar
CREATE VIEW Mis_notas_por_asignatura AS
SELECT Nombre as Asignatura, nota, mis_notas."RELACIÓN"
from mis_notas, relacion, asignatura
WHERE mis_notas.relación = relacion.relacion_id
AND relacion.ASIGNATURA_ASIGNATURA_ID = asignatura.asignatura_id;

GRANT SELECT ON Mis_notas_por_asignatura TO r_alumno;

--auxiliar
create view Mis_notas_total_por_asignatura AS
select asignatura, SUM(nota) AS nota from mis_notas_por_asignatura
GROUP BY asignatura;
GRANT SELECT ON Mis_notas_total_por_asignatura TO R_alumno;

--Solución
CREATE VIEW Mis_puntos_restantes AS
select asignatura, asignatura.min_puntos - mis_notas_total_por_asignatura.nota
AS "Puntos restantes para aprobar", asignatura.max_puntos-nota
AS "Puntos restantes para 10"
from asignatuRa, Mis_notas_total_por_asignatura 
;
GRANT SELECT ON Mis_puntos_restantes TO R_alumno;

----------------------------------------------
CREATE BITMAP INDEX grupo_idx ON matricula(grupo) tablespace ts_index;
CREATE BITMAP INDEX matricula_asignatura_idx ON matricula(asignatura_asignatura_id) tablespace ts_index;
CREATE INDEX apellido_mayus_idx ON alumno(UPPER(apellido1)) tablespace ts_index;


INSERT INTO usuario VALUES(1,'Godel');
INSERT INTO asignatura VALUES(1, 'ABD', 'Admin. Base de datos', '2cuat',50,100);
INSERT INTO alumno VALUES (1, '12345678A', 'Haritz', 'Puerto', 'San Román', '0001', SYSDATE, TO_DATE('1994/10/26', 'yyyy/mm/dd'));
INSERT INTO matricula VALUES('14/15', 'A', 1, 1, 1);
INSERT INTO ejercicio VALUES(1, 1, 'Muestra sysdate', 'SELECT sysdate FROM dual;', 0, 1);
INSERT into relacion VALUES (1,1,1,1);
INSERT INTO calif_ejercicio VALUES(1,1,1,1,1);
INSERT INTO ejercicio VALUES(2,1,'bla bla', 'sol', 0,1);
INSERT INTO ejercicio VALUES(3,1,'bla bla', 'sol', 0,1);
INSERT INTO ejercicio VALUES(4,1,'bla bla', 'sol', 0,1);
INSERT INTO ejercicio VALUES(5,1,'bla bla', 'sol', 0,1);
INSERT INTO calif_ejercicio VALUES(1,1,1,2,1);
INSERT INTO calif_ejercicio VALUES(1,1,1,3,1);
INSERT INTO calif_ejercicio VALUES(0,1,1,4,1);
INSERT INTO calif_ejercicio VALUES(0,1,1,5,1);

INSERT INTO ejercicio VALUES(6,1,'bla bla', 'sol', 0,1);
INSERT INTO ejercicio VALUES(7,1,'bla bla', 'sol', 0,1);
INSERT INTO ejercicio VALUES(8,1,'bla bla', 'sol', 0,1);
INSERT INTO ejercicio VALUES(9,1,'bla bla', 'sol', 0,1);
INSERT into relacion VALUES (2,2,1,1);
INSERT INTO calif_ejercicio VALUES(1,1,2,6,1);
INSERT INTO calif_ejercicio VALUES(1,1,2,7,1);
INSERT INTO calif_ejercicio VALUES(0,1,2,8,1);
INSERT INTO calif_ejercicio VALUES(0,1,2,9,1);
