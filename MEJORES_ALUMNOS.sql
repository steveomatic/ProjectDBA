create or replace 
PACKAGE BODY MEJORES_ALUMNOS AS 

  PROCEDURE N_MEJORES_ASIGNATURA(asig_id in number, num in number) IS
  
  CURSOR alumnos_cursor is
   SELECT usuario_id us, sum(nota) n FROM calif_ejercicio, usuario
    where asignatura_id=1 and usuario_id=usuario_usuario_id
    GROUP BY usuario_usuario_id
    order by sum(Nota) desc;
    
  usuario_nombre USUARIO.NOMBRE%TYPE;
  cont number :=1;
  puntos number;
  
  BEGIN
  
  FOR al_var in alumnos_cursor LOOP
      
    IF cont<=num  THEN
    select u.nombre into usuario_nombre from usuario u where usuario_id=al_var.us;
    puntos := al_var.n;
    DBMS_OUTPUT.PUT_LINE(cont||'. '||usuario_nombre ||' con ' || puntos || ' puntos');
    cont := cont+1;
    END IF;
    
  END LOOP;
  
  END N_MEJORES_ASIGNATURA;

END MEJORES_ALUMNOS;