create or replace 
PACKAGE BODY ANTIPLAGIO AS

  PROCEDURE semantico(usuario_id NUMBER, asignatura NUMBER, relacion_id NUMBER, ejercicio_id NUMBER) AS
  --ERROR_ALUMNO_HA_COPIADO EXCEPTION;
  respuesta_alu DOCENCIA.CALIF_EJERCICIO.RESPUESTA%TYPE;
  ha_copiado NUMBER; -- Almacenará 1 si se ha copiado
  CURSOR c_respuestas IS -- Todas las respuestas al ejercicio "ejercicio_id" excepto la del estudiante usuario_id
    SELECT respuesta FROM calif_ejercicio
    WHERE usuario_usuario_id != usuario_id AND asignatura = asignatura_id AND ejercicio_ejercicio_id = ejercicio_id; 
  
  BEGIN 
    SELECT respuesta INTO respuesta_alu FROM calif_ejercicio -- Cogemos la respuesta del estudiante y la metemos en respuesta_alu
      WHERE usuario_usuario_id = usuario_id AND asignatura_id = asignatura AND relacion_relacion_id = relacion_id AND ejercicio_ejercicio_id = ejercicio_id; 
    ha_copiado := 0;
    FOR respuesta IN c_respuestas LOOP
        -- Comparo la respuesta del alumno con las respuestas dadas por otros alumnos al mismo ejericio. Quito espacios y lo pongo en mayúsculas.
        IF UPPER(REPLACE(respuesta.respuesta, ' ')) = UPPER(REPLACE(respuesta_alu, ' ')) THEN 
          dbms_output.put_line('Usuario: '||usuario_id||'. Es muy posible que se haya copiado.');
          ha_copiado := 1;
          EXIT;
        END IF;
    END LOOP;
    
    IF ha_copiado = 0 THEN
      dbms_output.put_line('Usuario: '||usuario_id||'. No ha copiado.');
    END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN dbms_output.put_line('El alumno no ha respondido a esa pregunta.');
      WHEN OTHERS THEN dbms_output.put_line('Error desconocido.');
        
  END semantico;
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------


  procedure antiplagio_relacion(param_asignatura_id IN NUMBER, param_relacion_id in number, alu_usuario_id in number) AS
    
   dedic_tiempo_dias number;
   dedic_tiempo_horas number;
   dedic_tiempo_minutos number;
   dedic_tiempo_segundos number;
   fecha_inicio_al docencia.audit_ejer.fecha_inicio%type;
   fecha_fin_al docencia.audit_ejer.fecha_entrega_correcto%type;
   
   suma_total_min number;
   tiempo_min number;
   excepcion_no_tiempo_minimo exception; 
   excepcion_rel_no_terminada exception;
   CURSOR alum_rel is -- Nos da fecha de inicio, fecha de entrega, de cada ejercicio de la relacion, asignatura y alumnno dados
    select docencia.audit_ejer.fecha_inicio, docencia.audit_ejer.fecha_entrega_correcto 
    from docencia.audit_ejer 
    where docencia.audit_ejer.relacion_id = param_relacion_id AND docencia.audit_ejer.asignatura_id = param_asignatura_id AND docencia.audit_ejer.usuario_id = alu_usuario_id;
    
   BEGIN
    begin     
      select tiempo_minimo into tiempo_min from docencia.relacion where docencia.relacion.relacion_id = param_relacion_id AND docencia.relacion.asignatura_asignatura_id = param_asignatura_id;
      DBMS_OUTPUT.PUT_LINE(tiempo_min);
      exception when others then
 raise excepcion_no_tiempo_minimo;
    end;
    dedic_tiempo_dias := 0;
    dedic_tiempo_horas := 0;
    dedic_tiempo_minutos := 0;
    dedic_tiempo_segundos := 0;
    
    suma_total_min := 0;
    
      FOR calif IN alum_rel LOOP
      begin
        dedic_tiempo_dias := dedic_tiempo_dias + extract(day from calif.fecha_entrega_correcto - calif.fecha_inicio); 
        dedic_tiempo_horas := dedic_tiempo_horas + extract(hour from calif.fecha_entrega_correcto - calif.fecha_inicio);
        dedic_tiempo_minutos := dedic_tiempo_minutos + extract(minute from calif.fecha_entrega_correcto - calif.fecha_inicio);
        dedic_tiempo_segundos := dedic_tiempo_segundos + extract (second from calif.fecha_entrega_correcto - calif.fecha_inicio);
      exception
      when others then 
      raise excepcion_rel_no_terminada;
      END;
    END LOOP;
    /*
    OPEN alum_rel;
    LOOP
      FETCH alum_rel into fecha_inicio_al, fecha_fin_al;
      EXIT WHEN alum_rel%notfound;
      dedic_tiempo_dias := dedic_tiempo_dias + extract(day from (fecha_fin_al - fecha_inicio_al)); 
      dedic_tiempo_horas := dedic_tiempo_horas + extract(hour from (fecha_fin_al - fecha_inicio_al));
      dedic_tiempo_minutos := dedic_tiempo_minutos + extract(minute from (fecha_fin_al - fecha_inicio_al));
      dedic_tiempo_segundos := dedic_tiempo_segundos + extract (second from (fecha_fin_al - fecha_inicio_al));
      DBMS_OUTPUT.PUT_LINE(fecha_inicio_al || '   '  || fecha_fin_al);
    END LOOP;
    */
    
  IF alum_rel%ISOPEN THEN 
    CLOSE alum_rel;
  END IF;
  
  suma_total_min := dedic_tiempo_dias*24*60+
                    dedic_tiempo_horas*60+
                    dedic_tiempo_minutos+
                    dedic_tiempo_segundos/60;
  if suma_total_min <= tiempo_min
  then
  dbms_output.put_line('Atencion: Usuario #'||alu_usuario_id||' ha completado la relación '||param_relacion_id|| ' en '||suma_total_min||' minuto/s.');
  
  
  end if;
     
  exception
  when excepcion_no_tiempo_minimo
  then
  dbms_output.put_line('No se ha introducido un tiempo minimo para la relacion '||param_relacion_id);

  when excepcion_rel_no_terminada
  then
  dbms_output.put_line('El alumno aun no ha acabado la relacion o no ha empezado.');
  when others then
  dbms_output.put_line('Error desconocido');
    IF alum_rel%ISOPEN THEN 
    CLOSE alum_rel;
  END IF;
    end antiplagio_relacion;

---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------



  --Igual que la anterior pero muestra el antiplagio de todas las relaciones
  procedure antiplagio_relacion_todas as
  cursor rel_cur is
  select relacion_id from relacion
  ;
  
  begin
   FOR calif IN rel_cur LOOP
      
      antiplagio_relacion(calif.relacion_id);
     
    END LOOP;
    exception
    when others then
    dbms_output.put_line('Error, no se ha podido ejecutar');
     IF rel_cur%ISOPEN = TRUE THEN 
    CLOSE rel_cur;
    end if;
  end antiplagio_relacion_todas; 

END ANTIPLAGIO; 
