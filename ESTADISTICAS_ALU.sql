create or replace 
PACKAGE BODY ESTADISTICAS_ALU AS

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


  
  
  --Da un informe completo del alumno por asignatura
   --Da un informe completo del alumno por asignatura
  PROCEDURE ANALISIS_ALU_ASIGNATURA(alumno_id number, asignatura_id number) as
  
  nombre_alumno notas_alumnos.nombre%type;
  num_relacion notas_alumnos.relacion%type;
  nota_alu notas_alumnos.nota%type;
  
  v_nombre_alu notas_alumnos.nombre%type;
  v_nombre_asignatura notas_alumnos.asignatura%type;
  
 
  
  cursor sum_cur(nombre_alu varchar2,asignatura_nombre varchar2) is
  select sumNota
  from nota_alu_asig_procedure
  where NOMBRE = nombre_alu
  and
  ASIGNATURA= asignatura_nombre
  ; 
  cursor rel_cur is
  select relacion,nota,nombre 
  from notas_alumnos_para_procedure
  where alumnoid = alumno_id
  and
  ASIGNATURAID = asignatura_id;

no_datos_exception exception;
demasiadas_tuplas_exception exception;
  begin  
  
  
  --truco de poner max - asi nos asegurarmos de que la query devuelva a lo sumo una fila
  begin
  select max(nombre)
  into v_nombre_alu
  from notas_alumnos_para_procedure where alumnoid = alumno_id;
  exception
  when NO_DATA_FOUND then raise no_datos_exception;
  when TOO_MANY_ROWS then raise demasiadas_tuplas_exception;
  end;
  
  begin
  select max(asignatura)
  into v_nombre_asignatura
  from notas_alumnos_para_procedure
  where ASIGNATURAID = asignatura_id;
  exception
  when NO_DATA_FOUND then raise no_datos_exception;
  when TOO_MANY_ROWS then raise demasiadas_tuplas_exception;
  end;
  dbms_output.put_line('');
  dbms_output.put_line('***************  '||v_nombre_alu ||' en la asignatura '||v_nombre_asignatura||'  ***************');
  dbms_output.put_line('');

  FOR tupla IN rel_cur LOOP
    nombre_alumno := tupla.nombre;
    num_relacion := tupla.relacion;
    nota_alu := tupla.nota;
          dbms_output.put_line(nombre_alumno || ': Relacion-> ' || num_relacion || ' Nota-> ' ||nota_alu);
       END LOOP;
       
       IF rel_cur%ISOPEN = TRUE THEN 
        CLOSE rel_cur;
       END IF;
       
  FOR tupla2 in sum_cur(v_nombre_alu,v_nombre_asignatura) LOOP
      dbms_output.put_line('*****   Suma Acumulativa de Asignatura: '||v_nombre_asignatura||': '||tupla2.sumNota||'     *****');
      end loop;
       IF sum_cur%ISOPEN = TRUE THEN 
        CLOSE sum_cur;
       END IF;
      
       
      EXCEPTION
      WHEN NO_DATA_FOUND THEN dbms_output.put_line('Aun no hay entradas para dicho alumno y/o asignatura.');
      WHEN no_datos_exception then dbms_output.put_line('Aun no hay entradas para dicho alumno y/o asignatura.');
      WHEN demasiadas_tuplas_exception then dbms_output.put_line('Error too many rows');
      WHEN OTHERS THEN dbms_output.put_line('Error desconocido.');
  end ANALISIS_ALU_ASIGNATURA;

  PROCEDURE ANALISIS_ALU(alumno_id number) as
  
  cursor asignaturas_cur is
  select asignatura_asignatura_id
  from matricula
  where alumno_alumno_id = alumno_id;
  
  begin
    FOR tupla in asignaturas_cur LOOP
      ANALISIS_ALU_ASIGNATURA(alumno_id,tupla.asignatura_asignatura_id);
      end loop;
       IF asignaturas_cur%ISOPEN = TRUE THEN 
        CLOSE asignaturas_cur;
       END IF;
       EXCEPTION
      WHEN OTHERS THEN dbms_output.put_line('Error desconocido.');
  end ANALISIS_ALU;
 
  ----------------------------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------------------------
 
