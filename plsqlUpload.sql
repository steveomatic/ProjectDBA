------------------------------------------------------------------
------------------------------------------------------------------
--CREACIÓN DE LOS CINCO PAQUETES (PROCEDURES)
------------------------------------------------------------------
------------------------------------------------------------------

CREATE OR REPLACE PACKAGE ANTIPLAGIO AS 

  PROCEDURE semantico(usuario_id NUMBER, asignatura NUMBER, relacion_id NUMBER, ejercicio_id NUMBER);
  PROCEDURE antiplagio_relacion(param_asignatura_id IN NUMBER, param_relacion_id in number);
  PROCEDURE antiplagio_relacion_todas;
  
END ANTIPLAGIO;



CREATE OR REPLACE PACKAGE CORREC_EJER AS 

  PROCEDURE correccion(cor_usuario_id in number,cor_relacion_id in number , cor_ejercicio_id in number, cor_asignatura_id in number);
  PROCEDURE poner_cero(cor_usuario_id in number,cor_relacion_id in number , cor_ejercicio_id in number, cor_asignatura_id in number);
  PROCEDURE asignacion_ejer(usuario_id in number, relacion_id in number, asignatura_id in number, ejercicio_id in number);
  PROCEDURE crear_ejer(enunciado in varchar2,tema number,solucion in varchar2,retribucion in varchar2,palabras_clave in varchar2);
  PROCEDURE crear_relacion(usuario_id in number, asignatura_asignatura_id in number, tema in number);
  
END CORREC_EJER;



CREATE OR REPLACE PACKAGE ESTADISTICAS_ALU AS 

  PROCEDURE MAS_FALLOS;
  PROCEDURE ANALISIS_ALU_ASIGNATURA(alumno_id number, asignatura_id number);
  PROCEDURE ANALISIS_ALU(alumno_id number);
  PROCEDURE DEDICACION_ALU_RELACION(alu_usuario_id IN NUMBER, rel_relacion_id IN NUMBER);
  PROCEDURE N_MEJORES_ASIGNATURA(asig_id in number, N in number);
  PROCEDURE CORR_EJERCICIO_NOTA(ej_ejercicio_id IN NUMBER);
  
END ESTADISTICAS_ALU;



CREATE OR REPLACE PACKAGE GEST_USUARIO AS 

  PROCEDURE CREAR_USUARIO(usuario IN VARCHAR2, pass IN VARCHAR2);
  PROCEDURE CREAR_USUARIOS(asignatura IN VARCHAR2, numero IN NUMBER);
  PROCEDURE BORRAR_USUARIO(usuario IN VARCHAR2);
  PROCEDURE BORRAR_TODOS_USUARIOS;
  PROCEDURE BLOQUEAR_USUARIO(usuario IN VARCHAR2);
  PROCEDURE BLOQUEAR_TODOS_USUARIOS;
  PROCEDURE DESBLOQUEAR_USUARIO(usuario IN VARCHAR2);
  PROCEDURE DESBLOQUEAR_TODOS_USUARIOS;
  PROCEDURE MATAR_SESION (usuario IN VARCHAR2);
  
END GEST_USUARIO;



CREATE OR REPLACE PACKAGE PROC_ALU AS 

  PROCEDURE correccion_alu(cor_relacion_id in number , cor_ejercicio_id in number, cor_asignatura_id in number);
  PROCEDURE responder(res_respuesta in varchar2,res_relacion_id in number , res_ejercicio_id in number, res_asignatura_id in number);
  PROCEDURE ver_preguntas(ver_relacion_id in number, ver_asignatura_id in number);
  
END PROC_ALU;





---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------
------------------------------------------------------------------
----BODY DE LOS CINCO PAQUETES (PROCEDURES)
------------------------------------------------------------------
------------------------------------------------------------------



CREATE OR REPLACE 
PACKAGE BODY ANTIPLAGIO AS

  PROCEDURE semantico(usuario_id NUMBER, asignatura NUMBER, relacion_id NUMBER, ejercicio_id NUMBER) AS
  --ERROR_ALUMNO_HA_COPIADO EXCEPTION;
  respuesta_alu CALIF_EJERCICIO.RESPUESTA%TYPE;
  ha_copiado NUMBER; -- Almacenará 1 si se ha copiado
  CURSOR c_respuestas IS -- Todas las respuestas al ejercicio "ejercicio_id" excepto la del estudiante usuario_id
    SELECT respuesta,usuario_usuario_id FROM calif_ejercicio
    WHERE usuario_usuario_id != usuario_id AND asignatura = asignatura_id AND ejercicio_ejercicio_id = ejercicio_id; 
  
  BEGIN  
    SELECT respuesta INTO respuesta_alu FROM calif_ejercicio -- Cogemos la respuesta del estudiante y la metemos en respuesta_alu
      WHERE usuario_usuario_id = usuario_id AND asignatura_id = asignatura AND relacion_relacion_id = relacion_id AND ejercicio_ejercicio_id = ejercicio_id; 
    ha_copiado := 0;
    FOR respuesta IN c_respuestas LOOP
        -- Comparo la respuesta del alumno con las respuestas dadas por otros alumnos al mismo ejericio. Quito espacios y lo pongo en mayúsculas.
        IF UPPER(REPLACE(respuesta.respuesta, ' ')) = UPPER(REPLACE(respuesta_alu, ' ')) THEN 
          dbms_output.put_line('Usuario: '||usuario_id||'. Es muy posible que se haya copiado del usuario '||respuesta.usuario_usuario_id);
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


