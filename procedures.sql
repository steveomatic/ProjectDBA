create or replace 
PACKAGE BODY GEST_USUARIO AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 

--Procedimiento para crear un usuario específico. Recibe nombre de usuario y contraseña
--PRECONDICION: HA DE ESTAR CREADA LA SECUENCIA usuario_seq
PROCEDURE CREAR_USUARIO(usuario IN VARCHAR2, pass IN VARCHAR2) IS 
  
  --Declaración de las excepciones propias
  ERROR_PRIVS_INSUF exception;    --Privilegios insuficientes
  ERROR_USUARIO_EXISTE exception; --Usuario no existe
  ERROR_ROL_NO_EXISTE exception;  --Rol no existe
  ERROR_UK_VIOLADA exception;     --Clave única violada
  ERROR_DESCONOCIDO exception;    --Otro error
  
  --BEGIN del procedimiento
  BEGIN
  
    --BEGIN del CREATE USER
    BEGIN
      EXECUTE IMMEDIATE 'CREATE USER ' || usuario || ' IDENTIFIED BY ' || pass;
      --DBMS_OUTPUT.PUT_LINE('CREATE USER ' || usuario || ' IDENTIFIED BY ' || pass);
      DBMS_OUTPUT.PUT_LINE('Usuario ' || usuario || ' creado correctamente');   
      
      --Excepciones del CREATE USER
      EXCEPTION WHEN OTHERS THEN 
      IF SQLCODE = -1031 then raise ERROR_PRIVS_INSUF;
      ELSIF SQLCODE = -1920 then raise ERROR_USUARIO_EXISTE;
      ELSE RAISE ERROR_DESCONOCIDO;
      END IF;
    END;
    
    --BEGIN del INSERT INTO USUARIO
    BEGIN
      INSERT INTO USUARIO VALUES(usuario_seq.NEXTVAl,usuario);
      COMMIT;
      
      --Excepciones del INSERT INTO USUARIO
      EXCEPTION WHEN OTHERS THEN 
      IF SQLCODE = -1031 then raise ERROR_PRIVS_INSUF;
      ELSIF SQLCODE = -00001 then raise ERROR_UK_VIOLADA;
      ELSE raise ERROR_DESCONOCIDO;
      END IF;
    END;
    
    --BEGIN DEL GRANT R_USUARIO
    BEGIN
      EXECUTE IMMEDIATE 'GRANT R_ALUMNO TO ' || usuario;
      --DBMS_OUTPUT.PUT_LINE('GRANT R_ALUMNO TO ' || usuario);
      
      --Excepcuones del GRANT R_USUARIO
      EXCEPTION WHEN OTHERS THEN 
      IF SQLCODE = -1031 then raise ERROR_PRIVS_INSUF;
      ELSIF SQLCODE = -1920 then raise ERROR_USUARIO_EXISTE;
      ELSIF SQLCODE = -1919 then raise ERROR_ROL_NO_EXISTE;
      ELSE raise ERROR_DESCONOCIDO;
      END IF;
    END;
    
    EXCEPTION
    WHEN ERROR_PRIVS_INSUF THEN DBMS_OUTPUT.put_line('Error: no se tienen privilegios suficientes');
    WHEN ERROR_USUARIO_EXISTE THEN DBMS_OUTPUT.put_line('Error: el usuario ' || usuario || ' ya existe');
    WHEN ERROR_UK_VIOLADA THEN DBMS_OUTPUT.put_line('Error: usuario ' || usuario || ' creado pero el nombre está repetido y debe ser único');
    WHEN ERROR_ROL_NO_EXISTE THEN DBMS_OUTPUT.put_line('Error: El rol R_USUARIO no existe');
    WHEN ERROR_DESCONOCIDO THEN DBMS_OUTPUT.put_line('Error desconocido');
  END CREAR_USUARIO; 




