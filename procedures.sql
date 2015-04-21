create or replace 
PACKAGE BODY GEST_USUARIO AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 
  PROCEDURE CREAR_USUARIO(usuario IN VARCHAR2, pass IN VARCHAR2) IS 
  BEGIN
    EXECUTE IMMEDIATE 'CREATE USER ' || usuario || ' IDENTIFIED BY ' || pass;
    SYS.dbms_output.put_line('Usuario ' || usuario || ' creado correctamente');
  END CREAR_USUARIO;

  PROCEDURE BORRAR_USUARIO(usuario IN VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE 'DROP USER ' || usuario || ' CASCADE';
    SYS.dbms_output.put_line('Usuario ' || usuario || ' borrado correctamente');
  END BORRAR_USUARIO;
  
  PROCEDURE BLOQUEAR_USUARIO(usuario IN VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE 'ALTER USER ' || usuario || ' ACCOUNT LOCK';
    SYS.dbms_output.put_line('Usuario ' || usuario || ' bloqueado correctamente');
  END BLOQUEAR_USUARIO;
  
  PROCEDURE DESBLOQUEAR_USUARIO(usuario IN VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE 'ALTER USER ' || usuario || ' ACCOUNT LOCK';
    SYS.dbms_output.put_line('Usuario ' || usuario || ' bloqueado correctamente');
  END DESBLOQUEAR_USUARIO;
  
  
  PROCEDURE MATAR_SESION (usuario IN VARCHAR2) IS
  --EXCESIVAMENTE IMPORTANTE: Para poder compilar esto el usuario tiene que tener grant expreso por parte de sysdba
  VAR_SID v$session.sid%TYPE;
  VAR_SERIAL# v$session.serial#%TYPE;
  
  BEGIN
    select sid into VAR_SID from v$session where username = usuario;
    select serial# into VAR_SERIAL# from v$session where username = usuario;
    EXECUTE IMMEDIATE '''alter system kill session '||VAR_SID||','||VAR_SERIAL#||''';
    DBMS_OUTPUT.put_line('''alter system kill session '||VAR_SID||','||VAR_SERIAL#||''');
    
  END MATAR_SESION;
  
  
--PRECONDICION: HA DE ESTAR CREADA LA SECUENCIA SEQ_CREA_USUARIOS
--create sequence SEQ_CREA_USUARIOS start with 1 increment by 1;
PROCEDURE CREAR_USUARIOS(asignatura IN VARCHAR2, numero IN NUMBER) IS 
    var_counter number(6) ;
    n pls_integer;
    str varchar(5);
  BEGIN
    var_counter := 0;
    FOR VAR_COUNTER IN 1..numero LOOP 
    n := SEQ_CREA_USUARIOS.NEXTVAL;
    str := DBMS_RANDOM.STRING('U', 5);
    EXECUTE IMMEDIATE 'CREATE USER ' || ASIGNATURA || str || n || ' IDENTIFIED BY ' || ASIGNATURA || str || n;
    --DBMS_OUTPUT.PUT_LINE('CREATE USER ' || ASIGNATURA || str || n || ' IDENTIFIED BY ' || ASIGNATURA || str || n);
    SYS.DBMS_OUTPUT.PUT_LINE('Usuario '|| ASIGNATURA || str || n || ' creado correctamente');
    END LOOP;
 END CREAR_USUARIOS;


END GEST_USUARIO;