-- Mira si la relación param_relacion_id de la asignatura param_asignatura_id
--se ha realizado en menos tiempo del mínimo estipulado por el profedor
  PROCEDURE antiplagio_relacion(param_asignatura_id IN NUMBER, param_relacion_id in number) AS
    
   dedic_tiempo_dias number;
   dedic_tiempo_horas number;
   dedic_tiempo_minutos number;
   dedic_tiempo_segundos number;
   fecha_inicio_al audit_ejer.fecha_inicio%type;
   fecha_fin_al audit_ejer.fecha_entrega_correcto%type;
   
   var_userid number;
   
   suma_total_min number;
   tiempo_min number;
   excepcion_no_tiempo_minimo exception; 
   excepcion_rel_no_terminada exception;
   excepcion_no_alu           exception;
   CURSOR alum_rel(alu_usuario_id number) is -- Nos da fecha de inicio, fecha de entrega, de cada ejercicio de la relacion, asignatura y alumnno dados
    select audit_ejer.fecha_inicio, audit_ejer.fecha_entrega_ultima 
    from audit_ejer 
    where audit_ejer.relacion_id = param_relacion_id AND audit_ejer.asignatura_id = param_asignatura_id AND audit_ejer.usuario_id = alu_usuario_id;
    
   BEGIN
   begin
   select usuario_usuario_id
   into var_userid
   from relacion
   where
   relacion_id = param_relacion_id
   and asignatura_asignatura_id = param_asignatura_id;
   exception when others
   then
   raise excepcion_no_alu;
   end;
    begin     
      select tiempo_minimo into tiempo_min from relacion where relacion.relacion_id = param_relacion_id AND relacion.asignatura_asignatura_id = param_asignatura_id;
      exception when others then
 raise excepcion_no_tiempo_minimo;
    end;
    dedic_tiempo_dias := 0;
    dedic_tiempo_horas := 0;
    dedic_tiempo_minutos := 0;
    dedic_tiempo_segundos := 0;
    
    suma_total_min := 0;
    
      FOR calif IN alum_rel(var_userid) LOOP
      BEGIN
        IF calif.fecha_entrega_ultima IS NULL THEN
          RAISE excepcion_rel_no_terminada;
        ELSE
          dedic_tiempo_dias := dedic_tiempo_dias + extract(day from calif.fecha_entrega_ultima - calif.fecha_inicio); 
          dedic_tiempo_horas := dedic_tiempo_horas + extract(hour from calif.fecha_entrega_ultima - calif.fecha_inicio);
          dedic_tiempo_minutos := dedic_tiempo_minutos + extract(minute from calif.fecha_entrega_ultima - calif.fecha_inicio);
          dedic_tiempo_segundos := dedic_tiempo_segundos + extract (second from calif.fecha_entrega_ultima - calif.fecha_inicio);
        END IF;
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
  dbms_output.put_line('Atencion: Usuario #'||var_userid||' ha completado la relación '||param_relacion_id|| ' en '||suma_total_min||' minuto/s.');
  
  
  end if;
     
  exception
  when excepcion_no_tiempo_minimo
  then
  dbms_output.put_line('No se ha introducido un tiempo minimo para la relacion '||param_relacion_id);

  when excepcion_rel_no_terminada
  then
  dbms_output.put_line('El alumno aun no ha acabado la relacion o no ha empezado.');
  when excepcion_no_alu
  then
  dbms_output.put_line('No se ha encontrado alumno asociado a tal relacion');
  when others then
  dbms_output.put_line('Error desconocido');
    IF alum_rel%ISOPEN THEN 
    CLOSE alum_rel;
  END IF;
    end antiplagio_relacion;


---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------


  --Igual que la anterior pero muestra el antiplagio de todas las relaciones
  PROCEDURE antiplagio_relacion_todas as
  cursor rel_cur is
  select relacion_id,asignatura_asignatura_id from relacion
  ;
  
  begin
   FOR calif IN rel_cur LOOP 
      
      antiplagio_relacion(calif.asignatura_asignatura_id, calif.relacion_id);
     
    END LOOP;
    exception
    when others then
    dbms_output.put_line('Error, no se ha podido ejecutar');
     IF rel_cur%ISOPEN = TRUE THEN 
    CLOSE rel_cur;
    end if;
  end antiplagio_relacion_todas; 


