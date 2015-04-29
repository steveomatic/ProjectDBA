CREATE TABLE acceso_ejercicios
  (
  usuario_id  NUMBER NOT NULL,
  ejercicio_id NUMBER NOT NULL,
  fecha_inicio DATE NOT NULL,
  fecha_entrega DATE
  );
  ALTER TABLE acceso_ejercicios ADD CONSTRAINT USUARIO_UNIQUE UNIQUE (usuario_id, ejercicio_id));
