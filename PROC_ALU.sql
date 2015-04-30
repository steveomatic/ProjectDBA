create or replace 
PACKAGE BODY PROC_ALU AS


procedure correccion_alu(cor_usuario_id in number,cor_relacion_id in number , cor_ejercicio_id in number, cor_asignatura_id in number)AS
   /* 
  v_alu_query variable que guarda la query 
  enviada por el alumno y despues la ejecuta.
  */   
   
  ERROR_NO_DATOS exception;
  ERROR_COLUMNAS_DIF exception;
  ERROR_DESCONOCIDO exception;
  ERROR_TABLA_NO_EXISTE exception;
  ERROR_ALUMNO exception;
  
  
  v_alu_query CALIF_EJERCICIO.RESPUESTA%TYPE ;
  v_res_query EJERCICIO.SOLUCION%TYPE;
  
  v_respuestas_bien number;
  v_sol number;
  v_sol2 number;
  
  
  v_retrib number;
  
  
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
  
        select retribucion
        into v_retrib
        from ejercicio
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
 -- DBMS_OUTPUT.put_line(v_alu_query);
  --DBMS_OUTPUT.put_line(v_res_query);
  
  --DBMS_OUTPUT.put_line('select count(*) from ('|| v_alu_query||' MINUS '||v_res_query||')');
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
  
 
  begin
  IF v_respuestas_bien = 2 THEN 
    
   
    update calif_ejercicio
    set nota = v_retrib
    where usuario_usuario_id = cor_usuario_id 
    AND
    relacion_relacion_id = cor_relacion_id
    AND
    asignatura_id = cor_asignatura_id
    AND
    ejercicio_ejercicio_id = cor_ejercicio_id;
    
    --añadir puntuacion positiva
  ELSE DBMS_OUTPUT.PUT_LINE('');
   update calif_ejercicio
    set nota = 0
    where usuario_usuario_id = cor_usuario_id 
    AND
    relacion_relacion_id = cor_relacion_id
    AND
    asignatura_id = cor_asignatura_id
    AND
    ejercicio_ejercicio_id = cor_ejercicio_id;
    --añadir puntuacion negativa
    
    update ejercicio
    set fallos = fallos+1
    where ejercicio_id = cor_ejercicio_id;
  
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
  WHEN ERROR_ALUMNO THEN DBMS_OUTPUT.PUT_LINE('');
  WHEN ERROR_NO_DATOS then DBMS_OUTPUT.PUT_LINE('No se seleccionó nada.');
  WHEN ERROR_COLUMNAS_DIF THEN DBMS_OUTPUT.PUT_LINE('');
  WHEN ERROR_TABLA_NO_EXISTE THEN DBMS_OUTPUT.PUT_LINE('No existe la tabla');
  WHEN ERROR_DESCONOCIDO THEN DBMS_OUTPUT.PUT_LINE('Error desconocido');
  
  END correccion_alu;
  
  
  
  
 

  procedure responder(res_respuesta in varchar2,res_usuario_id in number,res_relacion_id in number , res_ejercicio_id in number, res_asignatura_id in number) as
    ERROR_PRIVS_INSUF exception;
    ERROR_DESCONOCIDO exception;
    respuesta_filtrada DOCENCIA.EJERCICIO.SOLUCION%TYPE;
    begin
    
      begin
        --[DEPRECATED] Si el último carácter es un ; entonces lo elimina, si no, nada. 
        --IF SUBSTR(res_respuesta, -1) = ';' THEN respuesta_filtrada := SUBSTR(res_respuesta, 0,length(res_respuesta)-1);
        --ELSE respuesta_filtrada := res_respuesta;
        --END IF;
        
        --Elimina todos los ; de la respuesta.
        respuesta_filtrada := REPLACE(res_respuesta, ';', ' ');
        
        update DOCENCIA.calif_ejercicio
        set respuesta = respuesta_filtrada
        where usuario_usuario_id = res_usuario_id 
        AND
        relacion_relacion_id = res_relacion_id
        AND
        asignatura_id = res_asignatura_id
        AND
        ejercicio_ejercicio_id = res_ejercicio_id;
        DBMS_OUTPUT.put_line('Respuesta enviada correctamente');
         correccion_alu(res_usuario_id,res_relacion_id,res_ejercicio_id, res_asignatura_id);
          DBMS_OUTPUT.put_line('Respuesta autoevaluada');
        EXCEPTION WHEN OTHERS THEN 
        IF SQLCODE = -1031 then raise ERROR_PRIVS_INSUF;
        ELSE raise ERROR_DESCONOCIDO;
        END IF;
      end;
     
    exception
    when ERROR_PRIVS_INSUF then DBMS_OUTPUT.put_line('Error: no se tienen privilegios suficientes');
   
    when ERROR_DESCONOCIDO then DBMS_OUTPUT.put_line('Error desconocido');
    end responder;


    
    
    
END PROC_ALU;