END ANTIPLAGIO; 



---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------


CREATE OR REPLACE 
PACKAGE BODY CORREC_EJER AS

 PROCEDURE correccion(cor_usuario_id in number,cor_relacion_id in number , cor_ejercicio_id in number, cor_asignatura_id in number)AS
  
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
    from CALIF_EJERCICIO
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
   
    update calif_ejercicio
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



  ---------------------------------------------------------------------------------------------------------------------------
  ---------------------------------------------------------------------------------------------------------------------------
  
  
 PROCEDURE poner_cero(cor_usuario_id in number,cor_relacion_id in number , cor_ejercicio_id in number, cor_asignatura_id in number) AS   
  BEGIN
    update calif_ejercicio
    set nota = 0
    where usuario_usuario_id = cor_usuario_id 
    AND
    relacion_relacion_id = cor_relacion_id
    AND
    asignatura_id = cor_asignatura_id
    AND
    ejercicio_ejercicio_id = cor_ejercicio_id;
    
    IF SQL%ROWCOUNT != 0 THEN
      update ejercicio
      set fallos = fallos+1
      where ejercicio_id = cor_ejercicio_id;
    END IF;
  END poner_cero;


  ---------------------------------------------------------------------------------------------------------------------------
  ---------------------------------------------------------------------------------------------------------------------------
  

  PROCEDURE asignacion_ejer(usuario_id in number, relacion_id in number, asignatura_id in number, ejercicio_id in number)as
  ERROR_PRIVS_INSUF exception;
  ERROR_DESCONOCIDO exception;
  ERROR_PK_VIOLADA exception;
    begin
      begin
        insert into calif_ejercicio(nota,usuario_usuario_id,relacion_relacion_id,ejercicio_ejercicio_id,asignatura_id,respuesta) values(0,usuario_id,relacion_id,ejercicio_id,asignatura_id,null);
        --no insertamos porque lo hace ver_preguntas
        --insert into audit_ejer values(usuario_id, ejercicio_id, relacion_id, asignatura_id, systimestamp, null, null);
        DBMS_OUTPUT.put_line('Asignación satisfactoria');
      EXCEPTION WHEN OTHERS THEN 
        IF SQLCODE = -1031 then raise ERROR_PRIVS_INSUF;
        ELSIF SQLCODE = -1 THEN RAISE ERROR_PK_VIOLADA;
        ELSE raise ERROR_DESCONOCIDO;
        END IF;
    end;
  EXCEPTION
    WHEN ERROR_PRIVS_INSUF THEN DBMS_OUTPUT.put_line('Error: no se tienen privilegios suficientes');
    WHEN ERROR_PK_VIOLADA THEN DBMS_OUTPUT.put_line('Error: Esa asignación ya está hecha. (PK Violada)'); 
    WHEN ERROR_DESCONOCIDO THEN DBMS_OUTPUT.put_line('Error desconocido');
  end asignacion_ejer;
  

  ---------------------------------------------------------------------------------------------------------------------------
  ---------------------------------------------------------------------------------------------------------------------------
      

  PROCEDURE crear_ejer(enunciado in varchar2,tema number,solucion in varchar2,retribucion in varchar2,palabras_clave in varchar2)as
 
  ERROR_PRIVS_INSUF exception;
  ERROR_DESCONOCIDO exception;
  ERROR_PK_VIOLADA exception;
  begin
    begin
      insert into ejercicio(ejercicio_id,tema,enunciado,solucion,fallos,retribucion,palabras_clave) values(ejercicio_seq.NEXTVAL,tema,enunciado,solucion,0,retribucion,palabras_clave);
      EXCEPTION WHEN OTHERS THEN 
      IF SQLCODE = -1031 THEN RAISE ERROR_PRIVS_INSUF;
      ELSIF SQLCODE = -1 THEN RAISE ERROR_PK_VIOLADA;
      ELSE raise ERROR_DESCONOCIDO;
      END IF;
    end;
    DBMS_OUTPUT.put_line('Ejercicio creado satisfactoriamente.');
  EXCEPTION
    WHEN ERROR_PRIVS_INSUF THEN DBMS_OUTPUT.put_line('Error: no se tienen privilegios suficientes.'); 
    WHEN ERROR_PK_VIOLADA THEN DBMS_OUTPUT.put_line('Error: PK violada. Vuelva a intentarlo, la próxima vez se usará una PK diferente.'); 
    WHEN ERROR_DESCONOCIDO THEN DBMS_OUTPUT.put_line('Error desconocido');
  end crear_ejer;


  ---------------------------------------------------------------------------------------------------------------------------
  ---------------------------------------------------------------------------------------------------------------------------


