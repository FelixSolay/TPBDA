USE COM2900G09
GO

CREATE OR ALTER PROCEDURE facturacion.GenerarNotaCredito
    @VentaID INT,                     -- ID de la venta original
    @MontoCredito DECIMAL(9, 2),      -- Monto
    @DevolucionProducto BIT = 0,      -- 0: Devolución monetaria, 1: Devolucion de producto
    @IdProductoDevolucion INT = NULL  -- ID del producto a devolver (es opcional)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
		--si el pago existe, se sigue
		DECLARE @VentaCerrada BIT;
		SELECT @VentaCerrada = Cerrado
		FROM facturacion.Venta
		WHERE ID = @VentaID;

		IF @VentaCerrada = 0
		BEGIN
			PRINT 'Error: La nota de crédito solo se puede emitir para ventas pagadas.';
			ROLLBACK TRANSACTION;
			RETURN;
		END
        --validamos monto
        DECLARE @TotalVenta DECIMAL(9, 2);
        SELECT @TotalVenta = MontoNeto FROM facturacion.Venta WHERE ID = @VentaID;

        IF @MontoCredito > @TotalVenta
        BEGIN
            PRINT 'Error: El monto de la nota de crédito no puede exceder el total de la venta.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- info de factura original
        DECLARE @ClienteID INT, @Letra CHAR(1);
        SELECT 
            @ClienteID = v.Cliente, 
            @Letra = f.letra
        FROM facturacion.Venta v
        INNER JOIN facturacion.factura f ON v.IDFactura = f.ID
        WHERE v.ID = @VentaID;

        -- seq de numero dependiendo de letra
        DECLARE @Numero CHAR(11);
        IF @Letra = 'A'
            SELECT @Numero = RIGHT('0000000000' + CAST(NEXT VALUE FOR FacturaASeq AS VARCHAR), 11);
        ELSE IF @Letra = 'B'
            SELECT @Numero = RIGHT('0000000000' + CAST(NEXT VALUE FOR FacturaBSeq AS VARCHAR), 11);
        ELSE IF @Letra = 'C'
            SELECT @Numero = RIGHT('0000000000' + CAST(NEXT VALUE FOR FacturaCSeq AS VARCHAR), 11);

		--insertamos
        DECLARE @Fecha DATETIME = GETDATE();
        DECLARE @Hora TIME = CONVERT(TIME, GETDATE());

        INSERT INTO facturacion.nota (factura, tipo, numero, Fecha, Hora, Importe)
        VALUES (@VentaID, 'NC', @Numero, @Fecha, @Hora, @MontoCredito);

        DECLARE @NotaCreditoID INT = SCOPE_IDENTITY();

        
        IF @DevolucionProducto = 1
        BEGIN
            DECLARE @PrecioProducto DECIMAL(9, 2), @IdCategoriaProducto INT;
            DECLARE @Cantidad INT = 0, @MontoTotal DECIMAL(9,2) = 0;

            
            SELECT @IdCategoriaProducto = categoria
            FROM deposito.producto
            WHERE IDProducto = @IdProductoDevolucion;

            --check que al menos un producto original tenga la misma categoria que el seleccionado por devolución
            IF NOT EXISTS (
                SELECT 1
                FROM facturacion.lineaVenta lv
                INNER JOIN deposito.producto p ON lv.IdProducto = p.IDProducto
                WHERE lv.ID = @VentaID AND p.categoria = @IdCategoriaProducto
            )
            BEGIN
                PRINT 'Error: No hay productos en la factura original que pertenezcan a la misma categoría que el producto seleccionado.';
                ROLLBACK TRANSACTION;
                RETURN;
            END

            
            SELECT @PrecioProducto = Precio FROM deposito.producto WHERE IDProducto = @IdProductoDevolucion;

            WHILE @MontoTotal + @PrecioProducto <= @MontoCredito
            BEGIN
                SET @MontoTotal = @MontoTotal + @PrecioProducto;
                SET @Cantidad = @Cantidad + 1;
            END

            -- insertamos el detalle de nc
            INSERT INTO facturacion.lineaVenta (ID, IDProducto, Cantidad, Monto)
            VALUES (@NotaCreditoID, @IdProductoDevolucion, @Cantidad, @MontoTotal);

            PRINT 'Nota de crédito generada con devolución de productos.';
        END
        ELSE
        BEGIN
            -- devol monetaria
            INSERT INTO facturacion.lineaVenta (ID, IDProducto, Cantidad, Monto)
            VALUES (@NotaCreditoID, NULL, 1, @MontoCredito);

            PRINT 'Nota de crédito generada como devolución monetaria.';
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
    @VentaID INT,               -- ID de la factura original
    @EmpleadoID INT,                  -- ID del empleado que genera la nota
    @MontoDebito DECIMAL(9, 2)       
