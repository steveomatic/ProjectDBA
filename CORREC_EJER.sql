CREATE OR REPLACE
PACKAGE BODY CORREC_EJER AS

  procedure correccion(cor_usuario_id in number, cor_ejercicio_id in number, cor_relacion_id in number, cor_asignatura_id in number) AS
   /*
  v_alu_query variable que guarda la query 
  enviada por el alumno y despues la ejecuta.
  */
  
  ERROR_NO_DATOS exception;
  ERROR_COLUMNAS_DIF exception;
  ERROR_DESCONOCIDO exception;
  ERROR_TABLA_NO_EXISTE exception;
  
  
  v_alu_query CALIF_EJERCICIO.RESPUESTA%TYPE;
  v_res_query EJERCICIO.SOLUCION%TYPE;
  
  v_respuestas_bien number;
  v_sol number;
  v_sol2 number;
  
  
  BEGIN
  
  --Se usuará para comprobar si ambas diferencias de tablas están a 0
  v_respuestas_bien :=0;
  
  BEGIN
  --mete la query del usuario
    select respuesta
    into v_alu_query
    from CALIF_EJERCICIO
    where usuario_usuario_id = cor_usuario_id AND relacion_relacion_id = cor_relacion_id AND asignatura_id = cor_asignatura_id AND ejercicio_ejercicio_id = cor_ejercicio_id;
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
    from ejercicio
    where ejercicio_id= cor_ejercicio_id;
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE = -01789 then RAISE ERROR_COLUMNAS_DIF;
        ELSIF SQLCODE = -01403 then RAISE ERROR_NO_DATOS;
        ELSIF SQLCODE = -00942 then RAISE ERROR_TABLA_NO_EXISTE;
        ELSE RAISE ERROR_DESCONOCIDO;
        END IF;
  END;
  DBMS_OUTPUT.put_line(v_alu_query);
  DBMS_OUTPUT.put_line(v_res_query);
  
  DBMS_OUTPUT.put_line('select count(*) from ('|| v_alu_query||' MINUS '||v_res_query||')');
  BEGIN
  --comprobamos el count(*) de la diferencia. Si es 0, significa que había filas idénticas.
    execute immediate 'select count(*) from ('|| v_alu_query||' MINUS '||v_res_query||')'
    into v_sol;
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE = -01789 then RAISE ERROR_COLUMNAS_DIF;
        ELSIF SQLCODE = -01403 then RAISE ERROR_NO_DATOS;
        ELSIF SQLCODE = -00942 then RAISE ERROR_TABLA_NO_EXISTE;
        ELSE RAISE ERROR_DESCONOCIDO;
        END IF;
        
  END;
  --Si efectivamente el count(*) da 0, sumamos 1 a v_respuestas_bien. Si la otra comprobación también es correcta, entonces es correcto.
  IF v_sol = 0 THEN 
    v_respuestas_bien := v_respuestas_bien + 1; 
  END IF;
  
  DBMS_OUTPUT.put_line('select count(*) from ('|| v_res_query||' MINUS '||v_alu_query||')');
  BEGIN
    execute immediate 'select count(*) from ('|| v_res_query||' MINUS '||v_res_query||')'
  into v_sol2;
      EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE = -01789 then RAISE ERROR_COLUMNAS_DIF;
        ELSIF SQLCODE = -01403 then RAISE ERROR_NO_DATOS;
        ELSIF SQLCODE = -00942 then RAISE ERROR_TABLA_NO_EXISTE;
        ELSE RAISE ERROR_DESCONOCIDO;
        END IF;
  END;
  IF v_sol2 = 0 THEN 
    v_respuestas_bien := v_respuestas_bien + 1;
  END IF;
  
  dbms_output.put_line(v_sol);
  dbms_output.put_line(v_sol2);
  
  IF v_respuestas_bien = 2 THEN 
    DBMS_OUTPUT.PUT_LINE('Correcto'); 
    --añadir puntuacion positiva
  ELSE DBMS_OUTPUT.PUT_LINE('Mal');
    --añadir puntuacion negativa
  END IF;
  
  
  EXCEPTION
  WHEN ERROR_NO_DATOS then DBMS_OUTPUT.PUT_LINE('No se seleccionó nada.');
  WHEN ERROR_COLUMNAS_DIF THEN DBMS_OUTPUT.PUT_LINE('Incorrecto, las columnas difieren.');
  WHEN ERROR_TABLA_NO_EXISTE THEN DBMS_OUTPUT.PUT_LINE('No existe la tabla');
  WHEN ERROR_DESCONOCIDO THEN DBMS_OUTPUT.PUT_LINE('Error desconocido');
  
  END correccion;

END CORREC_EJER;
