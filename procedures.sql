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
  
  VAR_SID v_$session.sid%TYPE;
  VAR_SERIAL# v_$session.serial#%TYPE;
  ERROR_USUARIO_NO_EXISTE exception;
  
  BEGIN
    BEGIN
      select sid into VAR_SID from v_$session where username = usuario;
      select serial# into VAR_SERIAL# from v_$session where username = usuario;
      exception when no_data_found then
      raise ERROR_USUARIO_NO_EXISTE;
      --DBMS_OUTPUT.put_line('alter system kill session '||''''||VAR_SID||','||VAR_SERIAL#|| '#'|| '''');
    END;
  BEGIN
    EXECUTE IMMEDIATE 'alter system kill session '''||VAR_SID||','||VAR_SERIAL#||''' ';
    exception when others then DBMS_OUTPUT.put_line('Error al matar sesión.');
  END;  
  
  exception
    when ERROR_USUARIO_NO_EXISTE then DBMS_OUTPUT.put_line('El usuario '||usuario||' no existe.');
    when others then DBMS_OUTPUT.put_line('Error desconocido.');
  
  END MATAR_SESION;


END GEST_USUARIO;
