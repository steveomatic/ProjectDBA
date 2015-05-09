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
  PROCEDURE ANALISIS_ALU_ASIGNATURA(alumno_id number, asignatura_id number) as
  
  nombre_alumno notas_alumnos.nombre%type;
  num_relacion notas_alumnos.relacion%type;
  nota_alu notas_alumnos.nota%type;
  
  v_nombre_alu notas_alumnos.nombre%type;
  v_nombre_asignatura notas_alumnos.asignatura%type;
  
 
  
  cursor med_cur(nombre_alu varchar2,asignatura_nombre varchar2) is
  select mediana
  from mediana_alu_relacion
  where nombre = nombre_alu
  and
  asignatura= asignatura_nombre
  ; 
  cursor rel_cur is
  select relacion,nota,nombre 
  from notas_alumnos
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
  from notas_alumnos where alumnoid = alumno_id;
  exception
  when NO_DATA_FOUND then raise no_datos_exception;
  when TOO_MANY_ROWS then raise demasiadas_tuplas_exception;
  end;
  
  begin
  select max(asignatura)
  into v_nombre_asignatura
  from notas_alumnos
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
       
  FOR tupla2 in med_cur(v_nombre_alu,v_nombre_asignatura) LOOP
      dbms_output.put_line('*****   Mediana Asignatura: '||v_nombre_asignatura||': '||tupla2.mediana||'     *****');
      end loop;
       IF med_cur%ISOPEN = TRUE THEN 
        CLOSE med_cur;
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
  
  


END ESTADISTICAS_ALU;
