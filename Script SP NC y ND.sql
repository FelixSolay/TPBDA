USE COM2900G09
GO

CREATE OR ALTER PROCEDURE facturacion.GenerarNotaCredito
    @ComprobanteID INT,                -- ID de la factura original
	@EmpleadoID INT,                   -- ID del empleado que genera la nota
    @Motivo VARCHAR(255),             
    @MontoCredito DECIMAL(9, 2),       
    @DevolucionProducto BIT = 0        -- 0: Devolución monetaria, 1: Devolucion de producto
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY

        --si tiene pago asociado
        DECLARE @IDPago INT;
        SELECT @IDPago = Pago
        FROM facturacion.comprobante
        WHERE ID = @ComprobanteID;

        IF @IDPago IS NULL
        BEGIN
            PRINT 'Error: La nota de crédito solo se puede emitir para facturas pagadas.';
            ROLLBACK TRANSACTION;
            RETURN;
        END


        DECLARE @TotalVenta DECIMAL(9, 2);
        SELECT @TotalVenta = Total FROM facturacion.comprobante WHERE ID = @ComprobanteID;

        IF @MontoCredito > @TotalVenta
        BEGIN
            PRINT 'Error: El monto de la nota de crédito no puede exceder el total de la venta.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

       
        DECLARE @NotaCreditoID INT;
        INSERT INTO facturacion.comprobante (tipo, numero, letra, Fecha, Hora, Total, Cliente, Empleado, Pago)
        SELECT 'NC', numero, letra, GETDATE(), CONVERT(TIME, GETDATE()), @MontoCredito, Cliente, @EmpleadoID, Pago
        FROM facturacion.comprobante
        WHERE ID = @ComprobanteID;

        SET @NotaCreditoID = SCOPE_IDENTITY();

        
        IF @DevolucionProducto = 0  --- 0 = dev monetaria 
        BEGIN
            
            INSERT INTO facturacion.lineaComprobante (ID, IdProducto, Cantidad, Monto)
            SELECT @NotaCreditoID, IdProducto, Cantidad, -Monto
            FROM facturacion.lineaComprobante
            WHERE ID = @ComprobanteID;

            PRINT 'Nota de crédito generada como devolución monetaria.';
        END
        ELSE						--- 1 = dev producto
        BEGIN
            DECLARE @IdProducto INT;
            SELECT TOP 1 @IdProducto = IdProducto
            FROM facturacion.lineaComprobante
            WHERE ID = @ComprobanteID
            ORDER BY NEWID();

            INSERT INTO facturacion.lineaComprobante (ID, IdProducto, Cantidad, Monto)
            VALUES (@NotaCreditoID, @IdProducto, 1, 0);

            PRINT 'Nota de crédito generada con devolución de producto similar.';
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al generar la nota de crédito: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.GenerarNotaDebito
    @ComprobanteID INT,               -- ID de la factura original
    @EmpleadoID INT,                  -- ID del empleado que genera la nota
    @Motivo VARCHAR(255),            -- Motivo de la nota de débito
    @MontoDebito DECIMAL(9, 2)        -- Monto del débito
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY

        DECLARE @NotaDebitoID INT;
        INSERT INTO facturacion.comprobante (tipo, numero, letra, Fecha, Hora, Total, Cliente, Empleado, Pago)
        SELECT 'ND', numero, letra, GETDATE(), CONVERT(TIME, GETDATE()), @MontoDebito, Cliente, @EmpleadoID, Pago
        FROM facturacion.comprobante
        WHERE ID = @ComprobanteID;

        SET @NotaDebitoID = SCOPE_IDENTITY();

       
        INSERT INTO facturacion.lineaComprobante (ID, IdProducto, Cantidad, Monto)
        SELECT @NotaDebitoID, IdProducto, 1, @MontoDebito
        FROM facturacion.lineaComprobante
        WHERE ID = @ComprobanteID;

        PRINT 'Nota de débito generada exitosamente.';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al generar la nota de débito: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

-----------------------------------------------------------------
------------------- EJEMPLO DE EJECUCION ------------------------
-----------------------------------------------------------------

DECLARE @MontoCredito DECIMAL(9, 2) = 200.00;
DECLARE @EmpleadoSupervisorID INT = 1;



--Supervisor
EXECUTE AS LOGIN = 'usuario_supervisor';
EXEC facturacion.GenerarNotaCredito 
    @ComprobanteID = 1, 
	@EmpleadoID = @EmpleadoSupervisorID, 
    @Motivo = 'Devolución parcial', 
    @MontoCredito = 100.00, 
    @DevolucionProducto = 0; 

REVERT;
GO

--Vendedor

DECLARE @EmpleadoNoSupervisorID INT = 2;
EXECUTE AS LOGIN = 'usuario_vendedor';
EXEC facturacion.GenerarNotaCredito 
    @ComprobanteID = 1, 
    @EmpleadoID = @EmpleadoNoSupervisorID, 
    @Motivo = 'Devolución parcial', 
    @MontoCredito = 100.00, 
    @DevolucionProducto = 0; 

REVERT;
GO