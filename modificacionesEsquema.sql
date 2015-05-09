ALTER TABLE matricula
DROP CONSTRAINT MATRICULA_USUARIO_FK;

alter table matricula
ADD CONSTRAINT MATRICULA_USUARIO_FK
FOREIGN KEY (USUARIO_USUARIO_ID)
REFERENCES USUARIO(usuario_id)
ON DELETE CASCADE;



--tiempo minimo va en minutos
alter table relacion add tiempo_minimo number;

--permiso explícito para ejecutar los execute immediate!!
grant create user to docencia;
grant drop user to docencia;
grant grant any role to docencia;
grant alter user to docencia;
grant create sequence to docencia;

--PELIGROSO, pero hace falta para que pueda matar las sesiones
grant alter system to docencia;
