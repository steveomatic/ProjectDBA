CREATE TABLE audit_ejer
  (
  usuario_id  NUMBER NOT NULL,
  ejercicio_id NUMBER NOT NULL,
  relacion_id NUMBER NOT NULL,
  asignatura_id NUMBER NOT NULL,
  fecha_inicio timestamp NOT NULL,
  fecha_entrega_ultima timestamp,
  fecha_entrega_correcto timestamp
  );
  ALTER TABLE audit_ejer ADD CONSTRAINT USUARIO_UNIQUE UNIQUE (usuario_id, ejercicio_id, relacion_id, asignatura_id);
