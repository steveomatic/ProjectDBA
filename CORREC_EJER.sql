create or replace 
PACKAGE BODY CORREC_EJER AS

 procedure correccion(cor_usuario_id in number,cor_relacion_id in number , cor_ejercicio_id in number, cor_asignatura_id in number)AS
  
  ERROR_NO_DATOS exception;
  ERROR_COLUMNAS_DIF exception; -- Este error se puede dar cuando hacemos select a,b from.. union select a from.. Esto causa un error ya que hace la unión de columnas diferentes.
  ERROR_DESCONOCIDO exception;
  ERROR_TABLA_NO_EXISTE exception;
  ERROR_ALUMNO exception;
  
  
  v_alu_query CALIF_EJERCICIO.RESPUESTA%TYPE ;  --variable que guarda la query enviada por el alumno y despues la ejecuta.
  v_res_query EJERCICIO.SOLUCION%TYPE; -- variable que guarda la solución.
  
  v_respuestas_bien number; -- Se usa para comprobar que las dif de las tablas son 0
  v_sol number;
  v_sol2 number;
  
  
  v_retrib number; -- Valor del ejercicio
  
  
  BEGIN
  
  --Se usuará para comprobar si ambas diferencias de tablas están a 0
  v_respuestas_bien :=0;
  
  BEGIN
  --mete la query del usuario
    select respuesta
    into v_alu_query
    from docencia.CALIF_EJERCICIO
    where usuario_usuario_id = cor_usuario_id AND relacion_relacion_id = cor_relacion_id AND asignatura_id = cor_asignatura_id AND ejercicio_ejercicio_id = cor_ejercicio_id;
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE = -01789 then RAISE ERROR_COLUMNAS_DIF; -- Este error se puede dar cuando hacemos select a,b from.. union select a from.. Esto causa un error ya que hace la unión de columnas diferentes.
        ELSIF SQLCODE = -01403 then RAISE ERROR_NO_DATOS;
        ELSIF SQLCODE = -00942 then RAISE ERROR_TABLA_NO_EXISTE;
        ELSE RAISE ERROR_DESCONOCIDO; -- Este error también podría ser que el alumno hubiera escrito una solución que no fuese un código sql válido
        END IF;
  END;
  
  BEGIN
  
      select retribucion
      into v_retrib
      from docencia.ejercicio
      where ejercicio_id = cor_ejercicio_id;
    
      EXCEPTION
        WHEN OTHERS THEN
          IF SQLCODE = -01789 then RAISE ERROR_COLUMNAS_DIF;
            ELSIF SQLCODE = -01403 then RAISE ERROR_NO_DATOS;
            ELSIF SQLCODE = -00942 then RAISE ERROR_TABLA_NO_EXISTE;
          ELSE RAISE ERROR_DESCONOCIDO;
        END IF;
  END;
  
  BEGIN
  --mete la query que da la solucion correcta
    select solucion
    into v_res_query
    from docencia.ejercicio
    where ejercicio_id= cor_ejercicio_id;
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE = -01789 then RAISE ERROR_COLUMNAS_DIF;
        ELSIF SQLCODE = -01403 then RAISE ERROR_NO_DATOS;
        ELSIF SQLCODE = -00942 then RAISE ERROR_TABLA_NO_EXISTE;
        ELSE RAISE ERROR_DESCONOCIDO;
        END IF;
  END;
 -- DBMS_OUTPUT.put_line(v_alu_query);
  --DBMS_OUTPUT.put_line(v_res_query);
  
  DBMS_OUTPUT.put_line('select count(*) from ('|| v_alu_query||' MINUS '||v_res_query||')');
  BEGIN
  --comprobamos el count(*) de la diferencia. Si es 0, significa que había filas idénticas.
    execute immediate 'select count(*) from ('|| v_alu_query||' MINUS '||v_res_query||')'
    into v_sol;
    EXCEPTION
      WHEN OTHERS THEN       
        RAISE ERROR_ALUMNO;
  END;
  --Si efectivamente el count(*) da 0, sumamos 1 a v_respuestas_bien. Si la otra comprobación también es correcta, entonces es correcto.
  IF v_sol = 0 THEN 
    v_respuestas_bien := v_respuestas_bien + 1; 
  END IF;
  
  -- Aún queda por comprobar que res minus alu_query = 0
  
 -- DBMS_OUTPUT.put_line('select count(*) from ('|| v_res_query||' MINUS '||v_alu_query||')');
  BEGIN
    execute immediate 'select count(*) from ('|| v_res_query||' MINUS '||v_res_query||')'
    into v_sol2;
      EXCEPTION
      WHEN OTHERS THEN
      RAISE ERROR_ALUMNO;
      
  END;
  IF v_sol2 = 0 THEN 
    v_respuestas_bien := v_respuestas_bien + 1;
  END IF;
  
  dbms_output.put_line(v_sol);
  dbms_output.put_line(v_sol2);
  begin
  IF v_respuestas_bien = 2 THEN     --añadir puntuacion positiva
    DBMS_OUTPUT.PUT_LINE('Correcto'); 
   
    update docencia.calif_ejercicio
    set nota = v_retrib
    where usuario_usuario_id = cor_usuario_id 
    AND
    relacion_relacion_id = cor_relacion_id
    AND
    asignatura_id = cor_asignatura_id
    AND
    ejercicio_ejercicio_id = cor_ejercicio_id;
    
  ELSE 
    DBMS_OUTPUT.PUT_LINE('Mal');     --añadir puntuacion negativa
    poner_cero(cor_usuario_id, cor_usuario_id, cor_ejercicio_id, cor_asignatura_id);
  
  END IF;
  
   EXCEPTION 
      WHEN OTHERS THEN
        IF SQLCODE = -01789 then RAISE ERROR_COLUMNAS_DIF;
        ELSIF SQLCODE = -01403 then RAISE ERROR_NO_DATOS;
        ELSIF SQLCODE = -00942 then RAISE ERROR_TABLA_NO_EXISTE;
        ELSE RAISE ERROR_DESCONOCIDO;
        END IF;
  end;
  
  EXCEPTION
  WHEN ERROR_ALUMNO THEN DBMS_OUTPUT.PUT_LINE('Incorrecto'); poner_cero(cor_usuario_id, cor_usuario_id, cor_ejercicio_id, cor_asignatura_id);
  WHEN ERROR_NO_DATOS then DBMS_OUTPUT.PUT_LINE('No se seleccionó nada.'); poner_cero(cor_usuario_id, cor_usuario_id, cor_ejercicio_id, cor_asignatura_id);
  WHEN ERROR_COLUMNAS_DIF THEN DBMS_OUTPUT.PUT_LINE('Incorrecto, las columnas difieren.');poner_cero(cor_usuario_id, cor_usuario_id, cor_ejercicio_id, cor_asignatura_id);
  WHEN ERROR_TABLA_NO_EXISTE THEN DBMS_OUTPUT.PUT_LINE('No existe la tabla');poner_cero(cor_usuario_id, cor_usuario_id, cor_ejercicio_id, cor_asignatura_id);
  WHEN ERROR_DESCONOCIDO THEN DBMS_OUTPUT.PUT_LINE('Error desconocido');poner_cero(cor_usuario_id, cor_usuario_id, cor_ejercicio_id, cor_asignatura_id);
  
  END correccion;
  
 procedure poner_cero(cor_usuario_id in number,cor_relacion_id in number , cor_ejercicio_id in number, cor_asignatura_id in number) AS   
  BEGIN
    update docencia.calif_ejercicio
    set nota = 0
    where usuario_usuario_id = cor_usuario_id 
    AND
    relacion_relacion_id = cor_relacion_id
    AND
    asignatura_id = cor_asignatura_id
    AND
    ejercicio_ejercicio_id = cor_ejercicio_id;
    
    update ejercicio
    set fallos = fallos+1
    where ejercicio_id = cor_ejercicio_id;
  END poner_cero;

END CORREC_EJER;