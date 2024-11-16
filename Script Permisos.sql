-- creacion de roles Supervisor y Vendedor para los SP de NC y ND
use COM2900G09
CREATE ROLE Supervisor
GO

CREATE ROLE Vendedor
GO


CREATE LOGIN usuario_supervisor WITH PASSWORD = '123456'
, DEFAULT_DATABASE = [COM2900G09], CHECK_EXPIRATION = OFF, CHECK_POLICY = OFF
CREATE LOGIN usuario_vendedor WITH PASSWORD = '654321'
, DEFAULT_DATABASE = [COM2900G09], CHECK_EXPIRATION = OFF, CHECK_POLICY = OFF
GO

CREATE USER usuario_supervisor FOR LOGIN usuario_supervisor
CREATE USER usuario_vendedor FOR LOGIN usuario_vendedor
GO 

ALTER ROLE Supervisor ADD MEMBER usuario_supervisor
GRANT EXECUTE
	ON OBJECT::facturacion.GenerarNotaCredito
	TO Supervisor
GRANT EXECUTE
	ON OBJECT::facturacion.GenerarNotaDebito
	TO Supervisor
GO


ALTER ROLE Vendedor ADD MEMBER usuario_vendedor
DENY EXECUTE
	ON OBJECT::facturacion.GenerarNotaCredito
	TO Vendedor
DENY EXECUTE
	ON OBJECT::facturacion.GenerarNotaDebito
	TO Vendedor
GO
