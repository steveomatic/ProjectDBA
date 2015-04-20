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
  
  
  PROCEDURE CREAR_USUARIOS(asignatura IN VARCHAR2, numero IN NUMBER) IS 
    var_counter number(6) ;
    n pls_integer;
    str varchar(4);
    BEGIN
       var_counter := 0;
       DBMS_OUTPUT.PUT_LINE('HOLA');
        FOR VAR_COUNTER IN 1..numero LOOP 
          n := SEQ_CREA_USUARIOS.NEXTVAL;
          str := DBMS_RANDOM.STRING('U', 4);
          --EXECUTE IMMEDIATE 'CREATE USER ' || asignatura || ''||n|| ' IDENTIFIED BY ' || asignatura||''||n;
          DBMS_OUTPUT.PUT_LINE('CREATE USER ' || ASIGNATURA || str || 'IDENTIFIED BY ' || ASIGNATURA || str);
          --SYS.DBMS_OUTPUT.PUT_LINE('Usuario '|| ' creado correctamente');
        END LOOP;
 END CREAR_USUARIOS;


END GEST_USUARIO;
