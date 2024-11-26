-- creacion de roles Supervisor y Cajero para los SP de NC y ND
use COM2900G09
CREATE ROLE Supervisor
GO

CREATE ROLE Cajero
GO

CREATE LOGIN usuario_supervisor WITH PASSWORD = '123456'
, DEFAULT_DATABASE = [COM2900G09], CHECK_EXPIRATION = OFF, CHECK_POLICY = OFF
CREATE LOGIN usuario_cajero WITH PASSWORD = '654321'
, DEFAULT_DATABASE = [COM2900G09], CHECK_EXPIRATION = OFF, CHECK_POLICY = OFF
GO

CREATE USER usuario_supervisor FOR LOGIN usuario_supervisor
CREATE USER usuario_cajero FOR LOGIN usuario_cajero
GO 

ALTER ROLE Supervisor ADD MEMBER usuario_supervisor
GRANT EXECUTE
	ON OBJECT::facturacion.GenerarNotaCredito
	TO Supervisor
GRANT EXECUTE
	ON OBJECT::facturacion.GenerarNotaDebito
	TO Supervisor
GO


ALTER ROLE Cajero ADD MEMBER usuario_cajero
DENY EXECUTE
	ON OBJECT::facturacion.GenerarNotaCredito
	TO Cajero
DENY EXECUTE
	ON OBJECT::facturacion.GenerarNotaDebito
	TO Cajero
GO

-----------------------------------------------------------------
------------------- EJEMPLO DE EJECUCION ------------------------
-----------------------------------------------------------------

select * from facturacion.nota

--Supervisor - monetario

EXECUTE AS LOGIN = 'usuario_supervisor'
EXEC facturacion.GenerarNotaCredito 
    @IDFactura = 2,              -- Factura asociada
    @MontoCredito = 122200.00,      -- Monto de la devolución
    @DevolucionProducto = 0;     -- Indica devolución monetaria
REVERT
GO



--Supervisor - producto

DECLARE @IdProductoDevolucion INT = 5  -- Producto seleccionado para devolución

EXECUTE AS LOGIN = 'usuario_supervisor'
EXEC facturacion.GenerarNotaCredito
    @IDFactura = 2,                -- Factura asociada
    @MontoCredito = 125000.00,        -- Monto total de la devolución
    @DevolucionProducto = 1,       -- Indica devolución por producto
    @IdProductoDevolucion = @IdProductoDevolucion;  -- Producto a devolver
REVERT
GO

EXECUTE AS LOGIN = 'usuario_supervisor';
EXEC facturacion.GenerarNotaDebito
    @IDFactura = 2,                -- Factura asociada
    @MontoDebito = 100.00        -- Monto total de la devolución
REVERT
GO


--Cajero - monetario

EXECUTE AS LOGIN = 'usuario_cajero';
EXEC facturacion.GenerarNotaCredito 
    @IDFactura = 1,              -- Factura asociada
    @MontoCredito = 100.00,      -- Monto de la devolución
    @DevolucionProducto = 0     -- Indica devolución monetaria
REVERT
GO

select*from facturacion.nota
