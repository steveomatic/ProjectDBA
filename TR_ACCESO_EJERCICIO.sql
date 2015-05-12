create or replace TRIGGER TR_ACCESO_EJERCICIO 
AFTER UPDATE ON docencia.calif_ejercicio FOR EACH ROW
DECLARE
VAR_RETRIBUCION docencia.ejercicio.retribucion%TYPE;
VAR_FECHA_DOBLE date;
BEGIN  
  --Sólo cuando ele ejercicio esté correcto.
  select retribucion into VAR_RETRIBUCION from docencia.ejercicio where ejercicio_id = :new.ejercicio_ejercicio_id;
  IF :new.nota = VAR_RETRIBUCION THEN
    --Significa que está correcto.
    VAR_FECHA_DOBLE := systimestamp;
    update docencia.audit_ejer set fecha_entrega_correcto = VAR_FECHA_DOBLE, fecha_entrega_ultima = VAR_FECHA_DOBLE where usuario_id = :new.usuario_usuario_id AND ejercicio_id = :new.ejercicio_ejercicio_id;
  ELSE
  --no está correcto, solo cambiamos la fecha de ultima entrega
    update docencia.audit_ejer set fecha_entrega_correcto = null, fecha_entrega_ultima = systimestamp where usuario_id = :new.usuario_usuario_id AND ejercicio_id = :new.ejercicio_ejercicio_id;
  END IF;
END;
