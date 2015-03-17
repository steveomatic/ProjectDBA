create tablespace TS_DOCENCIA
	datafile 'df_docencia.dat'
	size 16M
	AUTOEXTEND ON NEXT 1M ;

create table usuario(
  usuario_id number(5) primary key,
  usuario_name varchar2(100) not null

)
tablespace TS_DOCENCIA;

create table alumno(
  alumno_id number(5) primary key,
  nombre varchar2(100) not null,
  apellido1 varchar2(100) not null,
  apellido2 varchar2(100) ,
  dni varchar2(20) not null unique,
  expediente varchar2(30) not null,
  fecha_alta date,
  fecha_nacimiento date,
  user_id references usuario(usuario_id)
  )
  tablespace TS_DOCENCIA
  ;
  
create table profesor(
	profesor_id number(5) primary key,
	nombre varchar2(100) not null,
	apellido1 varchar2(100) not null,
	apellido2 varchar2(100),
	dni varchar2(20) not null unique
	)
	tablespace TS_DOCENCIA
;
	
  
 
 create table asignatura(
  asignatura_id number(5) primary key,
  code varchar2(40) not null unique,
  nombre varchar2(40) not null,
  cuatrimestre varchar2(10) not null,
  profesor_id references PROFESOR(profesor_id)
  )
  tablespace TS_DOCENCIA
  ;




create table ejercicio(
  ejercicio_id number(5) primary key,
  tema number,
  enunciado varchar2(1024) not null,
  solucion varchar2(1024) not null,
  fallos number
)tablespace TS_DOCENCIA;

  
create table RELACION (
  relacion_id number(5) primary key,
  tema number not null
  )
tablespace TS_DOCENCIA;
  
  
create table ASIG_RELACION(
  usuario_id references USUARIO(usuario_id),
  relacion_id references RELACION(relacion_id),
  constraint asig_PK primary key(usuario_id,relacion_id)
  )tablespace TS_DOCENCIA;
  
create table ASIG_EJER(
  relacion_id references RELACION(relacion_id),
  ejercicio_id references EJERCICIO(ejercicio_id),
  constraint ejer_PK primary key(relacion_id,ejercicio_id)
  )tablespace TS_DOCENCIA;

create table MATRICULA(
  alumno_id references ALUMNO(alumno_id),
  asignatura_id references ASIGNATURA(asignatura_id),
  grupo varchar2(1) not null,
  curso_academico varchar2(10) not null,
  constraint matricula_pk primary key(alumno_id,asignatura_id)
  )tablespace TS_DOCENCIA;
	

