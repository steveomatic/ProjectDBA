create or replace 
PACKAGE BODY GEST_USUARIO AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 
  PROCEDURE CREAR_USUARIO(usuario IN VARCHAR2, pass IN VARCHAR2) IS 
   ERROR_PRIVS_INSUF exception;
 ERROR_USUARIO_EXISTE exception;
 ERROR_DESCONOCIDO exception;
 BEGIN
    BEGIN
      EXECUTE IMMEDIATE 'CREATE USER ' || usuario || ' IDENTIFIED BY ' || pass;
     DBMS_OUTPUT.PUT_LINE('Usuario ' || usuario || ' creado correctamente');
      EXCEPTION WHEN OTHERS THEN 
      ROLLBACK;
      IF SQLCODE = -1031 then raise ERROR_PRIVS_INSUF;
      ELSIF SQLCODE = -1920 then raise ERROR_USUARIO_EXISTE;
      ELSE raise ERROR_DESCONOCIDO;
      END IF;
    END;
    
    exception
    when ERROR_PRIVS_INSUF then DBMS_OUTPUT.put_line('Error: no se tienen privilegios suficientes');
    when ERROR_USUARIO_EXISTE then dbms_output.put_line('Error: el usuario ' || usuario || ' ya existe');
    when ERROR_DESCONOCIDO then DBMS_OUTPUT.put_line('Error desconocido');
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
    when ERROR_USUARIO_NO_EXISTE then DBMS_OUTPUT.put_line('El usuario '||usuario||' no tiene la sesión iniciada.');
    when others then DBMS_OUTPUT.put_line('Error desconocido.');
  
  END MATAR_SESION;



END GEST_USUARIO;