AS
BEGIN

	BEGIN TRANSACTION;
    BEGIN TRY
       
        DECLARE @ClienteID INT, @Letra CHAR(1);
        SELECT @ClienteID = Cliente, @Letra = Letra
        FROM facturacion.Venta
        WHERE ID = @VentaID;

        
        DECLARE @NuevoNumero CHAR(11);
        SELECT @NuevoNumero = RIGHT('0000000000' + CAST(ISNULL(MAX(CAST(numero AS INT)) + 1, 1) AS VARCHAR), 11)
        FROM facturacion.Venta
        WHERE tipo = 'ND';

       
        DECLARE @Fecha DATETIME = GETDATE();
		DECLARE @Hora TIME = CONVERT(TIME, GETDATE());

        EXEC facturacion.InsertarVenta
            @tipo = 'ND',
            @numero = @NuevoNumero,
            @letra = @Letra,
            @Fecha = @Fecha,
			@Hora = @Hora,
            @Total = @MontoDebito,
            @Cliente = @ClienteID,
            @Empleado = @EmpleadoID,
            @Pago = NULL;  -- no requiere pago inicial

       
        DECLARE @NotaDebitoID INT = SCOPE_IDENTITY();

        
        EXEC facturacion.InsertarLineaVenta
            @ID = @NotaDebitoID,
            @IdProducto = NULL,         -- no asociada a un producto espec�fico
            @Cantidad = 1,              
            @Monto = @MontoDebito;     

        PRINT 'Nota de d�bito generada exitosamente.';

        COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al generar la nota de d�bito: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO




-----------------------------------------------------------------
------------------- EJEMPLO DE EJECUCION ------------------------
-----------------------------------------------------------------

DECLARE @Productos facturacion.TipoProductos;
INSERT INTO @Productos (IdProducto, Cantidad, Monto)
VALUES (1, 2, 150.00),  -- Producto 1, cantidad 2, monto unitario 150.00
       (2, 1, 200.00);  -- Producto 2, cantidad 1, monto unitario 200.00


-- generamos la factura
EXEC facturacion.GenerarFactura
    @ClienteID = 123,
    @EmpleadoID = 456,
	@Letra = 'A',
    @Productos = @Productos;
GO




DECLARE @MontoCredito DECIMAL(9, 2) = 200.00;
DECLARE @EmpleadoSupervisorID INT = 1;



--Supervisor - monetario

EXECUTE AS LOGIN = 'usuario_supervisor';
EXEC facturacion.GenerarNotaCredito 
    @VentaID = 1, 
	@EmpleadoID = @EmpleadoSupervisorID, 
    @MontoCredito = 100.00, 
    @DevolucionProducto = 0; 

REVERT;
GO

--Supervisor - producto

DECLARE @EmpleadoSupervisorID INT = 1;
DECLARE @IdProductoDevolucion INT = 102;

EXECUTE AS LOGIN = 'usuario_supervisor';
EXEC facturacion.GenerarNotaCredito
	@EmpleadoID = @EmpleadoSupervisorID, 
	@VentaID = 1,
    @MontoCredito = 100.00,
    @DevolucionProducto = 1,                  -- Indica que es devolucion por producto
    @IdProductoDevolucion = @IdProductoDevolucion;

REVERT;
GO

--Vendedor - monetario

DECLARE @EmpleadoNoSupervisorID INT = 2;
EXECUTE AS LOGIN = 'usuario_vendedor';
EXEC facturacion.GenerarNotaCredito 
    @VentaID = 1, 
    @EmpleadoID = @EmpleadoNoSupervisorID, 
    @MontoCredito = 100.00, 
    @DevolucionProducto = 0; 

REVERT;
GO
