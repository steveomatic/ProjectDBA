create or replace 
PACKAGE BODY MEJORES_ALUMNOS AS 

  PROCEDURE N_MEJORES_ASIGNATURA(asig_id in number, num in number) IS
  
  CURSOR alumnos_cursor is
    SELECT usuario.nombre usuario FROM calif_ejercicio, usuario
    where asignatura_id=asig_id
    GROUP BY usuario.nombre
    order by sum(Nota);
    
  usuario_nombre USUARIO.NOMBRE%TYPE;
  cont number :=1;
  
  BEGIN
  
  FOR al_var in alumnos_cursor LOOP
      
    IF cont<=num  THEN
    usuario_nombre := al_var.usuario;
    DBMS_OUTPUT.PUT_LINE(cont||'. '||usuario_nombre);
    cont := cont+1;
    END IF;
    
  END LOOP;
  
  END N_MEJORES_ASIGNATURA;

END MEJORES_ALUMNOS;