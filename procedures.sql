CREATE OR REPLACE
PACKAGE BODY GEST_USUARIO AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 


---------------------------------------------------------
---------------------------------------------------------


--Procedimiento para crear un usuario específico. Recibe nombre de usuario y contraseña
--PRECONDICION: HA DE ESTAR CREADA LA SECUENCIA usuario_seq
PROCEDURE CREAR_USUARIO(usuario IN VARCHAR2, pass IN VARCHAR2) IS 
  
  --Declaración de las excepciones propias
  ERROR_PRIVS_INSUF exception;    --Privilegios insuficientes
  ERROR_PRIVS_INSERT_INSUF exception; -- Privilegios insuficientes para hacer el insert
  ERROR_PRIVS_GRANT_INSUF exception; -- Privilegios insuficientes para hacer el grant
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
      IF SQLCODE = -1031 then raise ERROR_PRIVS_INSERT_INSUF;
      ELSIF SQLCODE = -00001 then raise ERROR_UK_VIOLADA;
      ELSE raise ERROR_DESCONOCIDO;
      END IF;
    END;
    
    --BEGIN DEL GRANT R_ALUMNO
    BEGIN
      EXECUTE IMMEDIATE 'GRANT R_ALUMNO TO ' || usuario;
      --DBMS_OUTPUT.PUT_LINE('GRANT R_ALUMNO TO ' || usuario);
      
      --Excepciones del GRANT R_ALUMNO
      EXCEPTION WHEN OTHERS THEN 
      IF SQLCODE = -1031 then raise ERROR_PRIVS_GRANT_INSUF;
      ELSIF SQLCODE = -1920 then raise ERROR_USUARIO_EXISTE;
      ELSIF SQLCODE = -1919 then raise ERROR_ROL_NO_EXISTE;
      ELSE raise ERROR_DESCONOCIDO;
      END IF;
    END;
    
    DBMS_OUTPUT.PUT_LINE('Usuario ' || usuario || ' creado correctamente');   
    EXCEPTION
    WHEN ERROR_PRIVS_INSUF THEN 
      DBMS_OUTPUT.put_line('Error: no se tienen privilegios suficientes para crear el usuario.');
    WHEN ERROR_USUARIO_EXISTE THEN 
      DBMS_OUTPUT.put_line('Error: el usuario ' || usuario || ' ya existe');
    WHEN ERROR_UK_VIOLADA THEN 
      DBMS_OUTPUT.put_line('Error: El usuario ' || usuario || ' ya existe en la base de datos o el id que se iba a utilizar para ese usuario que aún no existe ya estaba en uso. En este último caso, inténtelo de nuevo.');
      EXECUTE IMMEDIATE 'DROP USER ' || usuario; 
    WHEN ERROR_PRIVS_INSERT_INSUF THEN
      DBMS_OUTPUT.put_line('Error: No se tienen privilegios suficientes para insertar el usuario en la base de datos.');
      EXECUTE IMMEDIATE 'DROP USER ' || usuario; 
    WHEN ERROR_PRIVS_GRANT_INSUF THEN
      DBMS_OUTPUT.put_line('Error: No se tienen privilegios suficientes para dar el rol R_ALIMNO.');
      EXECUTE IMMEDIATE 'DROP USER ' || usuario; 
      DELETE FROM usuario WHERE nombre = usuario;
    WHEN ERROR_ROL_NO_EXISTE THEN 
      DBMS_OUTPUT.put_line('Error: El rol R_ALUMNO no existe');
      EXECUTE IMMEDIATE 'DROP USER ' || usuario; 
      DELETE FROM usuario WHERE nombre = usuario;
    WHEN ERROR_DESCONOCIDO THEN 
      DBMS_OUTPUT.put_line('Error desconocido');
      EXECUTE IMMEDIATE 'DROP USER ' || usuario; 
      DELETE FROM usuario WHERE nombre = usuario;
  END CREAR_USUARIO; 


