create or replace 
PACKAGE BODY ANTIPLAGIO AS

  PROCEDURE semantico(usuario_id INTEGER, asignatura_id INTEGER, ejercicio_id INTEGER) AS
  ERROR_ALUMNO_HA_COPIADO EXCEPTION;
  respuesta_alu DOCENCIA.CALIF_EJERCICIO.RESPUESTA%TYPE;
  respuesta_copiada INTEGER; -- Almacenará 0 si se ha copiado
  CURSOR c_respuestas IS -- Todas las respuestas al ejercicio "ejercicio_id" excepto la del estudiante usuario_id
    SELECT respuesta FROM calif_ejercicio
    WHERE usuario_usuario_id != usuario_id AND asignatura_id = asignatura_id AND ejercicio_ejercicio_id = ejercicio_id; 
  
  BEGIN
    SELECT respuesta INTO respuesta_alu FROM calif_ejercicio -- Cogemos la respuesta del estudiante y la metemos en respuesta_alu
      WHERE usuario_usuario_id = usuario_id AND asignatura_id = asignatura_id AND ejercicio_ejercicio_id = ejercicio_id; 
    
    FOR respuesta IN c_respuestas LOOP
      BEGIN
          respuesta_copiada := UPPER(REPLACE(respuesta.respuesta, ' '));
         -- SELECT UPPER(REPLACE(respuesta.respuesta, ' ')) INTO respuesta_copiada FROM DUAL; -- Quitamos los espacios y lo ponemso en mayúsucla para compararlo
          dbms_output.put_line(respuesta_copiada);

--        SELECT UPPER(REPLACE(respuesta_alu, ' ')) INTO respuesta_alu FROM DUAL; -- lo mismo con la respuesta del estudiante
  --      dbms_output.put_line(respuesta_alu); -- parece que funciona

        IF respuesta_copiada = respuesta_alu THEN 
            dbms_output.put_line('Es muy posible que se haya copiado.');
            EXIT;
        END IF;
        EXCEPTION 
          WHEN NO_DATA_FOUND THEN -- Si algún select no coge datos es porque la pregutna no se respondió. 
          NULL;
          WHEN OTHERS THEN
            dbms_output.put_line('Error desconocido.');
      END;
    END LOOP;
  END semantico;

END ANTIPLAGIO;