PROCEDURE crear_relacion(usuario_id in number, asignatura_asignatura_id in number, tema in number) as
  ERROR_PRIVS_INSUF exception;
  ERROR_DESCONOCIDO exception;
  ERROR_PK_VIOLADA exception;

  begin
    begin
      insert into relacion(relacion_id,tema,usuario_usuario_id,asignatura_asignatura_id) values(relacion_seq.NEXTVAL,tema,usuario_id,asignatura_asignatura_id);
      EXCEPTION WHEN OTHERS THEN 
        IF SQLCODE = -1031 then raise ERROR_PRIVS_INSUF;
        ELSIF SQLCODE = -1 THEN RAISE ERROR_PK_VIOLADA;
        ELSE raise ERROR_DESCONOCIDO;
        END IF;
    end;
    DBMS_OUTPUT.put_line('Relación creada satisfactoriamente.');
  EXCEPTION
    WHEN ERROR_PRIVS_INSUF THEN DBMS_OUTPUT.put_line('Error: no se tienen privilegios suficientes'); 
    WHEN ERROR_PK_VIOLADA THEN DBMS_OUTPUT.put_line('Error: PK violada. Vuelva a intentarlo, la próxima vez se usará una PK diferente.'); 
    WHEN ERROR_DESCONOCIDO THEN DBMS_OUTPUT.put_line('Error desconocido');
  end crear_relacion;

END CORREC_EJER;





---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------




CREATE OR REPLACE 
PACKAGE BODY ESTADISTICAS_ALU AS

   PROCEDURE MAS_FALLOS AS
   ejer_id ejercicio.ejercicio_id%type;
   ejercicio_enunciado ejercicio.enunciado%type;
   ejercicio_fallos ejercicio.fallos%type;
   CURSOR ejer_cur is -- Cursor que tiene los ejercicios donde más se ha fallado (todos tienen el mismo nº de fallos)
       select ejercicio_id,enunciado,fallos from ejercicio
       where fallos in (select max(fallos) from ejercicio);
       
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


  ----------------------------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------------------------
  
  
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
  
  if v_nombre_alu is null then raise no_datos_exception;
  end if;
  
  begin
  select max(asignatura)
  into v_nombre_asignatura
  from notas_alumnos_para_procedure
  where ASIGNATURAID = asignatura_id;
  exception
  when NO_DATA_FOUND then raise no_datos_exception;
  when TOO_MANY_ROWS then raise demasiadas_tuplas_exception;
  end;
  
   if v_nombre_asignatura is null then raise no_datos_exception;
  end if;
  
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
      dbms_output.put_line('*****   Suma Acumulativa Asignatura: '||v_nombre_asignatura||': '||tupla2.sumNota||'     *****');
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


  ----------------------------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------------------------


  PROCEDURE ANALISIS_ALU(alumno_id number) as
  v_nombre_alu notas_alumnos.nombre%type;
  cursor asignaturas_cur is
  select asignatura_asignatura_id
  from matricula
  where alumno_alumno_id = alumno_id;
  
  no_datos_exception exception;
  
  begin
  begin
  select max(nombre)
  into v_nombre_alu
  from notas_alumnos_para_procedure where alumnoid = alumno_id;
  exception
  when NO_DATA_FOUND then raise no_datos_exception;
  end;
  
  if v_nombre_alu is null then raise no_datos_exception;
  end if;
  
  
    FOR tupla in asignaturas_cur LOOP
      ANALISIS_ALU_ASIGNATURA(alumno_id,tupla.asignatura_asignatura_id);
      end loop;
       IF asignaturas_cur%ISOPEN = TRUE THEN 
        CLOSE asignaturas_cur;
       END IF;
       EXCEPTION
      WHEN no_datos_exception THEN dbms_output.put_line('Alumno no encontrado.');
      when others then dbms_output.put_line('Error desconocido');
  end ANALISIS_ALU;
 

  ----------------------------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------------------------
 

