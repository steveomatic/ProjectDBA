CREATE OR REPLACE
PACKAGE BODY ESTADISTICAS_ALU AS

  procedure MAS_FALLOS AS
   ejer_id ejercicio.ejercicio_id%type;
   ejercicio_enunciado ejercicio.enunciado%type;
   ejercicio_fallos ejercicio.fallos%type;
   CURSOR ejer_cur is
       select ejercicio_id,enunciado,fallos from ejercicio
       where fallos in (select max(fallos) from ejercicio);
    BEGIN
       OPEN ejer_cur;
       LOOP
          FETCH ejer_cur into ejer_id, ejercicio_enunciado,ejercicio_fallos;
          EXIT WHEN ejer_cur%notfound;
          dbms_output.put_line('ID= '||ejer_id || ' ' || ejercicio_enunciado || ' #Fallos=' ||ejercicio_fallos);
       END LOOP;
       CLOSE ejer_cur;
       
       EXCEPTION
       when others then
       dbms_output.put_line('Error, no se ha podido encontrar los ejercicios');
  END MAS_FALLOS;

END ESTADISTICAS_ALU;