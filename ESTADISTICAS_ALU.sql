create or replace 
PACKAGE BODY ESTADISTICAS_ALU AS

  -- Busca los ejercicios con el mayor número de fallos y los muestra. Solo da aquellos cuyo número de fallos es max(fallos)  
   PROCEDURE MAS_FALLOS AS
   ejer_id docencia.ejercicio.ejercicio_id%type;
   ejercicio_enunciado docencia.ejercicio.enunciado%type;
   ejercicio_fallos docencia.ejercicio.fallos%type;
   CURSOR ejer_cur is -- Cursor que tiene los ejercicios donde más se ha fallado (todos tienen el mismo nº de fallos)
       select ejercicio_id,enunciado,fallos from docencia.ejercicio
       where fallos in (select max(fallos) from docencia.ejercicio);
       
    BEGIN
       /* Otra forma propuesta por felipe. La veo más complicada. Fdo: Haritz Beck
       OPEN ejer_cur;
       LOOP
          FETCH ejer_cur into ejer_id, ejercicio_enunciado,ejercicio_fallos;
          EXIT WHEN ejer_cur%notfound;
          dbms_output.put_line('ID= '||ejer_id || ' ' || ejercicio_enunciado || ' #Fallos=' ||ejercicio_fallos);
       END LOOP;
       CLOSE ejer_cur;
       */
       FOR ejercicio IN ejer_cur LOOP
          ejer_id := ejercicio.ejercicio_id;
          ejercicio_enunciado := ejercicio.enunciado;
          ejercicio_fallos := ejercicio.fallos;
          dbms_output.put_line('ID= '||ejer_id || ' ' || ejercicio_enunciado || ' #Fallos=' ||ejercicio_fallos);
       END LOOP;
       
       IF ejer_cur%ISOPEN = TRUE THEN 
        CLOSE ejer_cur;
       END IF;
       
       EXCEPTION
       WHEN others then
       dbms_output.put_line('Error, no se ha podido encontrar los ejercicios');
  END MAS_FALLOS;


 procedure antiplagio_relacion(relacion_id in number) as
    
   dedic_tiempo_dias number;
   dedic_tiempo_horas number;
   dedic_tiempo_minutos number;
   dedic_tiempo_segundos number;
   fecha_inicio_al docencia.audit_ejer.fecha_inicio%type;
   fecha_fin_al docencia.audit_ejer.fecha_entrega_correcto%type;
 
   alu_usuario_id docencia.relacion.usuario_usuario_id%type;
  
    suma_total_min number;
    
    tiempo_min number;
     
  
  CURSOR alum_rel(p_alu_usuario  number)  is
    select docencia.audit_ejer.fecha_inicio, docencia.audit_ejer.fecha_entrega_correcto from docencia.audit_ejer
    inner join 
    (select docencia.calif_ejercicio.ejercicio_ejercicio_id, docencia.calif_ejercicio.relacion_relacion_id 
    from docencia.calif_ejercicio where docencia.calif_ejercicio.usuario_usuario_id = p_alu_usuario and docencia.calif_ejercicio.relacion_relacion_id = relacion_id) t2 
    on docencia.audit_ejer.ejercicio_id = t2.ejercicio_ejercicio_id 
    where docencia.audit_ejer.usuario_id = p_alu_usuario and docencia.audit_ejer.fecha_entrega_correcto is not null;
   BEGIN
   select usuario_usuario_id into alu_usuario_id  from relacion ;
   select tiempo_minimo
   into tiempo_min 
   from relacion
   where relacion.relacion_id = relacion_id;
    dedic_tiempo_dias := 0;
    dedic_tiempo_horas := 0;
    dedic_tiempo_minutos := 0;
    dedic_tiempo_segundos := 0;
    
    suma_total_min := 0;
    
      FOR calif IN alum_rel(alu_usuario_id) LOOP
      dedic_tiempo_dias := dedic_tiempo_dias + extract(day from (calif.fecha_inicio - calif.fecha_entrega_correcto)); 
      dedic_tiempo_horas := dedic_tiempo_horas + extract(hour from (calif.fecha_inicio - calif.fecha_entrega_correcto));
      dedic_tiempo_minutos := dedic_tiempo_minutos + extract(minute from (calif.fecha_inicio - calif.fecha_entrega_correcto));
      dedic_tiempo_segundos := dedic_tiempo_segundos + extract (second from (calif.fecha_inicio - calif.fecha_entrega_correcto));
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
    
  IF alum_rel%ISOPEN = TRUE THEN 
    CLOSE alum_rel;
  END IF;
  
  suma_total_min := dedic_tiempo_dias*24*60+
                    dedic_tiempo_horas*60+
                    dedic_tiempo_minutos+
                    dedic_tiempo_segundos/60;
  if suma_total_min <= tiempo_min
  then
  dbms_output.put_line('WARNING!! Usuario #'||alu_usuario_id||' ha realizado la relación '||relacion_id|| ' en '||suma_total_min);
  
  
  end if;
     
  exception
  when others then
  dbms_output.put_line('Error desconocido');
    IF alum_rel%ISOPEN = TRUE THEN 
    CLOSE alum_rel;
  END IF;
    end antiplagio_relacion;


END ESTADISTICAS_ALU;