PROCEDURE DEDICACION_ALU_RELACION(alu_usuario_id IN NUMBER, rel_relacion_id IN NUMBER) AS

  
  dedic_tiempo_dias number;
  dedic_tiempo_horas number;
  dedic_tiempo_minutos number;
  dedic_tiempo_segundos number;
  fecha_inicio_al audit_ejer.fecha_inicio%type;
  fecha_fin_al audit_ejer.fecha_entrega_correcto%type;
  ER_NO_EXISTE_USER exception;
  ER_NO_EXISTE_REL exception;
  existe_user_rel number;
  
  CURSOR alum_rel is
    select audit_ejer.fecha_inicio, audit_ejer.fecha_entrega_correcto from audit_ejer
    inner join 
    (select calif_ejercicio.ejercicio_ejercicio_id, calif_ejercicio.relacion_relacion_id 
    from calif_ejercicio where calif_ejercicio.usuario_usuario_id = alu_usuario_id and calif_ejercicio.relacion_relacion_id = rel_relacion_id) t2 
    on audit_ejer.ejercicio_id = t2.ejercicio_ejercicio_id 
    where audit_ejer.usuario_id = alu_usuario_id and audit_ejer.fecha_entrega_correcto is not null;
  BEGIN
    dedic_tiempo_dias := 0;
    dedic_tiempo_horas := 0;
    dedic_tiempo_minutos := 0;
    dedic_tiempo_segundos := 0;
    
  BEGIN
    select count(*) into existe_user_rel from usuario where usuario_id = alu_usuario_id;
    IF existe_user_rel = 0 then RAISE ER_NO_EXISTE_USER;
    END IF;
    select count(*) into existe_user_rel from relacion where rel_relacion_id = relacion.relacion_id;
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
  nombre_asignatura asignatura.nombre%type;

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

  
  -- Nos da la correlación de ej_ejercicio_id en la nota media de los estudiantes