---------------------------------------------------------
---------------------------------------------------------


--Procedimiento para crear varios usuarios. Recibe las siglas de la asignatura y el número de usuarios a crear
--PRECONDICION: HA DE ESTAR CREADA LA SECUENCIA usuario_seq
PROCEDURE CREAR_USUARIOS(asignatura IN VARCHAR2, numero IN NUMBER) IS 
      
    --Declaración de las excepciones propias
    ERROR_PRIVS_INSUF exception;    --Privilegios insuficientes
    ERROR_PRIVS_INSERT_INSUF exception; -- Privilegios insuficientes para hacer el insert
    ERROR_PRIVS_GRANT_INSUF exception; -- Privilegios insuficientes para hacer el grant
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
        IF SQLCODE = -1031 then raise ERROR_PRIVS_INSERT_INSUF;
        ELSIF SQLCODE = -00001 then raise ERROR_UK_VIOLADA;
        ELSE raise ERROR_DESCONOCIDO;
        END IF;
      END;
      
      --BEGIN del GRANT R_ALUMNO
      BEGIN
        EXECUTE IMMEDIATE 'GRANT R_ALUMNO TO ' || usuario;
        --DBMS_OUTPUT.PUT_LINE('GRANT R_ALUMNO TO ' || usuario);
        
        --Excepciones del GRANT R_ALUMNO
        EXCEPTION WHEN OTHERS THEN 
        IF SQLCODE = -1031 then raise ERROR_PRIVS_GRANT_INSUF;
        ELSIF SQLCODE = -1919 then raise ERROR_ROL_NO_EXISTE;
        ELSE raise ERROR_DESCONOCIDO;
        END IF;
      END;
      
      
      END LOOP;
      --Acaba el bucle de creación, inserción y concesión de privilegios a N usuarios
    
    --Tratamiento de excepciones del procedimiento
   EXCEPTION
    WHEN ERROR_PRIVS_INSUF THEN 
      DBMS_OUTPUT.put_line('Error: no se tienen privilegios suficientes para crear el usuario.');
    WHEN ERROR_USUARIO_EXISTE THEN 
      DBMS_OUTPUT.put_line('Error: el usuario ' || usuario || ' ya existe');
    WHEN ERROR_UK_VIOLADA THEN 
      DBMS_OUTPUT.put_line('Error: El usuario ' || usuario || ' ya existe en la base de datos o el id que se iba a utilizar para ese usuario que aún no existe ya estaba en uso. En este último caso, inténtelo de nuevo.');
      EXECUTE IMMEDIATE 'DROP USER ' || usuario; 
    WHEN ERROR_PRIVS_INSERT_INSUF THEN
      DBMS_OUTPUT.put_line('Error: No se tienen privilegios suficientes para insertar el usuario en la base de datos.');
      EXECUTE IMMEDIATE 'DROP USER ' || usuario; 
    WHEN ERROR_PRIVS_GRANT_INSUF THEN
      DBMS_OUTPUT.put_line('Error: No se tienen privilegios suficientes para dar el rol R_ALIMNO.');
      EXECUTE IMMEDIATE 'DROP USER ' || usuario; 
      DELETE FROM usuario WHERE nombre = usuario;
    WHEN ERROR_ROL_NO_EXISTE THEN 
      DBMS_OUTPUT.put_line('Error: El rol R_ALUMNO no existe');
      EXECUTE IMMEDIATE 'DROP USER ' || usuario; 
      DELETE FROM usuario WHERE nombre = usuario;
    WHEN ERROR_DESCONOCIDO THEN 
      DBMS_OUTPUT.put_line('Error desconocido');
      EXECUTE IMMEDIATE 'DROP USER ' || usuario; 
      DELETE FROM usuario WHERE nombre = usuario;
 END CREAR_USUARIOS;


---------------------------------------------------------
---------------------------------------------------------


