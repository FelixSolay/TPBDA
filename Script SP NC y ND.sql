USE COM2900G09
GO

CREATE OR ALTER PROCEDURE facturacion.GenerarNotaCredito
    @IDFactura INT,                   -- ID de la factura original
    @MontoCredito DECIMAL(9, 2),      -- Monto
    @DevolucionProducto BIT = 0,      -- 0: Devolución monetaria, 1: Devolución de producto
    @IdProductoDevolucion INT = NULL  -- ID del producto seleccionado como devolución
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
       

	    DECLARE @VentaID INT, @VentaCerrada BIT, @ClienteID INT, @Letra CHAR(1), @TotalVenta DECIMAL(9, 2);
        
        SELECT 
            @VentaID = v.ID,
            @VentaCerrada = v.Cerrado,
            @ClienteID = v.Cliente,
            @Letra = f.letra,
            @TotalVenta = v.MontoNeto
        FROM facturacion.Venta v
        INNER JOIN facturacion.factura f ON v.IDFactura = f.ID
        WHERE f.ID = @IDFactura;

        IF @VentaID IS NULL
        BEGIN
            PRINT 'Error: No se encontró una venta asociada a la factura especificada.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF @VentaCerrada = 0
        BEGIN
            PRINT 'Error: La nota de crédito solo se puede emitir para ventas cerradas (pagadas).';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF @MontoCredito > @TotalVenta
        BEGIN
            PRINT 'Error: El monto de la nota de crédito no puede exceder el total de la venta.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

       
        IF @DevolucionProducto = 1
        BEGIN
            DECLARE @PrecioProducto DECIMAL(9, 2), @IdCategoriaProducto INT;

            SELECT @PrecioProducto = Precio, @IdCategoriaProducto = Categoria
            FROM deposito.producto
            WHERE IDProducto = @IdProductoDevolucion;

           IF NOT EXISTS (
                SELECT 1
                FROM facturacion.lineaVenta lv
                INNER JOIN deposito.producto p ON lv.IDProducto = p.IDProducto
                WHERE lv.ID = @VentaID AND p.Categoria = @IdCategoriaProducto
            )
            BEGIN
                PRINT 'Error: No hay productos en la factura original que pertenezcan a la misma categoría que el producto seleccionado.';
                ROLLBACK TRANSACTION;
                RETURN;
            END

            IF @MontoCredito < @PrecioProducto
            BEGIN
                PRINT 'Error: El monto de la nota de crédito no puede ser menor al valor del producto seleccionado para devolución.';
                ROLLBACK TRANSACTION;
                RETURN;
            END
        END

        --generamos número de la nota de crédito después de validar todo
        DECLARE @Numero CHAR(11);
        IF @Letra = 'A'
            SELECT @Numero = RIGHT('0000000000' + CAST(NEXT VALUE FOR FacturaASeq AS VARCHAR), 11);
        ELSE IF @Letra = 'B'
            SELECT @Numero = RIGHT('0000000000' + CAST(NEXT VALUE FOR FacturaBSeq AS VARCHAR), 11);
        ELSE IF @Letra = 'C'
            SELECT @Numero = RIGHT('0000000000' + CAST(NEXT VALUE FOR FacturaCSeq AS VARCHAR), 11);

        
        DECLARE @Fecha DATETIME = GETDATE();
        DECLARE @Hora TIME = CONVERT(TIME, GETDATE());

        INSERT INTO facturacion.nota (factura, tipo, numero, Fecha, Hora, Importe)
        VALUES (@IDFactura, 'NC', @Numero, @Fecha, @Hora, @MontoCredito);

        DECLARE @NotaCreditoID INT = SCOPE_IDENTITY();

       
        IF @DevolucionProducto = 1  --- devol por producto
        BEGIN
            DECLARE @Cantidad INT = 0, @MontoTotal DECIMAL(9, 2) = 0;

            WHILE @MontoTotal + @PrecioProducto <= @MontoCredito
            BEGIN
                SET @MontoTotal = @MontoTotal + @PrecioProducto;
                SET @Cantidad = @Cantidad + 1;
            END

            INSERT INTO facturacion.lineaNota (ID, IDProducto, Cantidad, Monto)
            VALUES (@NotaCreditoID, @IdProductoDevolucion, @Cantidad, @MontoTotal);

            PRINT 'Nota de crédito generada con devolución de productos.';
        END
        ELSE   --- devol monetaria
        BEGIN
            PRINT 'Nota de crédito generada como devolución monetaria.';
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al generar la nota de crédito: ' + ERROR_MESSAGE();
    END CATCH
END
GO



CREATE OR ALTER PROCEDURE facturacion.GenerarNotaDebito
    @IDFactura INT,                  -- ID de la factura original
    @MontoDebito DECIMAL(9, 2)      -- Monto de la nota
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY

        IF NOT EXISTS (
            SELECT 1
            FROM facturacion.factura
            WHERE ID = @IDFactura
        )
        BEGIN
            PRINT 'Error: La factura especificada no existe.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        DECLARE @Letra CHAR(1);
        SELECT @Letra = letra
        FROM facturacion.factura
        WHERE ID = @IDFactura;

        
        DECLARE @Numero CHAR(11);
        IF @Letra = 'A'
            SELECT @Numero = RIGHT('0000000000' + CAST(NEXT VALUE FOR FacturaASeq AS VARCHAR), 11);
        ELSE IF @Letra = 'B'
            SELECT @Numero = RIGHT('0000000000' + CAST(NEXT VALUE FOR FacturaBSeq AS VARCHAR), 11);
        ELSE IF @Letra = 'C'
            SELECT @Numero = RIGHT('0000000000' + CAST(NEXT VALUE FOR FacturaCSeq AS VARCHAR), 11);

        
        DECLARE @Fecha DATETIME = GETDATE();
        DECLARE @Hora TIME = CONVERT(TIME, GETDATE());

        INSERT INTO facturacion.nota (factura, tipo, numero, Fecha, Hora, Importe)
        VALUES (@IDFactura, 'ND', @Numero, @Fecha, @Hora, @MontoDebito);

        PRINT 'Nota de débito generada exitosamente.';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al generar la nota de débito: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