procedure DEDICACION_ALU_RELACION(alu_usuario_id IN NUMBER, rel_relacion_id IN NUMBER) AS

  
  dedic_tiempo_dias number;
  dedic_tiempo_horas number;
  dedic_tiempo_minutos number;
  dedic_tiempo_segundos number;
  fecha_inicio_al docencia.audit_ejer.fecha_inicio%type;
  fecha_fin_al docencia.audit_ejer.fecha_entrega_correcto%type;
  ER_NO_EXISTE_USER exception;
  ER_NO_EXISTE_REL exception;
  existe_user_rel number;
  
  CURSOR alum_rel is
    select docencia.audit_ejer.fecha_inicio, docencia.audit_ejer.fecha_entrega_correcto from docencia.audit_ejer
    inner join 
    (select docencia.calif_ejercicio.ejercicio_ejercicio_id, docencia.calif_ejercicio.relacion_relacion_id 
    from docencia.calif_ejercicio where docencia.calif_ejercicio.usuario_usuario_id = alu_usuario_id and docencia.calif_ejercicio.relacion_relacion_id = rel_relacion_id) t2 
    on docencia.audit_ejer.ejercicio_id = t2.ejercicio_ejercicio_id 
    where docencia.audit_ejer.usuario_id = alu_usuario_id and docencia.audit_ejer.fecha_entrega_correcto is not null;
  BEGIN
    dedic_tiempo_dias := 0;
    dedic_tiempo_horas := 0;
    dedic_tiempo_minutos := 0;
    dedic_tiempo_segundos := 0;
    
  BEGIN
    select count(*) into existe_user_rel from docencia.usuario where usuario_id = alu_usuario_id;
    IF existe_user_rel = 0 then RAISE ER_NO_EXISTE_USER;
    END IF;
    select count(*) into existe_user_rel from docencia.relacion where rel_relacion_id = docencia.relacion.relacion_id;
    IF existe_user_rel = 0 then RAISE ER_NO_EXISTE_REL;
    END IF;
  END;
    
    FOR calif IN alum_rel LOOP
      dedic_tiempo_dias := dedic_tiempo_dias + extract(day from (calif.fecha_entrega_correcto - calif.fecha_inicio)); 
      dedic_tiempo_horas := dedic_tiempo_horas + extract(hour from (calif.fecha_entrega_correcto - calif.fecha_inicio));
      dedic_tiempo_minutos := dedic_tiempo_minutos + extract(minute from (calif.fecha_entrega_correcto - calif.fecha_inicio));
      dedic_tiempo_segundos := dedic_tiempo_segundos + extract (second from (calif.fecha_entrega_correcto - calif.fecha_inicio));
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
    
  DBMS_OUTPUT.PUT_LINE('El usuario ha dedicado a la relación '|| rel_relacion_id||':');
  DBMS_OUTPUT.PUT_LINE(dedic_tiempo_dias ||' días');
  DBMS_OUTPUT.PUT_LINE(dedic_tiempo_horas ||' horas');
  DBMS_OUTPUT.PUT_LINE(dedic_tiempo_minutos ||' minutos');
  DBMS_OUTPUT.PUT_LINE(dedic_tiempo_segundos ||' segundos.');
  
  EXCEPTION 
  when ER_NO_EXISTE_USER then DBMS_OUTPUT.PUT_LINE('Error, no existe el usuario');
  when ER_NO_EXISTE_REL then DBMS_OUTPUT.PUT_LINE('Error, no existe la relación');
  when others then DBMS_OUTPUT.PUT_LINE('Error desconocido');
  
  END DEDICACION_ALU_RELACION;
  
  ----------------------------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------------------------

  
  --Este procedimiento recibe el identificador de una asignatura y un número N
  --y devuelve los N alumnos con mayor cantidad de puntos de esa asignatura
  PROCEDURE N_MEJORES_ASIGNATURA(asig_id in number, N in number) IS
  
  --El cursor recoge la lista de alumnos de esa asignatura junto a sus notas
  --Ordenados de mayor a menor nota
  CURSOR alumnos_cursor is
   select nombre, sum(nota) n from notas_alumnos_para_procedure where asignaturaID=asig_id
   GROUP BY  nombre, asignatura ORDER BY SUM(nota) desc;
    
  usuario_nombre ALUMNO.NOMBRE%TYPE;  --Almacena el nombre del usuario en el bucle
  cont number :=1;   --Contador para mostrar por pantalla el top y para controlar el límite N
  puntos number;     --Variable que almacena el número de puntos del usuario en el bucle
  nombre_asignatura docencia.asignatura.nombre%type;

  BEGIN

   select nombre into nombre_asignatura from asignatura where asignatura_id=asig_id;
   DBMS_OUTPUT.PUT_LINE('Los mejores alumnos de la asignatura '|| nombre_asignatura ||' son: ');
  
  --Se recorre la lista de alumnos y se muestran por pantalla los N primeros
  FOR al_var in alumnos_cursor LOOP
      
    IF cont<=N  THEN
    usuario_nombre := al_var.nombre;
    puntos := al_var.n;
    --Ejemplo: 1. Usu Ariodep Rueba con 78 puntos
    DBMS_OUTPUT.PUT_LINE(cont||'. '||usuario_nombre ||' con ' || puntos || ' puntos');
    cont := cont+1;
    ELSE
      EXIT;
    END IF;


    
  END LOOP;
    
  IF alumnos_cursor%ISOPEN THEN 
     CLOSE alumnos_cursor;
  END IF;
    
  EXCEPTION
    WHEN others then
    DBMS_OUTPUT.PUT_LINE('Error, no se han podido obtener los mejores alumnos');
  
  END N_MEJORES_ASIGNATURA;
  
  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------
  
  -- Nos da la correlación de ej_ejercicio_id en la nota media de los estudiantes
