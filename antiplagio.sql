CREATE OR REPLACE
PACKAGE BODY ANTIPLAGIO AS

  PROCEDURE semantico(usuario_id INTEGER, asignatura_id INTEGER, ejercicio_id INTEGER) AS
  respuesta_alu DOCENCIA.CALIF_EJERCICIO.RESPUESTA%TYPE;
  respuesta_copiada INTEGER; -- Almacenará 0 si se ha copiado
  CURSOR c_respuestas IS -- Todas las respuestas al ejercicio "ejercicio_id" excepto la del estudiante usuario_id
    SELECT respuesta FROM calif_ejercicio
    WHERE usuario_usuario_id != usuario_id AND asignatura_id = asignatura_id; 
  
  BEGIN
    SELECT respuesta INTO respuesta_alu FROM calif_ejercicio -- Cogemos la respuesta del estudiante y la metemos en respuesta_alu
      WHERE usuario_usuario_id = usuario_id AND asignatura_id = asignatura_id; 
    FOR respuesta IN c_respuestas LOOP
      --SELECT UPPER(REPLACE(respuesta, ' ')) = UPPER(respuesta_alu) INTO respuesta_copiada FROM DUAL;
      IF UPPER(REPLACE(respuesta, ' ')) = UPPER(respuesta_alu) THEN
        dbms_output.put_line('Es muy posible que se haya copiado. Hay que indicarlo en alguna tabla');
        --INDICARLO EN ALGUNA TABLA
      END IF;
    
    END LOOP;

  END semantico;

END ANTIPLAGIO;