PROCEDURE CORR_EJERCICIO_NOTA(ej_ejercicio_id IN NUMBER) AS
  
  corr_ejer_notas FLOAT;
  ERROR_TABLA_NO_EXISTE exception;
  ERROR_NO_DATOS exception;
  ERROR_DESCONOCIDO exception;
  
  BEGIN
    BEGIN
      -- une el conjunto con las notas de cada alumno en el ejercicio dado con la media de cada estudiante
      select corr(media,nota) into corr_ejer_notas from (select media, nota -- cogemos la correlación
        from (select usuario_usuario_id usuario, sum(nota)/count(nota) media from calif_ejercicio group by usuario_usuario_id) t1 -- media de cada alu
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








---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------






CREATE OR REPLACE
PACKAGE BODY GEST_USUARIO AS 


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


  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------


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
        
        --Excepciones del CREATE user
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


  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------


--Procedimiento para borrar user específico. Recibe el nombre del usuario a borrar
PROCEDURE BORRAR_USUARIO(usuario IN VARCHAR2) IS

  --Declaración de las excepciones propias
  ERROR_PRIVS_INSUF exception;        --Privilegios insuficientes al hacer delete from usuario
  ERROR_USUARIO_NO_EXISTE exception;  --Usuario no existe
  ERROR_DESCONOCIDO exception;        --Otro error
  ERROR_PRIVS_DROP_INSUF exception;   --Privilegios insuficientes para hacer el drop
  ERROR_DESCONOCIDO_DROP exception;   --Error desconocido al hacer el drop
  --BEGIN del procedimiento
  BEGIN 

    --BEGIN del DROP USER
    BEGIN
    EXECUTE IMMEDIATE 'DROP USER ' || usuario || ' CASCADE';
    --DBMS_OUTPUT.PUT_LINE('DROP USER ' || usuario || ' CASCADE');

    --Excepciones del CREATE user
    EXCEPTION WHEN OTHERS THEN
      IF SQLCODE = -01918 then RAISE ERROR_USUARIO_NO_EXISTE;
      ELSIF SQLCODE = -1031 THEN RAISE ERROR_PRIVS_DROP_INSUF;
      ELSE RAISE ERROR_DESCONOCIDO_DROP;
      END IF;
    END;

    --BEGIN del DELETE FROM
    BEGIN
      DELETE FROM usuario WHERE usuario.nombre = usuario;

      --Excepciones del DELETE FROM
      EXCEPTION WHEN OTHERS THEN
        IF SQLCODE = -1031 THEN RAISE ERROR_PRIVS_INSUF;
        ELSE RAISE ERROR_DESCONOCIDO;
        END IF;
    END;
    DBMS_OUTPUT.PUT_LINE('Usuario ' || usuario || ' borrado correctamente');
    --Excepciones del procedimiento
    EXCEPTION
      WHEN ERROR_PRIVS_DROP_INSUF THEN
        DBMS_OUTPUT.put_line('Error: no se tienen privilegios suficientes para borrar al usuario.');
      WHEN ERROR_USUARIO_NO_EXISTE THEN 
        dbms_output.put_line('Error: el usuario no estaba registrado');
      WHEN ERROR_PRIVS_INSUF THEN 
        DBMS_OUTPUT.put_line('Error: Se ha borrado al usuario pero no se ha podido eliminar de la tabla usuarios. Consulte al administrador urgéntemente.');
      WHEN ERROR_DESCONOCIDO THEN
        DBMS_OUTPUT.put_line('Error desconocido');
      WHEN others THEN
        DBMS_OUTPUT.put_line('Error desconocido');

  END BORRAR_USUARIO;
  

  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------


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
  

  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------


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


  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------


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
  

  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------


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


  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------


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
  

  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------


  --Mata la sesión de usuario. Si no la tiene iniciada, nos dice que ese usuario no tiene iniciada la sesión
  --Se utiliza el sinónimo de v$session SESIONES que el profesor ha creado en Olimpia
  PROCEDURE MATAR_SESION (usuario IN VARCHAR2) IS
  
  --Declaramos una variable que va a almacenar el SID de la sesión del usuario
  VAR_SID SESIONES.sid%TYPE;
  --Declaramos una variable que va a almacenar el SERIAL de la sesión del usuario
  VAR_SERIAL# SESIONES.serial#%TYPE;

  ERROR_USUARIO_NO_EXISTE exception;  --El usuario cuya sesión quieren que matemos no existe
  ERROR_DESCONOCIDO exception;        --Otro error
  
  --BEGIN del procedimiento
  BEGIN

    --BEGIN del SELECT
    BEGIN

      --Extraemos el SID y el SERIAL de la sesión del usuario
      --Son los valores que necesitamos para llamar a ALTER SYSTEM KILL SESSION
      SELECT sid into VAR_SID from SESIONES where username = usuario;
      SELECT serial# into VAR_SERIAL# from SESIONES where username = usuario;

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

END GEST_USUARIO;





---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------




CREATE OR REPLACE
PACKAGE BODY PROC_ALU AS


PROCEDURE correccion_alu(cor_relacion_id in number , cor_ejercicio_id in number, cor_asignatura_id in number)AS
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
  
  cor_usuario_id NUMBER;
  
  BEGIN
  SELECT usuario_id INTO cor_usuario_id -- este select coge el usuario_id del que llama al procedure
    FROM usuario
    WHERE UPPER(usuario.nombre) = UPPER(user);  
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
    
  ELSE     --añadir puntuacion 0
    update calif_ejercicio
    set nota = 0
    where usuario_usuario_id = cor_usuario_id 
    AND
    relacion_relacion_id = cor_relacion_id
    AND
    asignatura_id = cor_asignatura_id
    AND
    ejercicio_ejercicio_id = cor_ejercicio_id;
    --aumentar el número de fallos del ejercicio
    
    IF SQL%ROWCOUNT != 0 THEN
      update ejercicio
      set fallos = fallos+1
      where ejercicio_id = cor_ejercicio_id;
    END IF;
  
  END IF;
  
   EXCEPTION 
      WHEN OTHERS THEN
        IF SQLCODE = -01789 then RAISE ERROR_COLUMNAS_DIF;
        ELSIF SQLCODE = -01403 then RAISE ERROR_NO_DATOS;
        ELSIF SQLCODE = -00942 then RAISE ERROR_TABLA_NO_EXISTE;
        ELSE RAISE ERROR_DESCONOCIDO;
        END IF;
  end;
  
  EXCEPTION -- He copiado el código de poner 0 en vez de hacer un función para que así el alumno no tenga permisos de ejecutar esa función.
  WHEN ERROR_ALUMNO THEN 
    DBMS_OUTPUT.PUT_LINE('');
    update calif_ejercicio
    set nota = 0
    where usuario_usuario_id = cor_usuario_id 
    AND
    relacion_relacion_id = cor_relacion_id
    AND
    asignatura_id = cor_asignatura_id
    AND
    ejercicio_ejercicio_id = cor_ejercicio_id;
    --aumentar el número de fallos del ejercicio
    
    IF SQL%ROWCOUNT != 0 THEN
      update ejercicio
      set fallos = fallos+1
      where ejercicio_id = cor_ejercicio_id;
    END IF;
  WHEN ERROR_NO_DATOS then 
    DBMS_OUTPUT.PUT_LINE('No se seleccionó nada.');
    update calif_ejercicio
    set nota = 0
    where usuario_usuario_id = cor_usuario_id 
    AND
    relacion_relacion_id = cor_relacion_id
    AND
    asignatura_id = cor_asignatura_id
    AND
    ejercicio_ejercicio_id = cor_ejercicio_id;
    --aumentar el número de fallos del ejercicio
    
    IF SQL%ROWCOUNT != 0 THEN
      update ejercicio
      set fallos = fallos+1
      where ejercicio_id = cor_ejercicio_id;
    END IF;
  WHEN ERROR_COLUMNAS_DIF THEN 
    DBMS_OUTPUT.PUT_LINE('');
    update calif_ejercicio
    set nota = 0
    where usuario_usuario_id = cor_usuario_id 
    AND
    relacion_relacion_id = cor_relacion_id
    AND
    asignatura_id = cor_asignatura_id
    AND
    ejercicio_ejercicio_id = cor_ejercicio_id;
    --aumentar el número de fallos del ejercicio
    
    IF SQL%ROWCOUNT != 0 THEN
      update ejercicio
      set fallos = fallos+1
      where ejercicio_id = cor_ejercicio_id;
    END IF;
  
  WHEN ERROR_TABLA_NO_EXISTE THEN 
    DBMS_OUTPUT.PUT_LINE('No existe la tabla');
    update calif_ejercicio
    set nota = 0
    where usuario_usuario_id = cor_usuario_id 
    AND
    relacion_relacion_id = cor_relacion_id
    AND
    asignatura_id = cor_asignatura_id
    AND
    ejercicio_ejercicio_id = cor_ejercicio_id;
    --aumentar el número de fallos del ejercicio
    
    IF SQL%ROWCOUNT != 0 THEN
      update ejercicio
      set fallos = fallos+1
      where ejercicio_id = cor_ejercicio_id;
    END IF;
    
  WHEN ERROR_DESCONOCIDO THEN 
    DBMS_OUTPUT.PUT_LINE('Error desconocido correccion');
    update calif_ejercicio
    set nota = 0
    where usuario_usuario_id = cor_usuario_id 
    AND
    relacion_relacion_id = cor_relacion_id
    AND
    asignatura_id = cor_asignatura_id
    AND
    ejercicio_ejercicio_id = cor_ejercicio_id;
    --aumentar el número de fallos del ejercicio
    
    IF SQL%ROWCOUNT != 0 THEN
      update ejercicio
      set fallos = fallos+1
      where ejercicio_id = cor_ejercicio_id;
    END IF;
  
  END correccion_alu;
  
  
  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------
 

  PROCEDURE responder(res_respuesta in varchar2,res_relacion_id in number , res_ejercicio_id in number, res_asignatura_id in number) as
    ERROR_PRIVS_INSUF exception;
    ERROR_DESCONOCIDO exception;
    ERROR_RESPUESTA_NO_ENVIADA exception;
    respuesta_filtrada EJERCICIO.SOLUCION%TYPE;
    res_usuario_id NUMBER;
    begin
    
      SELECT usuario_id INTO res_usuario_id -- este select coge el usuario_id del que llama al procedure
      FROM usuario
      WHERE UPPER(usuario.nombre) = UPPER(user);  
      begin
        --[DEPRECATED] Si el último carácter es un ; entonces lo elimina, si no, nada. 
        --IF SUBSTR(res_respuesta, -1) = ';' THEN respuesta_filtrada := SUBSTR(res_respuesta, 0,length(res_respuesta)-1);
        --ELSE respuesta_filtrada := res_respuesta;
        --END IF;
        
        --Elimina todos los ; de la respuesta.
        respuesta_filtrada := REPLACE(res_respuesta, ';', ' ');
        
        update calif_ejercicio
        set respuesta = respuesta_filtrada
        where usuario_usuario_id = res_usuario_id 
        AND
        relacion_relacion_id = res_relacion_id
        AND
        asignatura_id = res_asignatura_id
        AND
        ejercicio_ejercicio_id = res_ejercicio_id;
        IF SQL%ROWCOUNT = 0 THEN
          RAISE ERROR_RESPUESTA_NO_ENVIADA;
        END IF;
        DBMS_OUTPUT.put_line('Respuesta enviada correctamente');
        correccion_alu(res_relacion_id,res_ejercicio_id, res_asignatura_id);
        DBMS_OUTPUT.put_line('Respuesta autoevaluada');
        EXCEPTION 
          WHEN ERROR_RESPUESTA_NO_ENVIADA THEN
            DBMS_OUTPUT.PUT_LINE('Error: Respuesta no enviada. Compruebe que los parámetros estén bien. ¿Relación correcta? ¿Ejercicio correcto? ¿Asignatura correcta?');
          WHEN OTHERS THEN 
            IF SQLCODE = -1031 then raise ERROR_PRIVS_INSUF;
            ELSE raise ERROR_DESCONOCIDO;
            END IF;
      end;
     
    exception
    when ERROR_PRIVS_INSUF then DBMS_OUTPUT.put_line('Error: no se tienen privilegios suficientes');
   
    when ERROR_DESCONOCIDO then DBMS_OUTPUT.put_line('Error desconocido correccion');

   END responder;
    
    
  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------

   --Para cada relacion, visualiza cada pregunta. Si es la primera vez que se ve el ejercicio, se inserta la fecha de inicio (hoy)
   PROCEDURE ver_preguntas(ver_relacion_id in number, ver_asignatura_id in number) as

   ejer_id  ejercicio.ejercicio_id%type;
   ejercicio_enunciado ejercicio.enunciado%type;
   ejercicio_retribucion ejercicio.retribucion%type;
   ver_usuario_id INTEGER;
   suma_filas NUMBER;
   
   CURSOR ejer_cur (par_usuario INTEGER) is -- el param. del cursor es el usuario id del que llama al procedure
   -- este cursor coge datos sobre los ejercicios de una relación
       select ejercicio.ejercicio_id,ejercicio.enunciado,ejercicio.retribucion 
       from ejercicio JOIN  calif_ejercicio
       on ejercicio.ejercicio_id = calif_ejercicio.ejercicio_ejercicio_id
       where 
       ejercicio.ejercicio_id = calif_ejercicio.ejercicio_ejercicio_id
       and
       calif_ejercicio.usuario_usuario_id = par_usuario
       and
       calif_ejercicio.relacion_relacion_id = ver_relacion_id
       and 
       calif_ejercicio.asignatura_id = ver_asignatura_id
       ; 
        ERROR_PRIVS_INSUF exception;
    ERROR_DESCONOCIDO exception;
                
    BEGIN
    
    SELECT usuario_id INTO ver_usuario_id -- este select coge el usuario_id del que llama al procedure
    FROM usuario
    WHERE UPPER(usuario.nombre) = UPPER(user);  
    
       OPEN ejer_cur(ver_usuario_id);
       LOOP
          FETCH ejer_cur into ejer_id, ejercicio_enunciado,ejercicio_retribucion;
          EXIT WHEN ejer_cur%notfound;
          dbms_output.put_line('ID= '||ejer_id || ' ' || ejercicio_enunciado || ' #Puntos=' ||ejercicio_retribucion);
          begin
          
            select count(*) into suma_filas from audit_ejer
                  where usuario_id = ver_usuario_id
                  and
                  ejer_id = ejercicio_id
                  and
                  ver_relacion_id = relacion_id
                  and
                  ver_asignatura_id = asignatura_id;
            
            IF suma_filas = 0 then
              DBMS_OUTPUT.PUT_LINE('Primera vez visto.');      
              insert into audit_ejer values(ver_usuario_id, ejer_id, ver_relacion_id, ver_asignatura_id, systimestamp, null, null); 
            ELSE
              DBMS_OUTPUT.PUT_LINE('Ya visto.');      
            END IF;
                     
            EXCEPTION WHEN OTHERS THEN 
              IF SQLCODE = -1031 then raise ERROR_PRIVS_INSUF;
              ELSE raise ERROR_DESCONOCIDO;
              END IF;
          end;
          
       END LOOP;
       CLOSE ejer_cur;
       commit; --si no, no insertaba.
       EXCEPTION
        when ERROR_PRIVS_INSUF then 
        DBMS_OUTPUT.put_line('Error: no se tienen privilegios suficientes');
        IF ejer_cur%ISOPEN
        THEN
           CLOSE ejer_cur;
        END IF;
      when ERROR_DESCONOCIDO then
      DBMS_OUTPUT.put_line('Error desconocido de responder');
        IF ejer_cur%ISOPEN
        THEN
           CLOSE ejer_cur;
        END IF;
       WHEN others then
       dbms_output.put_line('Error, no se ha podido encontrar los ejercicios');
         IF ejer_cur%ISOPEN
        THEN
           CLOSE ejer_cur;
        END IF;
 end ver_preguntas;
    
END PROC_ALU;







---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------
------------------------------------------------------------------
----TRIGGER  TR_ACCESO_EJERCICIO
------------------------------------------------------------------
------------------------------------------------------------------



CREATE OR REPLACE TRIGGER TR_ACCESO_EJERCICIO 
AFTER UPDATE ON calif_ejercicio FOR EACH ROW
DECLARE
VAR_RETRIBUCION ejercicio.retribucion%TYPE;
VAR_FECHA_DOBLE date;
BEGIN  
  --Sólo cuando ele ejercicio esté correcto.
  select retribucion into VAR_RETRIBUCION from ejercicio where ejercicio_id = :new.ejercicio_ejercicio_id;
  IF :new.nota = VAR_RETRIBUCION THEN
    --Significa que está correcto.
    VAR_FECHA_DOBLE := systimestamp;
    update audit_ejer set fecha_entrega_correcto = VAR_FECHA_DOBLE, fecha_entrega_ultima = VAR_FECHA_DOBLE where usuario_id = :new.usuario_usuario_id AND ejercicio_id = :new.ejercicio_ejercicio_id;
  ELSE
  --no está correcto, solo cambiamos la fecha de ultima entrega
    update audit_ejer set fecha_entrega_correcto = null, fecha_entrega_ultima = systimestamp where usuario_id = :new.usuario_usuario_id AND ejercicio_id = :new.ejercicio_ejercicio_id;
  END IF;
END;