--Procedimiento para borrar user específico. Recibe el nombre del usuario a borrar
PROCEDURE BORRAR_USUARIO(usuario IN VARCHAR2) IS

  --Declaración de las excepciones propias
  ERROR_PRIVS_INSUF exception;        --Privilegios insuficientes
  ERROR_USUARIO_NO_EXISTE exception;  --Usuario no existe
  ERROR_DESCONOCIDO exception;        --Otro error

  --BEGIN del procedimiento
  BEGIN 

    --BEGIN del DROP USER
    BEGIN
    EXECUTE IMMEDIATE 'DROP USER ' || usuario || ' CASCADE';
    --DBMS_OUTPUT.PUT_LINE('DROP USER ' || usuario || ' CASCADE');
    DBMS_OUTPUT.PUT_LINE('Usuario ' || usuario || ' borrado correctamente');

    --Excepciones del create user
    EXCEPTION WHEN OTHERS THEN
      IF SQLCODE = -01918 then RAISE ERROR_USUARIO_NO_EXISTE;
      ELSIF SQLCODE = -1031 THEN RAISE ERROR_PRIVS_INSUF;
      ELSE RAISE ERROR_DESCONOCIDO;
      END IF;
    END;

    --BEGIN del DELETE FROM
    BEGIN
      DELETE FROM usuario WHERE usuario.nombre = usuario;

      --Excepciones del DELETE FROM
      EXCEPTION WHEN OTHERS THEN
        IF SQLCODE = -01918 then RAISE ERROR_USUARIO_NO_EXISTE;
        ELSIF SQLCODE = -1031 THEN RAISE ERROR_PRIVS_INSUF;
        ELSE RAISE ERROR_DESCONOCIDO;
        END IF;
    END;
    
    --Excepciones del procedimiento
    EXCEPTION
      WHEN ERROR_PRIVS_INSUF THEN DBMS_OUTPUT.put_line('Error: no se tienen privilegios suficientes');
      WHEN ERROR_USUARIO_NO_EXISTE THEN dbms_output.put_line('Error: el usuario no estaba registrado');
      WHEN ERROR_DESCONOCIDO THEN DBMS_OUTPUT.put_line('Error desconocido');
      WHEN others THEN DBMS_OUTPUT.put_line('Error desconocido');

  END BORRAR_USUARIO;
  

---------------------------------------------------------
---------------------------------------------------------


  --Procedimiento que borra todos los usuarios buscando en la tabla usuarios los usuarios 
  --y llamando a la función BORRAR_USUARIO(usuario) en un for.
  PROCEDURE BORRAR_TODOS_USUARIOS IS

  --Se declara un cursor sobre los nombres de la tabla usuario
  cursor c_usuarios IS SELECT nombre FROM usuario;

  --BEGIN del procedimiento
  BEGIN
    --Declaramos la variable var_usuario en el propio bucle sobre el cursor
    FOR var_usuario in c_usuarios LOOP 
      --Llamamos a la función borrar_usuario para cada nombre de la tabla usuario
      BORRAR_USUARIO(var_usuario.nombre);
    END LOOP;

    --Excepciones del procedimiento
    EXCEPTION 
      WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.put_line('No hay usuarios para borrar.');
      WHEN OTHERS THEN
        DBMS_OUTPUT.put_line('Error desconocido.');
  END BORRAR_TODOS_USUARIOS;
  

