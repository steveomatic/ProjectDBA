CREATE OR REPLACE
PACKAGE BODY CORREC_EJER AS

  procedure correccion(usuario_id in number,ejercicio_id in number,relacion_id in number,asignatura_id in number) AS
  /*
  v_alu_query variable que guarda la query 
  enviada por el alumno y despues la ejecuta.
  */
  v_alu_query CALIF_EJERCICIO.RESPUESTA%TYPE;
  
  v_res_query EJERCICIO.SOLUCION%TYPE;
  
 
  v_sol varchar2(255);
  v_sol2 varchar2(255);
  
  
  BEGIN
  --Guardamos  la query en v_alu_query
  select respuesta
  into v_alu_query
  from CALIF_EJERCICIO
  where usuario_usuario_id = usuario_id AND relacion_relacion_id = relacion_id AND asignatura_id = correccion.asignatura_id AND ejercicio_ejercicio_id = ejercicio_id;
  
  
  select solucion
  into v_res_query
  from ejercicio
  where ejercicio_id= correccion.ejercicio_id;
  

  
  dbms_output.put_line(v_alu_query);
  
  
  execute immediate v_alu_query||' MINUS '||v_res_query
  into v_sol;
  
  execute immediate v_res_query||' MINUS '||v_alu_query
  into v_sol2;
  dbms_output.put_line(v_sol);
  
  
  
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
     -- No rows selected, insert your exception handler here
     dbms_output.put_line('Error, no data found');
   WHEN TOO_MANY_ROWS THEN
   dbms_output.put_line('Error, more than 1 solution found! WARNING');
     -- More than 1 row seleced, insert your exception handler here
  
  
  END correccion;

END CORREC_EJER;