--Procedimiento para crear varios usuarios. Recibe las siglas de la asignatura y el número de usuarios a crear
--PRECONDICION: HA DE ESTAR CREADA LA SECUENCIA usuario_seq
PROCEDURE CREAR_USUARIOS(asignatura IN VARCHAR2, numero IN NUMBER) IS 
      
    --Declaración de las excepciones propias
    ERROR_PRIVS_INSUF exception;    --Privilegios insuficientes
    ERROR_USUARIO_EXISTE exception; --Usuario no existe
    ERROR_ROL_NO_EXISTE exception;  --Rol no existe
    ERROR_UK_VIOLADA exception;     --Clave única violada
    ERROR_DESCONOCIDO exception;    --Otro error
    
    --Declaración de variables
    var_counter number(6) ;   --Contador para el bucle
    n number(5);              --Número de secuencia para el id y el nombre de cada usuario
    str varchar(5);           --String de 5 caracteres que van a ser aleatorios para cada usuario
    usuario varchar(30);      --Nombre de cada usuario
    
    --BEGIN del procedimiento
    BEGIN
      --Iniciamos el bucle que va de 0 a N (número de usuarios que nos piden)
      var_counter := 0;
      FOR VAR_COUNTER IN 1..numero LOOP
      
      n := usuario_seq.NEXTVAL;          --Extraemos el siguiente valor de la secuencia
      str := DBMS_RANDOM.STRING('U', 5); --Generamos 5 caracteres aleatorios
      usuario := ASIGNATURA || str || n; --Concatenamos para conseguir el username
      
      --BEGIN del CREATE USER
      BEGIN
        EXECUTE IMMEDIATE 'CREATE USER ' || usuario || ' IDENTIFIED BY ' || usuario;
        --DBMS_OUTPUT.PUT_LINE('CREATE USER ' || usuario || ' IDENTIFIED BY ' || usuario);
        DBMS_OUTPUT.PUT_LINE('Usuario ' || usuario || ' creado correctamente');   
        
        --Excepciones del create user
        EXCEPTION WHEN OTHERS THEN 
        IF SQLCODE = -1031 then raise ERROR_PRIVS_INSUF;
        ELSIF SQLCODE = -1920 then raise ERROR_USUARIO_EXISTE;
        ELSE RAISE ERROR_DESCONOCIDO;
        END IF;
      END;
      
      --BEGIN del INSERT INTO
      BEGIN
        INSERT INTO USUARIO VALUES(n,usuario);
        COMMIT;
        
        --Excepciones del INSERT INTO
        EXCEPTION WHEN OTHERS THEN 
        IF SQLCODE = -1031 then raise ERROR_PRIVS_INSUF;
        ELSIF SQLCODE = -00001 then raise ERROR_UK_VIOLADA;
        ELSE raise ERROR_DESCONOCIDO;
        END IF;
      END;
      
      --BEGIN del GRANT R_USUARIO
      BEGIN
        EXECUTE IMMEDIATE 'GRANT R_ALUMNO TO ' || usuario;
        --DBMS_OUTPUT.PUT_LINE('GRANT R_ALUMNO TO ' || usuario);
        
        --Excepciones del GRANT R_USUARIO
        EXCEPTION WHEN OTHERS THEN 
        IF SQLCODE = -1031 then raise ERROR_PRIVS_INSUF;
        ELSIF SQLCODE = -1920 then raise ERROR_USUARIO_EXISTE;
        ELSIF SQLCODE = -1919 then raise ERROR_ROL_NO_EXISTE;
        ELSE raise ERROR_DESCONOCIDO;
        END IF;
      END;
      
      
      END LOOP;
      --Acaba el bucle de creación, inserción y concesión de privilegios a N usuarios
    
    --Tratamiento de excepciones del procedimiento
    EXCEPTION
    WHEN ERROR_PRIVS_INSUF THEN DBMS_OUTPUT.put_line('Error: no se tienen privilegios suficientes');
    WHEN ERROR_USUARIO_EXISTE THEN DBMS_OUTPUT.put_line('Error: el usuario ' || usuario || ' ya existe');
    WHEN ERROR_UK_VIOLADA THEN DBMS_OUTPUT.put_line('Error: usuario ' || usuario || ' creado pero el nombre está repetido y debe ser único');
    WHEN ERROR_ROL_NO_EXISTE THEN DBMS_OUTPUT.put_line('Error: El rol R_USUARIO no existe');
    WHEN ERROR_DESCONOCIDO THEN DBMS_OUTPUT.put_line('Error desconocido');
 END CREAR_USUARIOS;


 