---------------------------------------------------------
---------------------------------------------------------


  --Procedimiento para bloquear un usuario específico. Recibe el nombre de dicho user.
  PROCEDURE BLOQUEAR_USUARIO(usuario IN VARCHAR2) IS

  --Declaración de las excepciones propias
  ERROR_USUARIO_NO_EXISTE exception;    --No existe el usuario que se quiere bloquear
  ERROR_PRIVS_INSUF exception;          --No hay privilegios suficientes
  ERROR_DESCONOCIDO exception;          --Otro error

  --BEGIN del procedimiento
  BEGIN

    --BEGIN del ALTER USER ACCOUNT LOCK
    BEGIN
      EXECUTE IMMEDIATE 'ALTER USER ' || usuario || ' ACCOUNT LOCK';
      --DBMS_OUTPUT.put_line('ALTER USER ' || usuario || ' ACCOUNT LOCK');
      DBMS_OUTPUT.put_line('Usuario ' || usuario || ' bloqueado correctamente');

      --Excepciones del ALTER USER
      EXCEPTION WHEN OTHERS THEN
      IF SQLCODE = -01918 then RAISE ERROR_USUARIO_NO_EXISTE;
      ELSIF SQLCODE = -1031 THEN RAISE ERROR_PRIVS_INSUF;
      ELSE RAISE ERROR_DESCONOCIDO;
      END IF;
    END;

    --Tratamiento de excepciones del procedimiento
    EXCEPTION
    WHEN ERROR_USUARIO_NO_EXISTE then DBMS_OUTPUT.put_line('Error, el usuario '|| usuario ||' no existe.');
    WHEN ERROR_PRIVS_INSUF then DBMS_OUTPUT.put_line('Error: no se tienen privilegios suficientes.');
    WHEN ERROR_DESCONOCIDO then DBMS_OUTPUT.put_line('Error desconocido.');
  END BLOQUEAR_USUARIO;


---------------------------------------------------------
---------------------------------------------------------


  --Procedimiento que bloquea a todos los usuarios usando la función BLOQUEAR_USUARIO
  PROCEDURE BLOQUEAR_TODOS_USUARIOS IS

  --Cursor que almacena los nombres de los usuarios
  cursor c_usuarios IS SELECT nombre FROM usuario; 

  --BEGIN del procedimiento
  BEGIN

    --Declaramos la variable var_usuario en el propio bucle sobre el cursor
    FOR var_usuario IN c_usuarios LOOP
      BLOQUEAR_USUARIO(var_usuario.nombre); --Bloqueamos a cada usuario
    END LOOP;

    --Excepciones del procedimiento
    EXCEPTION
      WHEN NO_DATA_FOUND THEN --Si no hay usuarios (consulta vacía)
        DBMS_OUTPUT.put_line('No hay usuarios para borrar.');
      WHEN OTHERS THEN
        DBMS_OUTPUT.put_line('Error desconocido.');
  END BLOQUEAR_TODOS_USUARIOS;
  

---------------------------------------------------------
---------------------------------------------------------


  --Procedimiento que desbloquea a un usuario específico que se le indica
  PROCEDURE DESBLOQUEAR_USUARIO(usuario IN VARCHAR2) IS

  --Declaramos las excepciones propias
  ERROR_USUARIO_NO_EXISTE exception;  --El usuario que se quiere desbloquear no existe
  ERROR_PRIVS_INSUF exception;        --No hay privilegios suficientes
  ERROR_DESCONOCIDO exception;        --Otro error

  --BEGIN del procedimiento
  BEGIN

    --Begin del ALTER USER ACCOUNT UNLOCK
    BEGIN
      EXECUTE IMMEDIATE 'ALTER USER ' || usuario || ' ACCOUNT UNLOCK';
      DBMS_OUTPUT.put_line('Usuario ' || usuario || ' desbloqueado correctamente');

      --Excepciones del ALTER USE
      EXCEPTION WHEN OTHERS THEN
      IF SQLCODE = -01918 then RAISE ERROR_USUARIO_NO_EXISTE;
      ELSIF SQLCODE = -1031 THEN RAISE ERROR_PRIVS_INSUF;
      ELSE RAISE ERROR_DESCONOCIDO;
      END IF;
    END;

    --Tratamiento de excepciones del procedimiento
    EXCEPTION
    when ERROR_USUARIO_NO_EXISTE then DBMS_OUTPUT.put_line('Error, el usuario '|| usuario ||' no existe.');
    when ERROR_PRIVS_INSUF then DBMS_OUTPUT.put_line('Error: no se tienen privilegios suficientes.');
    when ERROR_DESCONOCIDO then DBMS_OUTPUT.put_line('Error desconocido.');
  END DESBLOQUEAR_USUARIO;


