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
  ERROR_PRIVS_INSUF exception;
  ERROR_USUARIO_NO_EXISTE exception;
  ERROR_DESCONOCIDO exception;
  
  BEGIN
    BEGIN
      EXECUTE IMMEDIATE 'DROP USER ' || usuario || ' CASCADE';
      SYS.dbms_output.put_line('Usuario ' || usuario || ' borrado correctamente');  
      EXCEPTION WHEN OTHERS THEN
      ROLLBACK;
      IF SQLCODE = -1031 THEN RAISE ERROR_PRIVS_INSUF;
      ELSIF SQLCODE = -1918 THEN RAISE ERROR_USUARIO_NO_EXISTE;
      ELSE RAISE ERROR_DESCONOCIDO;
      END IF;
    END;
    EXCEPTION
    when ERROR_PRIVS_INSUF then DBMS_OUTPUT.put_line('Error: no se tienen privilegios suficientes');
    when ERROR_USUARIO_NO_EXISTE then dbms_output.put_line('Error: el usuario ' || usuario || ' no existe');
    when ERROR_DESCONOCIDO then DBMS_OUTPUT.put_line('Error desconocido');
  END BORRAR_USUARIO;
  
  PROCEDURE BLOQUEAR_USUARIO(usuario IN VARCHAR2) IS
  ERROR_USUARIO_NO_EXISTE exception;
  ERROR_PRIVS_INSUF exception;
  ERROR_DESCONOCIDO exception;
  BEGIN
    BEGIN
      EXECUTE IMMEDIATE 'ALTER USER ' || usuario || ' ACCOUNT LOCK';
      SYS.dbms_output.put_line('Usuario ' || usuario || ' bloqueado correctamente');
      EXCEPTION WHEN OTHERS THEN
      IF SQLCODE = -01918 then RAISE ERROR_USUARIO_NO_EXISTE;
      ELSIF SQLCODE = -1031 THEN RAISE ERROR_PRIVS_INSUF;
      ELSE RAISE ERROR_DESCONOCIDO;
      END IF;
    END;
    EXCEPTION
    when ERROR_USUARIO_NO_EXISTE then DBMS_OUTPUT.put_line('Error, el usuario '|| usuario ||' no existe.');
    when ERROR_PRIVS_INSUF then DBMS_OUTPUT.put_line('Error, no se tienen privilegios suficientes.');
    when ERROR_DESCONOCIDO then DBMS_OUTPUT.put_line('Error desconocido.');
  END BLOQUEAR_USUARIO;
  
  PROCEDURE DESBLOQUEAR_USUARIO(usuario IN VARCHAR2) IS
  ERROR_USUARIO_NO_EXISTE exception;
  ERROR_PRIVS_INSUF exception;
  ERROR_DESCONOCIDO exception;
  BEGIN
    BEGIN
      EXECUTE IMMEDIATE 'ALTER USER ' || usuario || ' ACCOUNT UNLOCK';
      SYS.dbms_output.put_line('Usuario ' || usuario || ' desbloqueado correctamente');
      EXCEPTION WHEN OTHERS THEN
      IF SQLCODE = -01918 then RAISE ERROR_USUARIO_NO_EXISTE;
      ELSIF SQLCODE = -1031 THEN RAISE ERROR_PRIVS_INSUF;
      ELSE RAISE ERROR_DESCONOCIDO;
      END IF;
    END;
    EXCEPTION
    when ERROR_USUARIO_NO_EXISTE then DBMS_OUTPUT.put_line('Error, el usuario '|| usuario ||' no existe.');
    when ERROR_PRIVS_INSUF then DBMS_OUTPUT.put_line('Error, no se tienen privilegios suficientes.');
    when ERROR_DESCONOCIDO then DBMS_OUTPUT.put_line('Error desconocido.');
  END DESBLOQUEAR_USUARIO;


END GEST_USUARIO;
