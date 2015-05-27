CREATE OR REPLACE FUNCTION CURSO_ACTUAL RETURN VARCHAR2 AS 
PRAGMA AUTONOMOUS_TRANSACTION;
var_curso VARCHAR2(5);
num number(5);
var_fecha DATE;
BEGIN
  /*
  Se desea tener una tabla con los cursos académicos de los que hay datos.
  Para ello se ha decidido tener una función que devuelve el curso actual (suponiendo que empieza el 1 de octubre de cada año).
  Así, el 30/09/2015 devuelve 14/15 y el 1/10/2015 devuelve 15/16. Además si ese valor devuelto no existe en la tabla, lo inserta. 
  Utilice transacciones autónomas.
  */
  SELECT sysdate INTO var_fecha FROM dual;
  IF EXTRACT(MONTH FROM var_fecha) >= 10 THEN --Estamos en octubre, nuevo curso académico
    var_curso := substr(extract(year from sysdate),3,4) || '/' || substr(extract(year from sysdate)+1,3,4);
  ELSE
    var_curso := substr(extract(year from sysdate)-1,3,4) || '/' || substr(extract(year from sysdate),3,4);
  END IF;
  
  SELECT count(curso) into num from cursos where curso=var_curso;
  
  IF num = 0 THEN
    INSERT INTO CURSOS VALUES (var_curso);
    COMMIT;
  END IF;
  
  RETURN var_curso;
END CURSO_ACTUAL;
