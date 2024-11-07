use AuroraVentas
go


CREATE OR ALTER PROCEDURE ddbba.GenerarNotaCredito
    @VentaID INT,
    @Motivo NVARCHAR(255),
    @MontoCredito DECIMAL(9, 2)
	-- aca deberia recibir las opciones de otro producto o el dinero
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        --para que no exceda el total de la venta
        DECLARE @TotalVenta DECIMAL(9, 2);
        SELECT @TotalVenta = Total FROM ddbba.venta WHERE IDVenta = @VentaID;
        

		--agregar verificacion de rol del empleado



		-- añadir opcion de pedir otro producto de similar valor 

        IF @MontoCredito > @TotalVenta
        BEGIN
            PRINT 'El monto de la nota de credito no puede exceder el total de la venta';
            ROLLBACK TRANSACTION;
            RETURN;
        END

       
       -- EXEC ddbba.InsertarLog 'NotaCredito', @Motivo; ya para anticipar lo del log ver como lo manejamos dsp

	   -- para saber si esta pago solamente deberia checkear si existe el pago, ya que el valor pago del comprobante admite NULL




	   -- hacerlo aca
        
        UPDATE ddbba.venta
        SET Total = Total - @MontoCredito
        WHERE IDVenta = @VentaID;

        COMMIT TRANSACTION;
        PRINT 'Nota de credito generada exitosamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al generar la nota de credito: ' + ERROR_MESSAGE();
    END CATCH;
END
GO

CREATE OR ALTER PROCEDURE ddbba.GenerarNotaDebito
    @VentaID INT,
    @Motivo NVARCHAR(255),
    @MontoDebito DECIMAL(9, 2)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
       
        -- EXEC ddbba.InsertarLog 'NotaDebito', @Motivo;   idem

        
        UPDATE ddbba.venta
        SET Total = Total + @MontoDebito
        WHERE IDVenta = @VentaID;

        COMMIT TRANSACTION;
        PRINT 'Nota de débito generada exitosamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al generar la nota de débito: ' + ERROR_MESSAGE();
    END CATCH;
END
GO