---------------------------------------------------------
---------------------------------------------------------


  --Procedimiento para desbloquear todos los usuarios que llama a DESBLOQUEAR_USUARIO
  PROCEDURE DESBLOQUEAR_TODOS_USUARIOS IS

  --Cursor que almacena los nombres de los usuarios
  cursor c_usuarios IS SELECT nombre FROM usuario;

  --BEGIN del procedimiento
  BEGIN
    --Declaramos la variable var_usuario en el propio bucle sobre el cursor
    FOR var_usuario IN c_usuarios LOOP
      DESBLOQUEAR_USUARIO(var_usuario.nombre); --Desbloqueamos a cada usuario
    END LOOP;

    --Excepciones del procedimiento
    EXCEPTION
      WHEN NO_DATA_FOUND THEN -- Si no hay usuarios (consulta vacía)
        DBMS_OUTPUT.put_line('No hay usuarios para borrar.');
      WHEN OTHERS THEN
        DBMS_OUTPUT.put_line('Error desconocido.');
  END DESBLOQUEAR_TODOS_USUARIOS;
  

---------------------------------------------------------
---------------------------------------------------------


  --Mata la sesión de usuario. Si no la tiene iniciada, nos dice que ese usuario no tiene iniciada la sesión
  --Hemos creado un sinónimo público para V$session llamado v_$session y hemos dado permiso de select a él a R_profesor y docencia.
  PROCEDURE MATAR_SESION (usuario IN VARCHAR2) IS
  
  --Declaramos una variable que va a almacenar el SID de la sesión del usuario
  VAR_SID v_$session.sid%TYPE;
  --Declaramos una variable que va a almacenar el SERIAL de la sesión del usuario
  VAR_SERIAL# v_$session.serial#%TYPE;

  ERROR_USUARIO_NO_EXISTE exception;  --El usuario cuya sesión quieren que matemos no existe
  ERROR_DESCONOCIDO exception;        --Otro error
  
  --BEGIN del procedimiento
  BEGIN

    --BEGIN del SELECT
    BEGIN

      --Extraemos el SID y el SERIAL de la sesión del usuario
      --Son los valores que necesitamos para llamar a ALTER SYSTEM KILL SESSION
      SELECT sid into VAR_SID from v_$session where username = usuario;
      SELECT serial# into VAR_SERIAL# from v_$session where username = usuario;

      --Excepciones del SELECT
      EXCEPTION
      WHEN NO_DATA_FOUND THEN RAISE ERROR_USUARIO_NO_EXISTE;
      WHEN OTHERS THEN RAISE ERROR_DESCONOCIDO;
    END;

    --BEGIN del ALTER SYSTEM KILL SESSION
    BEGIN
      --DBMS_OUTPUT.put_line('ALTER SYSTEM KILL SESSION '||''''||VAR_SID||','||VAR_SERIAL#|| '#'|| '''');
      EXECUTE IMMEDIATE 'ALTER SYSTEM KILL SESSION '''||VAR_SID||','||VAR_SERIAL#||''' ';

      --Excepciones del ALTER SYSTEM KILL SESSION
      EXCEPTION
      WHEN OTHERS THEN DBMS_OUTPUT.put_line('Error al matar sesión.');
    END;  
  
    --Tratamiento de excepciones del procedimiento
    EXCEPTION
    WHEN ERROR_USUARIO_NO_EXISTE THEN DBMS_OUTPUT.put_line('El usuario '||usuario||' no tiene la sesión iniciada.');
    WHEN OTHERS THEN DBMS_OUTPUT.put_line('Error desconocido.');
  
  END MATAR_SESION;


---------------------------------------------------------
---------------------------------------------------------


END GEST_USUARIO;