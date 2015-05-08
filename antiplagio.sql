create or replace 
PACKAGE BODY ANTIPLAGIO AS

  PROCEDURE semantico(usuario_id INTEGER, asignatura INTEGER, relacion_id INTEGER, ejercicio_id INTEGER) AS
  --ERROR_ALUMNO_HA_COPIADO EXCEPTION;
  respuesta_alu DOCENCIA.CALIF_EJERCICIO.RESPUESTA%TYPE;
  ha_copiado INTEGER; -- Almacenará 1 si se ha copiado
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
          dbms_output.put_line('Es muy posible que se haya copiado.');
          ha_copiado := 1;
          EXIT;
        END IF;
    END LOOP;
    
    IF ha_copiado = 0 THEN
      dbms_output.put_line('No ha copiado.');
    END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN dbms_output.put_line('El alumno no ha respondido a esa pregunta.');
      WHEN OTHERS THEN dbms_output.put_line('Error desconocido.');
        
  END semantico;

END ANTIPLAGIO;