PROCEDURE BORRAR_USUARIO(usuario IN VARCHAR2) IS
  ERROR_PRIVS_INSUF exception;
  ERROR_USUARIO_NO_EXISTE exception;
  ERROR_DESCONOCIDO exception;
  BEGIN 
    EXECUTE IMMEDIATE 'DROP USER ' || usuario || ' CASCADE';
    SYS.dbms_output.put_line('Usuario ' || usuario || ' borrado correctamente');
    begin
      delete from  usuario where
        usuario.nombre = usuario;
      EXCEPTION WHEN OTHERS THEN
        IF SQLCODE = -01918 then RAISE ERROR_USUARIO_NO_EXISTE;
        ELSIF SQLCODE = -1031 THEN RAISE ERROR_PRIVS_INSUF;
        ELSE RAISE ERROR_DESCONOCIDO;
        END IF;
      end;
    
    EXCEPTION
      WHEN ERROR_PRIVS_INSUF then DBMS_OUTPUT.put_line('Error: no se tienen privilegios suficientes');
      WHEN ERROR_USUARIO_NO_EXISTE THEN dbms_output.put_line('Error, el usuario no estaba registrado');
      WHEN ERROR_DESCONOCIDO then DBMS_OUTPUT.put_line('Error desconocido');
      WHEN others THEN DBMS_OUTPUT.put_line('Error desconocido');

  END BORRAR_USUARIO;
  
  -- Borra todos los usuarios buscando en la tabla usuarios los usuarios y llamando
  -- a la función BORRAR_USUARIO(usuario) en un for.
  
  PROCEDURE BORRAR_TODOS_USUARIOS IS
  cursor c_usuarios IS SELECT nombre FROM usuario;
  BEGIN
    FOR var_usuario in c_usuarios LOOP -- Puedo declarar la variable var_usuario aquí.
      BORRAR_USUARIO(var_usuario.nombre);
    END LOOP;
    EXCEPTION 
      WHEN no_data_found THEN
        dbms_output.put_line('No hay usuarios para borrar.');
      WHEN OTHERS THEN
        dbms_output.put_line('Error desconocido.');
  END BORRAR_TODOS_USUARIOS;
  
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

  PROCEDURE BLOQUEAR_TODOS_USUARIOS IS
  cursor c_usuarios IS SELECT nombre FROM usuario; -- Cursor que almacena los nombres de los usuarios
  BEGIN
    FOR var_usuario IN c_usuarios LOOP -- Puedo declarar la variable var_usuario aquí.
      BLOQUEAR_USUARIO(var_usuario.nombre); -- Bloqueamos cada usuario
    END LOOP;
    EXCEPTION
      WHEN no_data_found THEN -- Si no hay usuarios (consulta vacía)
        dbms_output.put_line('No hay usuarios para borrar.');
      WHEN OTHERS THEN
        dbms_output.put_line('Error desconocido.');
  END BLOQUEAR_TODOS_USUARIOS;
  
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

  PROCEDURE DESBLOQUEAR_TODOS_USUARIOS IS
  cursor c_usuarios IS SELECT nombre FROM usuario; -- Cursor que almacena los nombres de los usuarios
  BEGIN
    FOR var_usuario IN c_usuarios LOOP -- Puedo declarar la variable var_usuario aquí.
      DESBLOQUEAR_USUARIO(var_usuario.nombre); -- Bloqueamos cada usuario
    END LOOP;
    EXCEPTION
      WHEN no_data_found THEN -- Si no hay usuarios (consulta vacía)
        dbms_output.put_line('No hay usuarios para borrar.');
      WHEN OTHERS THEN
        dbms_output.put_line('Error desconocido.');
  END DESBLOQUEAR_TODOS_USUARIOS;
  
  -- Mata la sesión de usuario. Si no la tiene iniciada, nos dice que ese usuario no tiene iniciada la sesión
  -- Hemos creado un sinónimo público para V$session llamado v_$session y hemos dado permiso de select a él a R_profesor y docencia.
  --
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
