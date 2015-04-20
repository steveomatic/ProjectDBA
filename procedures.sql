create or replace 
PACKAGE BODY GEST_USUARIO AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 
  PROCEDURE CREAR_USUARIO(usuario IN VARCHAR2, pass IN VARCHAR2) IS 
  BEGIN
    EXECUTE IMMEDIATE 'CREATE USER ' || usuario || ' IDENTIFIED BY ' || pass;
    SYS.dbms_output.put_line('Usuario ' || usuario || ' creado correctamente');
    EXCEPTION
    WHEN OTHERS THEN 
    IF SQLCODE = -1031
    then
    DBMS_OUTPUT.put_line('Error, no se tenian privilegios suficientes');
  
    ROLLBACK;
    ELSE
    dbms_output.put_line('Error desconocido');
    ROLLBACK;
    END IF;
  END CREAR_USUARIO;
 
  PROCEDURE BORRAR_USUARIO(usuario IN VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE 'DROP USER ' || usuario || ' CASCADE';
    SYS.dbms_output.put_line('Usuario ' || usuario || ' borrado correctamente');
    EXCEPTION
    WHEN OTHERS THEN 
     IF SQLCODE = -1031
    then
    DBMS_OUTPUT.put_line('Error, no se tenian privilegios suficientes');
  
    ROLLBACK;
    ELSE
    dbms_output.put_line('Error desconocido');
    ROLLBACK;
    END IF;
  END BORRAR_USUARIO;
  
  PROCEDURE BLOQUEAR_USUARIO(usuario IN VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE 'ALTER USER ' || usuario || ' ACCOUNT LOCK';
    SYS.dbms_output.put_line('Usuario ' || usuario || ' bloqueado correctamente');
    EXCEPTION
    WHEN OTHERS THEN 
    IF SQLCODE = -1031
    then
    DBMS_OUTPUT.put_line('Error, no se tenian privilegios suficientes');
  
    ROLLBACK;
    ELSE
    dbms_output.put_line('Error desconocido');
    ROLLBACK;
    END IF;
  END BLOQUEAR_USUARIO;
  
  PROCEDURE DESBLOQUEAR_USUARIO(usuario IN VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE 'ALTER USER ' || usuario || ' ACCOUNT LOCK';
    SYS.dbms_output.put_line('Usuario ' || usuario || ' bloqueado correctamente');
    EXCEPTION
    WHEN OTHERS THEN 
     IF SQLCODE = -1031
    then
    DBMS_OUTPUT.put_line('Error, no se tenian privilegios suficientes');
  
    ROLLBACK;
    ELSE
    dbms_output.put_line('Error desconocido');
    ROLLBACK;
    END IF;
  END DESBLOQUEAR_USUARIO;
  
  /**
  *
  * EXCESIVAMENTE IMPORTANTE: 
  * Para poder compilar esto el usuario tiene que tener grant 
  * expreso por parte de sysdba
  * Excepciones: 
  */
  PROCEDURE MATAR_SESION (usuario IN VARCHAR2) IS
  VAR_SID v$session.sid%TYPE;
  VAR_SERIAL# v$session.serial#%TYPE;
  
  BEGIN
    BEGIN
    select sid 
    into VAR_SID 
    from v$session 
    where username = usuario;

    END;
    select serial# into VAR_SERIAL# from v$session where username = usuario;
    EXECUTE IMMEDIATE '''alter system kill session '||VAR_SID||','||VAR_SERIAL#||''';
    DBMS_OUTPUT.put_line('''alter system kill session '||VAR_SID||','||VAR_SERIAL#||''');
    
  END MATAR_SESION;


END GEST_USUARIO;
