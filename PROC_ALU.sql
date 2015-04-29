CREATE OR REPLACE
PACKAGE BODY PROC_ALU AS

  procedure responder(res_respuesta in varchar2,res_usuario_id in number,res_relacion_id in number , res_ejercicio_id in number, res_asignatura_id in number) as
    ERROR_PRIVS_INSUF exception;
    ERROR_DESCONOCIDO exception;
    respuesta_filtrada DOCENCIA.EJERCICIO.SOLUCION%TYPE;
    begin
    
      begin
        --[DEPRECATED] Si el último carácter es un ; entonces lo elimina, si no, nada. 
        --IF SUBSTR(res_respuesta, -1) = ';' THEN respuesta_filtrada := SUBSTR(res_respuesta, 0,length(res_respuesta)-1);
        --ELSE respuesta_filtrada := res_respuesta;
        --END IF;
        
        --Elimina todos los ; de la respuesta.
        respuesta_filtrada := REPLACE(res_respuesta, ';')
        
        update DOCENCIA.calif_ejercicio
        set respuesta = respuesta_filtrada
        where usuario_usuario_id = res_usuario_id 
        AND
        relacion_relacion_id = res_relacion_id
        AND
        asignatura_id = res_asignatura_id
        AND
        ejercicio_ejercicio_id = res_ejercicio_id;
        DBMS_OUTPUT.put_line('Respuesta enviada correctamente');
        EXCEPTION WHEN OTHERS THEN 
        IF SQLCODE = -1031 then raise ERROR_PRIVS_INSUF;
        ELSE raise ERROR_DESCONOCIDO;
        END IF;
      end;
     
    exception
    when ERROR_PRIVS_INSUF then DBMS_OUTPUT.put_line('Error: no se tienen privilegios suficientes');
   
    when ERROR_DESCONOCIDO then DBMS_OUTPUT.put_line('Error desconocido');
    end responder;

END PROC_ALU;
