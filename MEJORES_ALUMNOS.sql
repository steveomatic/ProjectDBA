create or replace 
PACKAGE BODY MEJORES_ALUMNOS AS 

  PROCEDURE N_MEJORES_ASIGNATURA(asig_id in number, num in number) IS
  
  CURSOR alumnos_cursor is
   select nombre, sum(nota) n from notas_alumnos where asignaturaID=asig_id
   GROUP BY  nombre, asignatura ORDER BY SUM(nota) desc;
    
  usuario_nombre ALUMNO.NOMBRE%TYPE;
  cont number :=1;
  puntos number;
  
  BEGIN
  
  FOR al_var in alumnos_cursor LOOP
      
    IF cont<=num  THEN
    usuario_nombre := al_var.nombre;
    puntos := al_var.n;
    DBMS_OUTPUT.PUT_LINE(cont||'. '||usuario_nombre ||' con ' || puntos || ' puntos');
    cont := cont+1;
    END IF;
    
  END LOOP;
  
  END N_MEJORES_ASIGNATURA;

END MEJORES_ALUMNOS;