procedure CORR_EJERCICIO_NOTA(ej_ejercicio_id IN NUMBER) AS
  
  corr_ejer_notas FLOAT;
  ERROR_TABLA_NO_EXISTE exception;
  ERROR_NO_DATOS exception;
  ERROR_DESCONOCIDO exception;
  
  BEGIN
    BEGIN
      -- une el conjunto con las notas de cada alumno en el ejercicio dado con la media de cada estudiante
      select corr(media,nota) into corr_ejer_notas from (select media, nota -- cogemos la correlación
        from (select usuario_usuario_id usuario, sum(nota)/count(nota) media from docencia.calif_ejercicio group by usuario_usuario_id) t1 -- media de cada alu
        join (select distinct usuario_usuario_id, nota from calif_ejercicio where ejercicio_ejercicio_id = ej_ejercicio_id) t2 -- nota de cada alu en el ejercicio dado (param)
          on t1.usuario = t2.usuario_usuario_id); -- une la media del alumno con la nota en ese ejercicio
      EXCEPTION
        WHEN OTHERS THEN
        IF SQLCODE = -00942 then RAISE ERROR_TABLA_NO_EXISTE;
        ELSIF SQLCODE = -01403 then RAISE ERROR_NO_DATOS;
        ELSE RAISE ERROR_DESCONOCIDO;
        END IF;
    END;
    
    IF corr_ejer_notas is null THEN
      DBMS_OUTPUT.PUT_LINE('No existen datos para correlar, o bien estos no presentan dependencia.');
    ELSE
      DBMS_OUTPUT.PUT_LINE('Correlación entre la nota media de los usuarios y el ejercicio '||ej_ejercicio_id||':  '||corr_ejer_notas);
    END IF;
  EXCEPTION
  WHEN ERROR_TABLA_NO_EXISTE THEN DBMS_OUTPUT.PUT_LINE('No existe la tabla o ejercicio.');
  WHEN ERROR_NO_DATOS THEN DBMS_OUTPUT.PUT_LINE('No existe el ejercicio.');
  WHEN ERROR_DESCONOCIDO THEN DBMS_OUTPUT.PUT_LINE('Error desconocido.');
  END CORR_EJERCICIO_NOTA;


END ESTADISTICAS_ALU;
