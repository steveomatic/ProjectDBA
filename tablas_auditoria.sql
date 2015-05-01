CREATE TABLE audit_ejer
  (
  usuario_id  NUMBER NOT NULL,
  ejercicio_id NUMBER NOT NULL,
  fecha_inicio DATE NOT NULL,
  fecha_entrega_ultima DATE,
  fecha_entrega_correcto DATE
  );
  ALTER TABLE audit_ejer ADD CONSTRAINT USUARIO_UNIQUE UNIQUE (usuario_id, ejercicio_id);
